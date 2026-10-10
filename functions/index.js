const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// =========================================================================
// 1. AUTOMATIC STOCK MONITORING & STOCKOUT PREDICTION
// =========================================================================
exports.onInventoryUpdated = functions.firestore
  .document("pharmacies/{pharmacyId}/inventory/{itemId}")
  .onWrite(async (change, context) => {
    const { pharmacyId, itemId } = context.params;

    if (!change.after.exists) {
      console.log(`Inventory item ${itemId} was deleted from pharmacy ${pharmacyId}`);
      return null;
    }

    const data = change.after.data();
    const currentStock = Number(data.currentStock) || 0;
    const avgDailyConsumption = Number(data.averageDailyConsumption) || 1.0;
    const warningDays = Number(data.warningDaysThreshold) || 3.0;
    const criticalDays = Number(data.criticalDaysThreshold) || 1.0;

    // Calculate Estimated Days Remaining
    let estimatedDaysRemaining = 999;
    if (currentStock <= 0) {
      estimatedDaysRemaining = 0;
    } else if (avgDailyConsumption > 0) {
      estimatedDaysRemaining = parseFloat((currentStock / avgDailyConsumption).toFixed(1));
    }

    // Determine Status
    let status = "NORMAL";
    let riskLevel = null;

    if (currentStock === 0) {
      status = "OUT OF STOCK";
      riskLevel = "OUT OF STOCK";
    } else if (estimatedDaysRemaining <= criticalDays) {
      status = "CRITICAL";
      riskLevel = "CRITICAL";
    } else if (estimatedDaysRemaining <= warningDays) {
      status = "WARNING";
      riskLevel = "WARNING";
    }

    // Update the inventory document if status or estimatedDaysRemaining changed
    if (data.status !== status || data.estimatedDaysRemaining !== estimatedDaysRemaining) {
      await change.after.ref.update({
        status: status,
        estimatedDaysRemaining: estimatedDaysRemaining,
        lastEvaluatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Check if Alert is required
    const alertsRef = db.collection("stock_alerts");

    if (riskLevel) {
      // Check for existing unresolved alert to prevent duplicate notifications
      const existingAlerts = await alertsRef
        .where("pharmacyId", "==", pharmacyId)
        .where("medicineId", "==", data.medicineId)
        .where("isResolved", "==", false)
        .limit(1)
        .get();

      const pharmacyDoc = await db.collection("pharmacies").doc(pharmacyId).get();
      const pharmacyName = pharmacyDoc.exists ? pharmacyDoc.data().name : "Unknown Pharmacy";

      const alertPayload = {
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        medicineId: data.medicineId,
        medicineName: data.medicineName || "Medicine",
        currentStock: currentStock,
        averageDailyConsumption: avgDailyConsumption,
        estimatedDaysRemaining: estimatedDaysRemaining,
        riskLevel: riskLevel,
        isAcknowledged: false,
        isResolved: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (existingAlerts.empty) {
        // Create new alert
        const newAlert = await alertsRef.add(alertPayload);

        // Add to Notifications Collection
        await db.collection("notifications").add({
          targetPharmacyId: pharmacyId,
          type: riskLevel === "OUT OF STOCK" ? "OUT_OF_STOCK" : (riskLevel === "CRITICAL" ? "CRITICAL_ALERT" : "STOCK_WARNING"),
          title: `Stock ${riskLevel}: ${data.medicineName}`,
          body: `${data.medicineName} has ${currentStock} units left (${estimatedDaysRemaining} days remaining).`,
          dataPayload: { alertId: newAlert.id, itemId: itemId, medicineId: data.medicineId },
          isRead: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Send FCM Push Notification to Pharmacy Staff
        await sendFcmToPharmacy(pharmacyId, {
          title: `⚠️ ${riskLevel}: ${data.medicineName}`,
          body: `Current stock: ${currentStock}. Estimated ${estimatedDaysRemaining} day(s) remaining.`,
          data: { type: "STOCK_ALERT", medicineId: data.medicineId },
        });

      } else {
        // Update existing alert with latest figures
        const alertId = existingAlerts.docs[0].id;
        await alertsRef.doc(alertId).update({
          currentStock: currentStock,
          estimatedDaysRemaining: estimatedDaysRemaining,
          riskLevel: riskLevel,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    } else {
      // Stock is back to NORMAL: automatically resolve any unresolved alerts
      const activeAlerts = await alertsRef
        .where("pharmacyId", "==", pharmacyId)
        .where("medicineId", "==", data.medicineId)
        .where("isResolved", "==", false)
        .get();

      const batch = db.batch();
      activeAlerts.forEach((doc) => {
        batch.update(doc.ref, {
          isResolved: true,
          resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
          resolutionNote: "Restocked to normal levels",
        });
      });
      await batch.commit();
    }

    return null;
  });

// =========================================================================
// 2. ATOMIC REDISTRIBUTION TRANSFER EXECUTION
// =========================================================================
exports.completeRedistributionTransfer = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { transferId } = data;
  if (!transferId) {
    throw new functions.https.HttpsError("invalid-argument", "transferId is required.");
  }

  return await db.runTransaction(async (transaction) => {
    const transferRef = db.collection("redistribution_transfers").doc(transferId);
    const transferDoc = await transaction.get(transferRef);

    if (!transferDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Transfer record not found.");
    }

    const transfer = transferDoc.data();
    if (transfer.status === "COMPLETED") {
      throw new functions.https.HttpsError("failed-precondition", "Transfer has already been completed.");
    }

    const { sourcePharmacyId, destinationPharmacyId, medicineId, agreedQuantity } = transfer;
    const qty = Number(agreedQuantity);

    // Source inventory query
    const sourceInvQuery = await db
      .collection(`pharmacies/${sourcePharmacyId}/inventory`)
      .where("medicineId", "==", medicineId)
      .limit(1)
      .get();

    if (sourceInvQuery.empty) {
      throw new functions.https.HttpsError("failed-precondition", "Source pharmacy does not hold this medicine.");
    }

    const sourceInvDoc = sourceInvQuery.docs[0];
    const sourceStock = Number(sourceInvDoc.data().currentStock) || 0;

    if (sourceStock < qty) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        `Insufficient source stock. Available: ${sourceStock}, Requested: ${qty}`
      );
    }

    // Destination inventory query
    const destInvQuery = await db
      .collection(`pharmacies/${destinationPharmacyId}/inventory`)
      .where("medicineId", "==", medicineId)
      .limit(1)
      .get();

    // Perform atomic stock updates
    const newSourceStock = sourceStock - qty;
    transaction.update(sourceInvDoc.ref, {
      currentStock: newSourceStock,
      lastStockUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });

    let newDestStock = qty;
    if (!destInvQuery.empty) {
      const destInvDoc = destInvQuery.docs[0];
      newDestStock = (Number(destInvDoc.data().currentStock) || 0) + qty;
      transaction.update(destInvDoc.ref, {
        currentStock: newDestStock,
        lastStockUpdate: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // Create new inventory item in destination pharmacy
      const newDestItemRef = db.collection(`pharmacies/${destinationPharmacyId}/inventory`).doc();
      transaction.set(newDestItemRef, {
        pharmacyId: destinationPharmacyId,
        medicineId: medicineId,
        medicineName: transfer.medicineName,
        currentStock: qty,
        minStockThreshold: 10,
        averageDailyConsumption: 2.0,
        status: "NORMAL",
        lastStockUpdate: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Log Stock Movement for Source Pharmacy (TRANSFER_OUT)
    const sourceMovementRef = db.collection("stock_movements").doc();
    transaction.set(sourceMovementRef, {
      pharmacyId: sourcePharmacyId,
      medicineId: medicineId,
      movementType: "TRANSFER_OUT",
      quantity: qty,
      previousStock: sourceStock,
      newStock: newSourceStock,
      performedBy: context.auth.uid,
      referenceId: transferId,
      notes: `Redistribution transfer out to pharmacy ${destinationPharmacyId}`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Log Stock Movement for Destination Pharmacy (TRANSFER_IN)
    const destMovementRef = db.collection("stock_movements").doc();
    transaction.set(destMovementRef, {
      pharmacyId: destinationPharmacyId,
      medicineId: medicineId,
      movementType: "TRANSFER_IN",
      quantity: qty,
      previousStock: destInvQuery.empty ? 0 : Number(destInvQuery.docs[0].data().currentStock),
      newStock: newDestStock,
      performedBy: context.auth.uid,
      referenceId: transferId,
      notes: `Redistribution transfer in from pharmacy ${sourcePharmacyId}`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Mark transfer as COMPLETED
    transaction.update(transferRef, {
      status: "COMPLETED",
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      completedBy: context.auth.uid,
    });

    return {
      success: true,
      transferId: transferId,
      sourceNewStock: newSourceStock,
      destinationNewStock: newDestStock,
    };
  });
});

// =========================================================================
// 3. PATIENT AVAILABILITY ALERTS TRIGGER
// =========================================================================
exports.notifySubscribedPatientsOnRestock = functions.firestore
  .document("pharmacies/{pharmacyId}/inventory/{itemId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Trigger only when transitioning from unavailable (<= 0) to available (> 0)
    if (beforeData.currentStock <= 0 && afterData.currentStock > 0) {
      const medicineId = afterData.medicineId;
      const pharmacyId = context.params.pharmacyId;

      const pharmacyDoc = await db.collection("pharmacies").doc(pharmacyId).get();
      const pharmacy = pharmacyDoc.data();

      // Find active subscriptions for this medicine
      const subs = await db
        .collection("patient_subscriptions")
        .where("medicineId", "==", medicineId)
        .where("active", "==", true)
        .get();

      if (subs.empty) return null;

      const promises = [];
      subs.forEach((subDoc) => {
        const sub = subDoc.data();
        promises.push(
          db.collection("notifications").add({
            targetUserId: sub.patientId,
            type: "PATIENT_AVAILABILITY",
            title: `Medicine Available: ${afterData.medicineName}`,
            body: `${afterData.medicineName} is now in stock at ${pharmacy.name}. Contact: ${pharmacy.phone}`,
            dataPayload: {
              pharmacyId: pharmacyId,
              medicineId: medicineId,
              pharmacyName: pharmacy.name,
              pharmacyPhone: pharmacy.phone,
            },
            isRead: false,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          })
        );
      });

      await Promise.all(promises);
    }
    return null;
  });

// =========================================================================
// HELPER: Send FCM Push Notification
// =========================================================================
async function sendFcmToPharmacy(pharmacyId, { title, body, data }) {
  try {
    const usersSnapshot = await db
      .collection("users")
      .where("pharmacyId", "==", pharmacyId)
      .where("fcmToken", "!=", null)
      .get();

    const tokens = [];
    usersSnapshot.forEach((doc) => {
      const t = doc.data().fcmToken;
      if (t) tokens.push(t);
    });

    if (tokens.length === 0) return;

    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      notification: { title, body },
      data: data || {},
    });
  } catch (error) {
    console.error("FCM dispatch error:", error);
  }
}
