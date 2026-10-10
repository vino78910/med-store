import '../lib/services/stock_monitor_service.dart';
import '../lib/services/redistribution_service.dart';
import '../lib/services/patient_service.dart';
import '../lib/services/sample_data_service.dart';
import '../lib/services/location_service.dart';
import '../lib/models/inventory_item_model.dart';
import '../lib/models/stock_alert_model.dart';
import '../lib/models/redistribution_transfer_model.dart';
import '../lib/models/patient_subscription_model.dart';

int passedTests = 0;
int failedTests = 0;

void expect(dynamic actual, dynamic expected, String testName) {
  if (actual == expected) {
    passedTests++;
    // ignore: avoid_print
    print('  [PASS] $testName');
  } else {
    failedTests++;
    // ignore: avoid_print
    print('  [FAIL] $testName: expected $expected, got $actual');
  }
}

void expectTrue(bool condition, String testName) {
  expect(condition, true, testName);
}

void expectGreaterThan(num actual, num threshold, String testName) {
  if (actual > threshold) {
    passedTests++;
    // ignore: avoid_print
    print('  [PASS] $testName ($actual > $threshold)');
  } else {
    failedTests++;
    // ignore: avoid_print
    print('  [FAIL] $testName: expected $actual > $threshold');
  }
}

void main() {
  // ignore: avoid_print
  print('=================================================================');
  // ignore: avoid_print
  print('VitalMed - Full End-to-End Core Business Logic Test Suite');
  // ignore: avoid_print
  print('=================================================================\n');

  // -------------------------------------------------------------------
  // TEST SUITE 1: FEATURE 4 & 5 (STOCKOUT PREDICTION & EARLY ALERTS)
  // -------------------------------------------------------------------
  // ignore: avoid_print
  print('SUITE 1: Feature 5 - Stockout Prediction & Early Alerts');
  const thresholds = StockoutThresholds(warningDays: 3.0, criticalDays: 1.0);

  // 1. Formula: Days Remaining = Available Stock / Average Daily Burn
  // Paracetamol: 10 bottles / 5 per day = 2.0 days remaining -> WARNING!
  final res1 = StockMonitorService.evaluateStock(
    currentStock: 10,
    averageDailyConsumption: 5.0,
    thresholds: thresholds,
  );
  expect(res1.estimatedDaysRemaining, 2.0, 'Paracetamol Syrup: 10 bottles / 5 per day = 2.0 days');
  expect(res1.status, StockStatus.warning, 'Status is WARNING (<= 3 days)');
  expect(res1.riskLevel, AlertRiskLevel.warning, 'Risk level is WARNING');
  expectTrue(res1.alertRequired, 'Alert is required for WARNING stock');

  // 2. Critical Alert: Salbutamol Inhaler (2 units / 2 per day = 1.0 day -> CRITICAL)
  final res2 = StockMonitorService.evaluateStock(
    currentStock: 2,
    averageDailyConsumption: 2.0,
    thresholds: thresholds,
  );
  expect(res2.estimatedDaysRemaining, 1.0, 'Salbutamol: 2 units / 2 per day = 1.0 day');
  expect(res2.status, StockStatus.critical, 'Status is CRITICAL (<= 1 day)');
  expect(res2.riskLevel, AlertRiskLevel.critical, 'Risk level is CRITICAL');

  // 3. Out of stock: 0 units
  final res3 = StockMonitorService.evaluateStock(
    currentStock: 0,
    averageDailyConsumption: 3.0,
    thresholds: thresholds,
  );
  expect(res3.estimatedDaysRemaining, 0.0, 'Out of stock = 0.0 days remaining');
  expect(res3.status, StockStatus.outOfStock, 'Status is OUT OF STOCK');

  // 4. Healthy stock level
  final res4 = StockMonitorService.evaluateStock(
    currentStock: 100,
    averageDailyConsumption: 2.0,
    thresholds: thresholds,
  );
  expect(res4.estimatedDaysRemaining, 50.0, 'Healthy stock: 100 units / 2 per day = 50 days');
  expect(res4.status, StockStatus.normal, 'Status is NORMAL');
  expectTrue(!res4.alertRequired, 'No alert required for healthy stock');

  // 5. Zero consumption safety
  final res5 = StockMonitorService.evaluateStock(
    currentStock: 25,
    averageDailyConsumption: 0.0,
    thresholds: thresholds,
  );
  expect(res5.estimatedDaysRemaining, 999.0, 'Safe zero consumption handling: 999.0 days');
  expect(res5.status, StockStatus.normal, 'Zero burn status remains NORMAL');

  // 6. AI Demand Forecasting regression
  final history = [2, 2, 3, 4, 5, 6, 8];
  final res6 = StockMonitorService.evaluateStock(
    currentStock: 30,
    averageDailyConsumption: 4.5,
    thresholds: thresholds,
    historicalDailyConsumption: history,
  );
  expect(res6.trendDirection, 'INCREASING', 'AI Trend velocity is INCREASING');
  expect(res6.modelType, 'AI-Powered Weighted Trend Model', 'Uses AI Weighted Trend Model');
  expectGreaterThan(res6.confidenceScore, 0.5, 'AI confidence score exceeds 50%');

  // -------------------------------------------------------------------
  // TEST SUITE 2: FEATURE 7 & 8 (NEARBY PHARMACY MATCHING & SURPLUS)
  // -------------------------------------------------------------------
  // ignore: avoid_print
  print('\nSUITE 2: Feature 7 & 8 - Nearby Matching & Shortage Protection Invariant');
  final pharmacies = SampleDataService.getInitialPharmacies();
  final inventory = SampleDataService.getInitialInventory();

  // Haversine distance
  final dist = LocationService.calculateDistanceKm(
    startLatitude: 28.6145,
    startLongitude: 77.2095,
    endLatitude: 28.6250,
    endLongitude: 77.2180,
  );
  expectGreaterThan(dist, 1.0, 'Haversine distance between Pharmacy A & B is > 1.0 km');

  // Exclude self
  final candidates = RedistributionService.findEligibleSuppliers(
    requestingPharmacyId: 'pharmacy_a',
    requestingLat: 28.6145,
    requestingLng: 77.2095,
    medicineId: 'med_paracetamol_syrup',
    strength: '250mg/5ml',
    dosageForm: 'Syrup',
    requestedQuantity: 20,
    allPharmacies: pharmacies,
    allInventory: inventory,
    searchRadiusKm: 5.0,
  );
  expectTrue(!candidates.any((c) => c.pharmacy.id == 'pharmacy_a'), 'Requesting pharmacy is excluded from suppliers');

  // Candidate B (Metro Cure): Surplus = 120 - (20 + 8) = 92 -> ELIGIBLE
  final metroCure = candidates.firstWhere((c) => c.pharmacy.id == 'pharmacy_b');
  expectTrue(metroCure.isEligible, 'Metro Cure Pharmacy is ELIGIBLE');
  expectGreaterThan(metroCure.surplusStock, 20, 'Metro Cure surplus > 20 requested bottles');

  // Candidate C (GreenCross): Stock = 15, Reserve = 20 -> Surplus = 0 -> INELIGIBLE (Never creates source shortage!)
  final greenCross = candidates.firstWhere((c) => c.pharmacy.id == 'pharmacy_c');
  expectTrue(!greenCross.isEligible, 'GreenCross is INELIGIBLE (protection against secondary shortage)');
  expect(greenCross.surplusStock, 0, 'GreenCross safe surplus is 0');

  // -------------------------------------------------------------------
  // TEST SUITE 3: FEATURE 8 (ATOMIC DUAL-INVENTORY TRANSFER COMPLETION)
  // -------------------------------------------------------------------
  // ignore: avoid_print
  print('\nSUITE 3: Feature 8 - Atomic Dual-Inventory Transfer Execution');
  final now = DateTime.now();
  final sourceItem = InventoryItemModel(
    id: 'inv_b', pharmacyId: 'pharmacy_b', medicineId: 'med_p', medicineName: 'Paracetamol Syrup',
    genericName: 'Acetaminophen', strength: '250mg/5ml', dosageForm: 'Syrup', batchNumber: 'B9',
    expiryDate: now.add(const Duration(days: 300)), currentStock: 120, minStockThreshold: 20,
    averageDailyConsumption: 4.0, estimatedDaysRemaining: 30.0, status: StockStatus.normal,
    lastStockUpdate: now,
  );
  final destItem = InventoryItemModel(
    id: 'inv_a', pharmacyId: 'pharmacy_a', medicineId: 'med_p', medicineName: 'Paracetamol Syrup',
    genericName: 'Acetaminophen', strength: '250mg/5ml', dosageForm: 'Syrup', batchNumber: 'B1',
    expiryDate: now.add(const Duration(days: 200)), currentStock: 10, minStockThreshold: 25,
    averageDailyConsumption: 5.0, estimatedDaysRemaining: 2.0, status: StockStatus.warning,
    lastStockUpdate: now,
  );
  final transfer = RedistributionTransferModel(
    id: 'trans_demo', requestId: 'req_01', sourcePharmacyId: 'pharmacy_b',
    sourcePharmacyName: 'Metro Cure', destinationPharmacyId: 'pharmacy_a',
    destinationPharmacyName: 'Apex Care', medicineId: 'med_p', medicineName: 'Paracetamol Syrup',
    strength: '250mg/5ml', dosageForm: 'Syrup', agreedQuantity: 20, batchNumber: 'B9',
    expiryDate: now.add(const Duration(days: 300)), status: TransferStatus.approved,
    createdAt: now,
  );

  final transferResult = RedistributionService.completeTransferLocally(
    transfer: transfer,
    sourceItem: sourceItem,
    destItem: destItem,
    completedByUserId: 'Chief Pharmacist',
  );
  expect(transferResult.updatedSourceItem.currentStock, 100, 'Source stock decremented by 20 (120 -> 100)');
  expect(transferResult.updatedDestItem.currentStock, 30, 'Destination stock incremented by 20 (10 -> 30)');
  expect(transferResult.updatedDestItem.estimatedDaysRemaining, 6.0, 'Destination days remaining recalculated to 6.0 days');
  expect(transferResult.updatedDestItem.status, StockStatus.normal, 'Destination status restored from WARNING to NORMAL!');
  expect(transferResult.completedTransfer.status, TransferStatus.completed, 'Transfer status transitioned to COMPLETED');
  expect(transferResult.sourceMovement.movementType.label, 'TRANSFER OUT', 'Source logged TRANSFER OUT');
  expect(transferResult.destMovement.movementType.label, 'TRANSFER IN', 'Destination logged TRANSFER IN');

  // -------------------------------------------------------------------
  // TEST SUITE 4: FEATURE 9 & 10 (PATIENT SEARCH & PRIVACY PRESERVATION)
  // -------------------------------------------------------------------
  // ignore: avoid_print
  print('\nSUITE 4: Feature 9 & 10 - Patient Search & Privacy Shield');
  final searchResults = PatientService.searchMedicineNearby(
    searchQuery: 'Paracetamol',
    userLat: 28.6180,
    userLng: 77.2120,
    maxDistanceKm: 10.0,
    pharmacies: pharmacies,
    inventory: inventory,
  );
  expectGreaterThan(searchResults.length, 0, 'Found pharmacies reporting Paracetamol');

  // Verify Privacy Preservation: only categories, no exact internal count exposed
  bool allHaveCategories = searchResults.every((r) => [
    PatientAvailabilityStatus.available,
    PatientAvailabilityStatus.lowStock,
    PatientAvailabilityStatus.unavailable,
    PatientAvailabilityStatus.availabilityUnconfirmed,
  ].contains(r.availability));
  expectTrue(allHaveCategories, 'All results use privacy categories (never leaks private wholesale counts)');

  // Patient restock notification matching
  final patientSubs = [
    PatientSubscriptionModel(
      id: 'sub_test', patientId: 'patient_01', patientName: 'John Patient',
      medicineName: 'Paracetamol Syrup', strength: '250mg/5ml', dosageForm: 'Syrup',
      maxDistanceKm: 5.0, userLatitude: 28.6250, userLongitude: 77.2180,
      active: true, createdAt: DateTime.now(),
    ),
  ];
  final notifs = PatientService.checkSubscriptionsForRestock(
    restockedItem: transferResult.updatedDestItem,
    pharmacy: pharmacies.firstWhere((p) => p.id == 'pharmacy_a'),
    subscriptions: patientSubs,
  );
  expect(notifs.length, 1, 'Restock notification triggered for subscribed patient');
  expect(notifs.first.targetUserId, 'patient_01', 'Target patient ID matches subscription');

  // Summary
  // ignore: avoid_print
  print('\n=================================================================');
  // ignore: avoid_print
  print('TEST SUMMARY: $passedTests passed, $failedTests failed');
  // ignore: avoid_print
  print('=================================================================');
}
