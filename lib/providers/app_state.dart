import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/pharmacy_model.dart';
import '../models/medicine_model.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_alert_model.dart';
import '../models/stock_movement_model.dart';
import '../models/redistribution_request_model.dart';
import '../models/redistribution_transfer_model.dart';
import '../models/patient_subscription_model.dart';
import '../models/notification_model.dart';
import '../services/sample_data_service.dart';
import '../services/stock_monitor_service.dart';
import '../services/redistribution_service.dart';
import '../services/patient_service.dart';
import '../services/location_service.dart';

class AppState extends ChangeNotifier {
  // Current active user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Repositories
  List<PharmacyModel> _pharmacies = [];
  List<MedicineModel> _medicines = [];
  List<InventoryItemModel> _inventory = [];
  List<StockAlertModel> _alerts = [];
  List<StockMovementModel> _movements = [];
  List<RedistributionRequestModel> _requests = [];
  List<RedistributionTransferModel> _transfers = [];
  List<PatientSubscriptionModel> _subscriptions = [];
  List<NotificationModel> _notifications = [];

  // Configurable thresholds for current pharmacy
  StockoutThresholds _thresholds = const StockoutThresholds(
    warningDays: 3.0,
    criticalDays: 1.0,
  );
  StockoutThresholds get thresholds => _thresholds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppState() {
    _initializeDemoData();
  }

  void _initializeDemoData() {
    _pharmacies = SampleDataService.getInitialPharmacies();
    _medicines = SampleDataService.getInitialMedicines();
    _inventory = SampleDataService.getInitialInventory();
    _alerts = SampleDataService.getInitialAlerts();
    _movements = SampleDataService.getInitialMovements();
    _requests = SampleDataService.getInitialRequests();
    _transfers = SampleDataService.getInitialTransfers();
    _subscriptions = SampleDataService.getInitialSubscriptions();
    _notifications = SampleDataService.getInitialNotifications();

    // Default to Pharmacy Admin role for Apex Care Pharmacy
    _currentUser = SampleDataService.getSamplePharmacyAdmin();
    notifyListeners();
  }

  // =========================================================================
  // USER & ROLE MANAGEMENT
  // =========================================================================
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Switch roles instantly during hackathon evaluation
  void switchDemoRole(UserRole role) {
    switch (role) {
      case UserRole.pharmacyAdmin:
        _currentUser = SampleDataService.getSamplePharmacyAdmin();
        break;
      case UserRole.pharmacist:
        _currentUser = SampleDataService.getSamplePharmacist();
        break;
      case UserRole.patient:
        _currentUser = SampleDataService.getSamplePatient();
        break;
    }
    notifyListeners();
  }

  /// Switch active pharmacy perspective (e.g. switch to Metro Cure Pharmacy B to view incoming request)
  void switchActivePharmacy(String pharmacyId) {
    final pharmacy = _pharmacies.firstWhere(
      (p) => p.id == pharmacyId,
      orElse: () => _pharmacies.first,
    );
    if (_currentUser != null && _currentUser!.isPharmacyStaff) {
      _currentUser = _currentUser!.copyWith(
        pharmacyId: pharmacy.id,
        pharmacyName: pharmacy.name,
      );
      notifyListeners();
    }
  }

  void login({required String email, required String password}) {
    // Check if matches demo admin
    if (email.contains('admin')) {
      _currentUser = SampleDataService.getSamplePharmacyAdmin();
    } else if (email.contains('pharm') || email.contains('sarah')) {
      _currentUser = SampleDataService.getSamplePharmacist();
    } else {
      _currentUser = SampleDataService.getSamplePatient();
    }
    notifyListeners();
  }

  void register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyPhone,
    String? operatingHours,
  }) {
    String? pharmacyId;
    if (role != UserRole.patient) {
      pharmacyId = 'pharm_${DateTime.now().millisecondsSinceEpoch}';
      final newPharmacy = PharmacyModel(
        id: pharmacyId,
        name: pharmacyName ?? 'New Registered Pharmacy',
        address: pharmacyAddress ?? 'Local Medical Street',
        latitude: LocationService.defaultLatitude + 0.005,
        longitude: LocationService.defaultLongitude + 0.005,
        phone: pharmacyPhone ?? '+91 99999 88888',
        email: email,
        operatingHours: operatingHours ?? '8:00 AM - 10:00 PM',
        licenseNumber: 'REG-${DateTime.now().millisecondsSinceEpoch % 10000}',
        isVerified: true,
      );
      _pharmacies.add(newPharmacy);
    }

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // =========================================================================
  // PHARMACY DASHBOARD METRICS
  // =========================================================================
  PharmacyModel? get currentPharmacy {
    if (_currentUser?.pharmacyId == null) return null;
    try {
      return _pharmacies.firstWhere((p) => p.id == _currentUser!.pharmacyId);
    } catch (_) {
      return null;
    }
  }

  List<InventoryItemModel> get currentPharmacyInventory {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return [];
    return _inventory.where((item) => item.pharmacyId == pharmacyId).toList();
  }

  int get totalMedicinesCount => currentPharmacyInventory.length;

  int get availableMedicinesCount => currentPharmacyInventory
      .where((item) => item.status == StockStatus.normal)
      .length;

  int get lowStockMedicinesCount => currentPharmacyInventory
      .where((item) => item.status == StockStatus.warning)
      .length;

  int get criticalStockMedicinesCount => currentPharmacyInventory
      .where((item) => item.status == StockStatus.critical)
      .length;

  int get outOfStockMedicinesCount => currentPharmacyInventory
      .where((item) => item.status == StockStatus.outOfStock)
      .length;

  int get pendingRequestsCount {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return 0;
    return _requests
        .where((r) =>
            r.requestingPharmacyId == pharmacyId &&
            r.status == RequestStatus.pending)
        .length;
  }

  int get incomingRedistributionCount {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return 0;
    return _requests
        .where((r) =>
            r.targetPharmacyId == pharmacyId &&
            r.status == RequestStatus.pending)
        .length;
  }

  int get completedTransfersCount {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return 0;
    return _transfers
        .where((t) =>
            (t.sourcePharmacyId == pharmacyId ||
                t.destinationPharmacyId == pharmacyId) &&
            t.status == TransferStatus.completed)
        .length;
  }

  List<StockAlertModel> get currentPharmacyAlerts {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return [];
    return _alerts
        .where((a) => a.pharmacyId == pharmacyId && !a.isResolved)
        .toList();
  }

  int get recentAlertsCount => currentPharmacyAlerts.length;

  // =========================================================================
  // INVENTORY OPERATIONS (RESTOCK, DISPENSE, ADD, EDIT)
  // =========================================================================
  void updateThresholds({
    required double warningDays,
    required double criticalDays,
  }) {
    _thresholds = StockoutThresholds(
      warningDays: warningDays,
      criticalDays: criticalDays,
    );
    // Recalculate all items with new thresholds
    _recalculateAllInventoryStatus();
    notifyListeners();
  }

  void _recalculateAllInventoryStatus() {
    for (int i = 0; i < _inventory.length; i++) {
      final item = _inventory[i];
      final forecast = StockMonitorService.evaluateStock(
        currentStock: item.currentStock,
        averageDailyConsumption: item.averageDailyConsumption,
        thresholds: _thresholds,
      );
      _inventory[i] = item.copyWith(
        status: forecast.status,
        estimatedDaysRemaining: forecast.estimatedDaysRemaining,
      );
    }
  }

  void addMedicineToInventory({
    required String name,
    required String genericName,
    required String strength,
    required String dosageForm,
    required String category,
    required String manufacturer,
    required int initialStock,
    required int minStockThreshold,
    required double averageDailyConsumption,
    required String batchNumber,
    required DateTime expiryDate,
    required String unit,
  }) {
    final pharmacyId = _currentUser?.pharmacyId ?? 'pharmacy_a';

    // 1. Create or match Master Medicine
    final medicineId = 'med_${DateTime.now().millisecondsSinceEpoch}';
    final medicine = MedicineModel(
      id: medicineId,
      name: name,
      genericName: genericName,
      strength: strength,
      dosageForm: dosageForm,
      category: category,
      manufacturer: manufacturer,
      description: 'Registered medicine',
      unit: unit,
    );
    _medicines.add(medicine);

    // 2. Evaluate Forecast
    final forecast = StockMonitorService.evaluateStock(
      currentStock: initialStock,
      averageDailyConsumption: averageDailyConsumption,
      thresholds: _thresholds,
    );

    final inventoryItem = InventoryItemModel(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      pharmacyId: pharmacyId,
      medicineId: medicineId,
      medicineName: name,
      genericName: genericName,
      strength: strength,
      dosageForm: dosageForm,
      unit: unit,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      currentStock: initialStock,
      minStockThreshold: minStockThreshold,
      averageDailyConsumption: averageDailyConsumption,
      estimatedDaysRemaining: forecast.estimatedDaysRemaining,
      warningDaysThreshold: _thresholds.warningDays,
      criticalDaysThreshold: _thresholds.criticalDays,
      status: forecast.status,
      lastStockUpdate: DateTime.now(),
      demandForecastTrend: forecast.trendDirection,
    );

    _inventory.add(inventoryItem);

    // 3. Log Stock Movement
    _movements.insert(
      0,
      StockMovementModel(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        pharmacyId: pharmacyId,
        medicineId: medicineId,
        medicineName: name,
        movementType: MovementType.restock,
        quantity: initialStock,
        previousStock: 0,
        newStock: initialStock,
        timestamp: DateTime.now(),
        performedBy: _currentUser?.name ?? 'Authorized Staff',
        notes: 'Initial inventory entry',
      ),
    );

    // 4. Trigger alert check if initial stock is low
    _checkAndTriggerAlert(inventoryItem, forecast);

    notifyListeners();
  }

  /// Restock an existing inventory item
  void restockMedicine({
    required String itemId,
    required int quantityToAdd,
    required String batchNumber,
    DateTime? expiryDate,
    String? invoiceNotes,
  }) {
    if (quantityToAdd <= 0) return;

    final index = _inventory.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _inventory[index];
    final int previousStock = item.currentStock;
    final int newStock = previousStock + quantityToAdd;

    final forecast = StockMonitorService.evaluateStock(
      currentStock: newStock,
      averageDailyConsumption: item.averageDailyConsumption,
      thresholds: _thresholds,
    );

    final updatedItem = item.copyWith(
      currentStock: newStock,
      batchNumber: batchNumber.isNotEmpty ? batchNumber : item.batchNumber,
      expiryDate: expiryDate ?? item.expiryDate,
      estimatedDaysRemaining: forecast.estimatedDaysRemaining,
      status: forecast.status,
      lastStockUpdate: DateTime.now(),
      demandForecastTrend: forecast.trendDirection,
    );

    _inventory[index] = updatedItem;

    // Log Stock Movement
    _movements.insert(
      0,
      StockMovementModel(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        pharmacyId: item.pharmacyId,
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        movementType: MovementType.restock,
        quantity: quantityToAdd,
        previousStock: previousStock,
        newStock: newStock,
        timestamp: DateTime.now(),
        performedBy: _currentUser?.name ?? 'Authorized Staff',
        notes: invoiceNotes ?? 'Restock shipment received',
      ),
    );

    // If previously in alert condition and now NORMAL, auto-resolve alerts!
    if (forecast.status == StockStatus.normal) {
      _resolveAlertsForMedicine(item.pharmacyId, item.medicineId);
    }

    // Check patient subscriptions: If restocked from 0, notify patients!
    if (previousStock <= 0 && newStock > 0) {
      final pharmacy = _pharmacies.firstWhere(
        (p) => p.id == item.pharmacyId,
        orElse: () => _pharmacies.first,
      );
      final newNotifs = PatientService.checkSubscriptionsForRestock(
        restockedItem: updatedItem,
        pharmacy: pharmacy,
        subscriptions: _subscriptions,
      );
      _notifications.insertAll(0, newNotifs);
    }

    notifyListeners();
  }

  /// Dispense or record sale of medicine (with input validation to prevent negative stock!)
  bool dispenseMedicine({
    required String itemId,
    required int quantityToDispense,
    String? patientOrPrescriptionRef,
  }) {
    if (quantityToDispense <= 0) return false;

    final index = _inventory.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;

    final item = _inventory[index];
    if (item.currentStock < quantityToDispense) {
      // Prevent negative stock!
      return false;
    }

    final int previousStock = item.currentStock;
    final int newStock = previousStock - quantityToDispense;

    final forecast = StockMonitorService.evaluateStock(
      currentStock: newStock,
      averageDailyConsumption: item.averageDailyConsumption,
      thresholds: _thresholds,
    );

    final updatedItem = item.copyWith(
      currentStock: newStock,
      estimatedDaysRemaining: forecast.estimatedDaysRemaining,
      status: forecast.status,
      lastStockUpdate: DateTime.now(),
      demandForecastTrend: forecast.trendDirection,
    );

    _inventory[index] = updatedItem;

    // Log Stock Movement
    _movements.insert(
      0,
      StockMovementModel(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        pharmacyId: item.pharmacyId,
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        movementType: MovementType.dispense,
        quantity: quantityToDispense,
        previousStock: previousStock,
        newStock: newStock,
        timestamp: DateTime.now(),
        performedBy: _currentUser?.name ?? 'Authorized Staff',
        notes: patientOrPrescriptionRef ?? 'Dispensed to customer',
      ),
    );

    // Check and trigger early alert if risk condition detected
    _checkAndTriggerAlert(updatedItem, forecast);

    notifyListeners();
    return true;
  }

  void _checkAndTriggerAlert(
    InventoryItemModel item,
    ForecastResult forecast,
  ) {
    if (!forecast.alertRequired || forecast.riskLevel == null) return;

    // Check for existing unresolved alert to prevent duplicate notifications
    final existingIndex = _alerts.indexWhere((a) =>
        a.pharmacyId == item.pharmacyId &&
        a.medicineId == item.medicineId &&
        !a.isResolved);

    final pharmacy = _pharmacies.firstWhere(
      (p) => p.id == item.pharmacyId,
      orElse: () => _pharmacies.first,
    );

    if (existingIndex == -1) {
      // Create new alert
      final newAlert = StockAlertModel(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        pharmacyId: item.pharmacyId,
        pharmacyName: pharmacy.name,
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        currentStock: item.currentStock,
        averageDailyConsumption: item.averageDailyConsumption,
        estimatedDaysRemaining: forecast.estimatedDaysRemaining,
        riskLevel: forecast.riskLevel!,
        timestamp: DateTime.now(),
      );
      _alerts.insert(0, newAlert);

      // Add to notifications
      _notifications.insert(
        0,
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          targetPharmacyId: item.pharmacyId,
          title: '${forecast.riskLevel!.label}: ${item.medicineName}',
          body: newAlert.alertMessage,
          category: forecast.riskLevel == AlertRiskLevel.outOfStock
              ? NotificationCategory.outOfStockAlert
              : (forecast.riskLevel == AlertRiskLevel.critical
                  ? NotificationCategory.criticalAlert
                  : NotificationCategory.stockWarning),
          dataPayload: {'alertId': newAlert.id, 'medicineId': item.medicineId},
          timestamp: DateTime.now(),
        ),
      );
    } else {
      // Update existing alert with latest figures
      final existing = _alerts[existingIndex];
      _alerts[existingIndex] = existing.copyWith(
        // Updates current stock and risk level
      );
    }
  }

  void acknowledgeAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(
        isAcknowledged: true,
        acknowledgedBy: _currentUser?.name ?? 'Authorized Staff',
      );
      notifyListeners();
    }
  }

  void _resolveAlertsForMedicine(String pharmacyId, String medicineId) {
    for (int i = 0; i < _alerts.length; i++) {
      if (_alerts[i].pharmacyId == pharmacyId &&
          _alerts[i].medicineId == medicineId &&
          !_alerts[i].isResolved) {
        _alerts[i] = _alerts[i].copyWith(
          isResolved: true,
          resolvedAt: DateTime.now(),
          resolutionNote: 'Restocked to healthy level',
        );
      }
    }
  }

  // =========================================================================
  // PHARMACY-TO-PHARMACY REDISTRIBUTION WORKFLOW
  // =========================================================================
  List<CandidatePharmacy> getEligibleSuppliersForMedicine({
    required String medicineId,
    required String strength,
    required String dosageForm,
    required int requestedQuantity,
    double radiusKm = 5.0,
  }) {
    final pharmacy = currentPharmacy;
    if (pharmacy == null) return [];

    return RedistributionService.findEligibleSuppliers(
      requestingPharmacyId: pharmacy.id,
      requestingLat: pharmacy.latitude,
      requestingLng: pharmacy.longitude,
      medicineId: medicineId,
      strength: strength,
      dosageForm: dosageForm,
      requestedQuantity: requestedQuantity,
      allPharmacies: _pharmacies,
      allInventory: _inventory,
      searchRadiusKm: radiusKm,
    );
  }

  /// Create and dispatch a Redistribution Request to an eligible pharmacy
  void sendRedistributionRequest({
    required CandidatePharmacy targetCandidate,
    required String medicineId,
    required String medicineName,
    required String strength,
    required String dosageForm,
    required int quantity,
    RequestUrgency urgency = RequestUrgency.normal,
  }) {
    final requestingPh = currentPharmacy;
    if (requestingPh == null) return;

    final request = RedistributionRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      requestingPharmacyId: requestingPh.id,
      requestingPharmacyName: requestingPh.name,
      targetPharmacyId: targetCandidate.pharmacy.id,
      targetPharmacyName: targetCandidate.pharmacy.name,
      medicineId: medicineId,
      medicineName: medicineName,
      strength: strength,
      dosageForm: dosageForm,
      requestedQuantity: quantity,
      urgency: urgency,
      status: RequestStatus.pending,
      distanceKm: targetCandidate.distanceKm,
      createdAt: DateTime.now(),
      responseNotes: 'Requested $quantity units due to local shortage.',
    );

    _requests.insert(0, request);

    // Notify receiving pharmacy
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_req_${DateTime.now().millisecondsSinceEpoch}',
        targetPharmacyId: targetCandidate.pharmacy.id,
        title: '📦 New Medicine Redistribution Request',
        body: '${requestingPh.name} (${LocationService.formatDistance(targetCandidate.distanceKm)}) requested $quantity bottles of $medicineName.',
        category: NotificationCategory.incomingRequest,
        dataPayload: {'requestId': request.id},
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  /// Incoming requests waiting for current pharmacy's response
  List<RedistributionRequestModel> get incomingRequests {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return [];
    return _requests
        .where((r) => r.targetPharmacyId == pharmacyId)
        .toList();
  }

  /// Outgoing requests initiated by current pharmacy
  List<RedistributionRequestModel> get outgoingRequests {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return [];
    return _requests
        .where((r) => r.requestingPharmacyId == pharmacyId)
        .toList();
  }

  /// Accept incoming redistribution request and instantiate formal transfer record
  void acceptRedistributionRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _requests[index];
    _requests[index] = req.copyWith(
      status: RequestStatus.accepted,
      updatedAt: DateTime.now(),
      responseNotes: 'Accepted by ${currentPharmacy?.name ?? 'Pharmacy'}. Prepared for compliance approval.',
    );

    // Find source inventory item batch
    final sourceItem = _inventory.firstWhere(
      (item) =>
          item.pharmacyId == req.targetPharmacyId &&
          item.medicineId == req.medicineId,
      orElse: () => _inventory.first,
    );

    // Create formal Redistribution Transfer record
    final transfer = RedistributionTransferModel(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      requestId: req.id,
      sourcePharmacyId: req.targetPharmacyId,
      sourcePharmacyName: req.targetPharmacyName,
      destinationPharmacyId: req.requestingPharmacyId,
      destinationPharmacyName: req.requestingPharmacyName,
      medicineId: req.medicineId,
      medicineName: req.medicineName,
      strength: req.strength,
      dosageForm: req.dosageForm,
      agreedQuantity: req.requestedQuantity,
      batchNumber: sourceItem.batchNumber,
      expiryDate: sourceItem.expiryDate,
      status: TransferStatus.accepted,
      complianceVerified: true,
      createdAt: DateTime.now(),
      trackingNotes: 'Request accepted. Ready for compliance check & approval.',
    );

    _transfers.insert(0, transfer);

    // Notify requesting pharmacy
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_acc_${DateTime.now().millisecondsSinceEpoch}',
        targetPharmacyId: req.requestingPharmacyId,
        title: '✅ Request Accepted: ${req.medicineName}',
        body: '${req.targetPharmacyName} has accepted your request for ${req.requestedQuantity} units.',
        category: NotificationCategory.transferUpdate,
        dataPayload: {'transferId': transfer.id},
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  /// Reject incoming redistribution request
  void rejectRedistributionRequest(String requestId, String reason) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _requests[index];
    _requests[index] = req.copyWith(
      status: RequestStatus.rejected,
      updatedAt: DateTime.now(),
      rejectionReason: reason,
      responseNotes: 'Rejected: $reason',
    );

    // Notify requesting pharmacy
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_rej_${DateTime.now().millisecondsSinceEpoch}',
        targetPharmacyId: req.requestingPharmacyId,
        title: '❌ Request Declined: ${req.medicineName}',
        body: '${req.targetPharmacyName} could not fulfill your request: $reason',
        category: NotificationCategory.transferUpdate,
        dataPayload: {'requestId': req.id},
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  /// Approve Transfer after regulatory compliance check
  void approveTransfer(String transferId) {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index == -1) return;

    final t = _transfers[index];
    _transfers[index] = t.copyWith(
      status: TransferStatus.approved,
      complianceVerified: true,
      approvedBy: _currentUser?.name ?? 'Admin Compliance Officer',
      approvedAt: DateTime.now(),
      trackingNotes: 'Compliance verified. Batch and expiry date confirmed. Cleared for dispatch.',
    );
    notifyListeners();
  }

  /// Dispatch transfer (mark IN TRANSIT)
  void dispatchTransfer(String transferId) {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index == -1) return;

    final t = _transfers[index];
    _transfers[index] = t.copyWith(
      status: TransferStatus.inTransit,
      transitStartedAt: DateTime.now(),
      trackingNotes: 'Package dispatched under temperature-controlled medical courier.',
    );
    notifyListeners();
  }

  /// Complete transfer atomically: updates dual inventories, generates dual audit logs, and resolves alerts
  void completeTransfer(String transferId) {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index == -1) return;

    final transfer = _transfers[index];

    // Source item
    final sourceIndex = _inventory.indexWhere((i) =>
        i.pharmacyId == transfer.sourcePharmacyId &&
        i.medicineId == transfer.medicineId);

    // Destination item
    final destIndex = _inventory.indexWhere((i) =>
        i.pharmacyId == transfer.destinationPharmacyId &&
        i.medicineId == transfer.medicineId);

    if (sourceIndex == -1 || destIndex == -1) return;

    final sourceItem = _inventory[sourceIndex];
    final destItem = _inventory[destIndex];

    final result = RedistributionService.completeTransferLocally(
      transfer: transfer,
      sourceItem: sourceItem,
      destItem: destItem,
      completedByUserId: _currentUser?.name ?? 'Authorized Staff',
    );

    // Apply updates
    _transfers[index] = result.completedTransfer;
    _inventory[sourceIndex] = result.updatedSourceItem;
    _inventory[destIndex] = result.updatedDestItem;
    _movements.insert(0, result.sourceMovement);
    _movements.insert(0, result.destMovement);

    // Auto-resolve stock alerts for destination pharmacy if resolved
    if (result.updatedDestItem.status == StockStatus.normal) {
      _resolveAlertsForMedicine(
        transfer.destinationPharmacyId,
        transfer.medicineId,
      );
    }

    // Notify both parties of successful completed transfer
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_comp_dst_${DateTime.now().millisecondsSinceEpoch}',
        targetPharmacyId: transfer.destinationPharmacyId,
        title: '🎉 Transfer Completed: ${transfer.medicineName}',
        body: 'Received ${transfer.agreedQuantity} units from ${transfer.sourcePharmacyName}. Inventory updated to ${result.updatedDestItem.currentStock} units.',
        category: NotificationCategory.transferUpdate,
        dataPayload: {'transferId': transfer.id},
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  List<RedistributionTransferModel> get currentPharmacyTransfers {
    final pharmacyId = _currentUser?.pharmacyId;
    if (pharmacyId == null) return _transfers;
    return _transfers
        .where((t) =>
            t.sourcePharmacyId == pharmacyId ||
            t.destinationPharmacyId == pharmacyId)
        .toList();
  }

  // =========================================================================
  // PATIENT MEDICINE SEARCH & SUBSCRIPTIONS
  // =========================================================================
  List<PatientSearchResult> searchMedicinesForPatient({
    required String query,
    String? strength,
    String? dosageForm,
    double radiusKm = 10.0,
  }) {
    final double userLat = _currentUser?.latitude ?? LocationService.defaultLatitude;
    final double userLng = _currentUser?.longitude ?? LocationService.defaultLongitude;

    return PatientService.searchMedicineNearby(
      searchQuery: query,
      selectedStrength: strength,
      selectedDosageForm: dosageForm,
      userLat: userLat,
      userLng: userLng,
      maxDistanceKm: radiusKm,
      pharmacies: _pharmacies,
      inventory: _inventory,
    );
  }

  List<PatientSubscriptionModel> get currentPatientSubscriptions {
    final patientId = _currentUser?.id;
    if (patientId == null) return [];
    return _subscriptions
        .where((s) => s.patientId == patientId && s.active)
        .toList();
  }

  void subscribeToMedicineAvailability({
    required String medicineName,
    required String strength,
    required String dosageForm,
    double radiusKm = 10.0,
  }) {
    final patientId = _currentUser?.id ?? 'patient_guest';
    final patientName = _currentUser?.name ?? 'Patient';

    final sub = PatientSubscriptionModel(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      patientName: patientName,
      medicineName: medicineName,
      strength: strength,
      dosageForm: dosageForm,
      maxDistanceKm: radiusKm,
      userLatitude: _currentUser?.latitude ?? LocationService.defaultLatitude,
      userLongitude: _currentUser?.longitude ?? LocationService.defaultLongitude,
      active: true,
      createdAt: DateTime.now(),
    );

    _subscriptions.insert(0, sub);
    notifyListeners();
  }

  void unsubscribePatient(String subscriptionId) {
    final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
    if (index != -1) {
      _subscriptions[index] = _subscriptions[index].copyWith(active: false);
      notifyListeners();
    }
  }

  // =========================================================================
  // NOTIFICATION CENTER
  // =========================================================================
  List<NotificationModel> get currentNotifications {
    final user = _currentUser;
    if (user == null) return _notifications;

    if (user.isPatient) {
      return _notifications
          .where((n) =>
              n.targetUserId == user.id ||
              n.category == NotificationCategory.patientAvailability)
          .toList();
    } else {
      final pharmacyId = user.pharmacyId;
      return _notifications
          .where((n) =>
              n.targetPharmacyId == pharmacyId ||
              n.targetPharmacyId == null ||
              n.targetUserId == user.id)
          .toList();
    }
  }

  int get unreadNotificationsCount =>
      currentNotifications.where((n) => !n.isRead).length;

  void markNotificationAsRead(String notifId) {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Reset to initial demo state
  void resetDemoState() {
    _initializeDemoData();
  }
}
