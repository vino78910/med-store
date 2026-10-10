import '../models/pharmacy_model.dart';
import '../models/inventory_item_model.dart';
import '../models/redistribution_request_model.dart';
import '../models/redistribution_transfer_model.dart';
import '../models/stock_movement_model.dart';
import 'location_service.dart';

class CandidatePharmacy {
  final PharmacyModel pharmacy;
  final InventoryItemModel inventoryItem;
  final int surplusStock;
  final double distanceKm;
  final bool isEligible;
  final String eligibilityReason;
  final double suitabilityScore;

  CandidatePharmacy({
    required this.pharmacy,
    required this.inventoryItem,
    required this.surplusStock,
    required this.distanceKm,
    required this.isEligible,
    required this.eligibilityReason,
    required this.suitabilityScore,
  });
}

class RedistributionService {
  /// Find and rank eligible nearby pharmacies that can supply medicine without depleting their own reserves
  static List<CandidatePharmacy> findEligibleSuppliers({
    required String requestingPharmacyId,
    required double requestingLat,
    required double requestingLng,
    required String medicineId,
    required String strength,
    required String dosageForm,
    required int requestedQuantity,
    required List<PharmacyModel> allPharmacies,
    required List<InventoryItemModel> allInventory,
    double searchRadiusKm = 5.0,
  }) {
    final List<CandidatePharmacy> candidates = [];

    for (final pharmacy in allPharmacies) {
      // 1. Exclude the requesting pharmacy
      if (pharmacy.id == requestingPharmacyId) continue;

      // 2. Calculate distance using Haversine formula
      final double distance = LocationService.calculateDistanceKm(
        startLatitude: requestingLat,
        startLongitude: requestingLng,
        endLatitude: pharmacy.latitude,
        endLongitude: pharmacy.longitude,
      );

      // 3. Filter within search radius
      if (distance > searchRadiusKm) continue;

      // 4. Find matching medicine in candidate pharmacy's inventory
      final matchingItems = allInventory.where((item) =>
          item.pharmacyId == pharmacy.id &&
          item.medicineId == medicineId &&
          item.strength.toLowerCase() == strength.toLowerCase() &&
          item.dosageForm.toLowerCase() == dosageForm.toLowerCase() &&
          !item.isExpired);

      if (matchingItems.isEmpty) continue;
      final inventoryItem = matchingItems.first;

      // 5. Calculate safe surplus stock:
      // Current Stock - (Minimum Threshold + 2-Day Expected Demand)
      final int safeReserve = (inventoryItem.minStockThreshold +
              (inventoryItem.averageDailyConsumption * 2).ceil());
      final int surplus = inventoryItem.currentStock - safeReserve;

      // 6. Check eligibility: Never create a shortage at source pharmacy!
      bool isEligible = false;
      String reason = '';

      if (surplus <= 0) {
        isEligible = false;
        reason =
            'Insufficient surplus. Current stock (${inventoryItem.currentStock}) is needed for local patient reserve ($safeReserve).';
      } else if (surplus < requestedQuantity) {
        isEligible = false;
        reason =
            'Partial surplus only ($surplus units available, $requestedQuantity needed). Transferring would cause local shortage.';
      } else {
        isEligible = true;
        reason = 'Eligible! Has safe surplus of $surplus units.';
      }

      // 7. Calculate ranking suitability score (Higher is better)
      // Balances surplus availability (60%) and proximity (40%)
      final double distanceScore = 1.0 / (1.0 + distance);
      final double surplusScore = surplus / (surplus + requestedQuantity);
      final double score = (surplusScore * 0.6) + (distanceScore * 0.4);

      candidates.add(
        CandidatePharmacy(
          pharmacy: pharmacy.withDistance(distance),
          inventoryItem: inventoryItem,
          surplusStock: surplus > 0 ? surplus : 0,
          distanceKm: distance,
          isEligible: isEligible,
          eligibilityReason: reason,
          suitabilityScore: score,
        ),
      );
    }

    // Sort: Eligible first, then highest suitability score
    candidates.sort((a, b) {
      if (a.isEligible && !b.isEligible) return -1;
      if (!a.isEligible && b.isEligible) return 1;
      return b.suitabilityScore.compareTo(a.suitabilityScore);
    });

    return candidates;
  }

  /// Create a Redistribution Request
  static RedistributionRequestModel createRequest({
    required String id,
    required String requestingPharmacyId,
    required String requestingPharmacyName,
    required String targetPharmacyId,
    required String targetPharmacyName,
    required String medicineId,
    required String medicineName,
    required String strength,
    required String dosageForm,
    required int requestedQuantity,
    RequestUrgency urgency = RequestUrgency.normal,
    double distanceKm = 0.0,
  }) {
    return RedistributionRequestModel(
      id: id,
      requestingPharmacyId: requestingPharmacyId,
      requestingPharmacyName: requestingPharmacyName,
      targetPharmacyId: targetPharmacyId,
      targetPharmacyName: targetPharmacyName,
      medicineId: medicineId,
      medicineName: medicineName,
      strength: strength,
      dosageForm: dosageForm,
      requestedQuantity: requestedQuantity,
      urgency: urgency,
      status: RequestStatus.pending,
      distanceKm: distanceKm,
      createdAt: DateTime.now(),
    );
  }

  /// Execute atomic transfer completion logic
  static ({
    RedistributionTransferModel completedTransfer,
    InventoryItemModel updatedSourceItem,
    InventoryItemModel updatedDestItem,
    StockMovementModel sourceMovement,
    StockMovementModel destMovement,
  }) completeTransferLocally({
    required RedistributionTransferModel transfer,
    required InventoryItemModel sourceItem,
    required InventoryItemModel destItem,
    required String completedByUserId,
  }) {
    final int qty = transfer.agreedQuantity;

    if (sourceItem.currentStock < qty) {
      throw Exception(
        'Cannot complete transfer: Source pharmacy has insufficient stock (${sourceItem.currentStock} < $qty)',
      );
    }

    // Decrement source inventory
    final newSourceStock = sourceItem.currentStock - qty;
    final double sourceDays = sourceItem.averageDailyConsumption > 0
        ? double.parse((newSourceStock / sourceItem.averageDailyConsumption).toStringAsFixed(1))
        : 999.0;
    final updatedSource = sourceItem.copyWith(
      currentStock: newSourceStock,
      estimatedDaysRemaining: sourceDays,
      status: newSourceStock == 0
          ? StockStatus.outOfStock
          : (sourceDays <= sourceItem.criticalDaysThreshold
              ? StockStatus.critical
              : (sourceDays <= sourceItem.warningDaysThreshold
                  ? StockStatus.warning
                  : StockStatus.normal)),
      lastStockUpdate: DateTime.now(),
    );

    // Increment destination inventory
    final newDestStock = destItem.currentStock + qty;
    final double destDays = destItem.averageDailyConsumption > 0
        ? double.parse((newDestStock / destItem.averageDailyConsumption).toStringAsFixed(1))
        : 999.0;
    final updatedDest = destItem.copyWith(
      currentStock: newDestStock,
      estimatedDaysRemaining: destDays,
      status: destDays <= destItem.criticalDaysThreshold
          ? StockStatus.critical
          : (destDays <= destItem.warningDaysThreshold
              ? StockStatus.warning
              : StockStatus.normal),
      lastStockUpdate: DateTime.now(),
    );

    // Create Stock Movement log for Source
    final sourceMovement = StockMovementModel(
      id: 'SM-${DateTime.now().millisecondsSinceEpoch}-SRC',
      pharmacyId: transfer.sourcePharmacyId,
      medicineId: transfer.medicineId,
      medicineName: transfer.medicineName,
      movementType: MovementType.transferOut,
      quantity: qty,
      previousStock: sourceItem.currentStock,
      newStock: newSourceStock,
      timestamp: DateTime.now(),
      performedBy: completedByUserId,
      referenceId: transfer.id,
      notes: 'Redistributed to ${transfer.destinationPharmacyName}',
    );

    // Create Stock Movement log for Destination
    final destMovement = StockMovementModel(
      id: 'SM-${DateTime.now().millisecondsSinceEpoch}-DST',
      pharmacyId: transfer.destinationPharmacyId,
      medicineId: transfer.medicineId,
      medicineName: transfer.medicineName,
      movementType: MovementType.transferIn,
      quantity: qty,
      previousStock: destItem.currentStock,
      newStock: newDestStock,
      timestamp: DateTime.now(),
      performedBy: completedByUserId,
      referenceId: transfer.id,
      notes: 'Received redistribution transfer from ${transfer.sourcePharmacyName}',
    );

    final completedTransfer = transfer.copyWith(
      status: TransferStatus.completed,
      completedAt: DateTime.now(),
    );

    return (
      completedTransfer: completedTransfer,
      updatedSourceItem: updatedSource,
      updatedDestItem: updatedDest,
      sourceMovement: sourceMovement,
      destMovement: destMovement,
    );
  }
}
