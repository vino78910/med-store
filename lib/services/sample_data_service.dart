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

class SampleDataService {
  static List<PharmacyModel> getInitialPharmacies() {
    return [
      PharmacyModel(
        id: 'pharmacy_a',
        name: '[SAMPLE DATA] Apex Care Pharmacy',
        address: '12 Health Boulevard, Sector 14, Central District',
        latitude: 28.6145,
        longitude: 77.2095,
        phone: '+91 98765 43210',
        email: 'contact@apexcare.sample.com',
        operatingHours: '8:00 AM - 11:00 PM',
        licenseNumber: 'DL-APEX-2024-091',
        isVerified: true,
        rating: 4.9,
      ),
      PharmacyModel(
        id: 'pharmacy_b',
        name: '[SAMPLE DATA] Metro Cure Pharmacy',
        address: '88 Central Avenue, Market Complex, North Wing',
        latitude: 28.6250,
        longitude: 77.2180,
        phone: '+91 98111 22334',
        email: 'support@metrocure.sample.com',
        operatingHours: '24 Hours Open (Emergency Care)',
        licenseNumber: 'DL-METRO-2023-412',
        isVerified: true,
        rating: 4.8,
      ),
      PharmacyModel(
        id: 'pharmacy_c',
        name: '[SAMPLE DATA] GreenCross Chemist',
        address: '45 Riverside Colony, Block B',
        latitude: 28.6320,
        longitude: 77.2250,
        phone: '+91 98222 33445',
        email: 'info@greencross.sample.com',
        operatingHours: '9:00 AM - 9:30 PM',
        licenseNumber: 'DL-GCROSS-2022-817',
        isVerified: true,
        rating: 4.6,
      ),
    ];
  }

  static List<MedicineModel> getInitialMedicines() {
    return [
      MedicineModel(
        id: 'med_paracetamol_syrup',
        name: 'Paracetamol Syrup',
        genericName: 'Acetaminophen Oral Suspension',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        category: 'Analgesic / Antipyretic',
        manufacturer: 'Cipla Healthcare Ltd',
        description: 'Fever reduction and mild-to-moderate pain relief for pediatric patients.',
        isPrescriptionRequired: false,
        unit: 'bottles',
      ),
      MedicineModel(
        id: 'med_amoxicillin_susp',
        name: 'Amoxicillin Oral Suspension',
        genericName: 'Amoxicillin Trihydrate',
        strength: '125mg/5ml',
        dosageForm: 'Suspension',
        category: 'Antibacterial',
        manufacturer: 'GlaxoSmithKline',
        description: 'Broad-spectrum antibiotic for pediatric ear, throat, and respiratory infections.',
        isPrescriptionRequired: true,
        unit: 'bottles',
      ),
      MedicineModel(
        id: 'med_metformin_500',
        name: 'Metformin HCl',
        genericName: 'Metformin Hydrochloride',
        strength: '500mg',
        dosageForm: 'Tablet',
        category: 'Antidiabetic',
        manufacturer: 'Sun Pharmaceutical',
        description: 'First-line medication for the treatment of type 2 diabetes mellitus.',
        isPrescriptionRequired: true,
        unit: 'strips',
      ),
      MedicineModel(
        id: 'med_salbutamol_inhaler',
        name: 'Salbutamol Inhaler',
        genericName: 'Albuterol / Salbutamol',
        strength: '100mcg',
        dosageForm: 'Inhaler',
        category: 'Bronchodilator',
        manufacturer: 'Lupin Pharmaceuticals',
        description: 'Rapid relief for acute bronchospasm and chronic asthma symptoms.',
        isPrescriptionRequired: true,
        unit: 'inhalers',
      ),
      MedicineModel(
        id: 'med_azithromycin_500',
        name: 'Azithromycin Tablets',
        genericName: 'Azithromycin Dihydrate',
        strength: '500mg',
        dosageForm: 'Tablet',
        category: 'Macrolide Antibiotic',
        manufacturer: 'Pfizer Bio',
        description: 'Antibiotic for bacterial respiratory infections, sinusitis, and bronchitis.',
        isPrescriptionRequired: true,
        unit: 'strips',
      ),
    ];
  }

  static List<InventoryItemModel> getInitialInventory() {
    final now = DateTime.now();

    return [
      // Pharmacy A (Shortage on Paracetamol Syrup: 10 bottles left, 5/day consumption -> 2 days remaining -> WARNING)
      InventoryItemModel(
        id: 'inv_a_paracetamol',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        genericName: 'Acetaminophen Oral Suspension',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        unit: 'bottles',
        batchNumber: 'PARA-2024-B1',
        expiryDate: now.add(const Duration(days: 280)),
        currentStock: 10,
        minStockThreshold: 25,
        averageDailyConsumption: 5.0,
        estimatedDaysRemaining: 2.0,
        status: StockStatus.warning,
        lastStockUpdate: now.subtract(const Duration(minutes: 25)),
        demandForecastTrend: 'INCREASING',
        aiPredictedDemand7d: 38.5,
      ),
      InventoryItemModel(
        id: 'inv_a_amoxicillin',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_amoxicillin_susp',
        medicineName: 'Amoxicillin Oral Suspension',
        genericName: 'Amoxicillin Trihydrate',
        strength: '125mg/5ml',
        dosageForm: 'Suspension',
        unit: 'bottles',
        batchNumber: 'AMOX-2024-C3',
        expiryDate: now.add(const Duration(days: 340)),
        currentStock: 45,
        minStockThreshold: 20,
        averageDailyConsumption: 2.5,
        estimatedDaysRemaining: 18.0,
        status: StockStatus.normal,
        lastStockUpdate: now.subtract(const Duration(hours: 3)),
        demandForecastTrend: 'STABLE',
        aiPredictedDemand7d: 17.5,
      ),
      InventoryItemModel(
        id: 'inv_a_salbutamol',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_salbutamol_inhaler',
        medicineName: 'Salbutamol Inhaler',
        genericName: 'Albuterol / Salbutamol',
        strength: '100mcg',
        dosageForm: 'Inhaler',
        unit: 'inhalers',
        batchNumber: 'SALB-2024-X9',
        expiryDate: now.add(const Duration(days: 410)),
        currentStock: 2,
        minStockThreshold: 10,
        averageDailyConsumption: 2.0,
        estimatedDaysRemaining: 1.0,
        status: StockStatus.critical,
        lastStockUpdate: now.subtract(const Duration(hours: 1)),
        demandForecastTrend: 'STABLE',
        aiPredictedDemand7d: 14.0,
      ),
      InventoryItemModel(
        id: 'inv_a_azithromycin',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_azithromycin_500',
        medicineName: 'Azithromycin Tablets',
        genericName: 'Azithromycin Dihydrate',
        strength: '500mg',
        dosageForm: 'Tablet',
        unit: 'strips',
        batchNumber: 'AZI-2024-Z2',
        expiryDate: now.add(const Duration(days: 200)),
        currentStock: 0,
        minStockThreshold: 15,
        averageDailyConsumption: 3.0,
        estimatedDaysRemaining: 0.0,
        status: StockStatus.outOfStock,
        lastStockUpdate: now.subtract(const Duration(hours: 5)),
        demandForecastTrend: 'INCREASING',
        aiPredictedDemand7d: 22.0,
      ),

      // Pharmacy B (Surplus on Paracetamol Syrup: 120 bottles! Safe surplus = 92)
      InventoryItemModel(
        id: 'inv_b_paracetamol',
        pharmacyId: 'pharmacy_b',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        genericName: 'Acetaminophen Oral Suspension',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        unit: 'bottles',
        batchNumber: 'PARA-2024-B9',
        expiryDate: now.add(const Duration(days: 350)),
        currentStock: 120,
        minStockThreshold: 20,
        averageDailyConsumption: 4.0,
        estimatedDaysRemaining: 30.0,
        status: StockStatus.normal,
        lastStockUpdate: now.subtract(const Duration(minutes: 40)),
        demandForecastTrend: 'STABLE',
        aiPredictedDemand7d: 28.0,
      ),
      InventoryItemModel(
        id: 'inv_b_azithromycin',
        pharmacyId: 'pharmacy_b',
        medicineId: 'med_azithromycin_500',
        medicineName: 'Azithromycin Tablets',
        genericName: 'Azithromycin Dihydrate',
        strength: '500mg',
        dosageForm: 'Tablet',
        unit: 'strips',
        batchNumber: 'AZI-2024-M1',
        expiryDate: now.add(const Duration(days: 310)),
        currentStock: 65,
        minStockThreshold: 15,
        averageDailyConsumption: 3.0,
        estimatedDaysRemaining: 21.7,
        status: StockStatus.normal,
        lastStockUpdate: now.subtract(const Duration(hours: 2)),
        demandForecastTrend: 'STABLE',
        aiPredictedDemand7d: 21.0,
      ),

      // Pharmacy C (Insufficient Paracetamol: only 15 bottles with reserve 20 -> INELIGIBLE to supply)
      InventoryItemModel(
        id: 'inv_c_paracetamol',
        pharmacyId: 'pharmacy_c',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        genericName: 'Acetaminophen Oral Suspension',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        unit: 'bottles',
        batchNumber: 'PARA-2024-C5',
        expiryDate: now.add(const Duration(days: 190)),
        currentStock: 15,
        minStockThreshold: 20,
        averageDailyConsumption: 3.0,
        estimatedDaysRemaining: 5.0,
        status: StockStatus.normal,
        lastStockUpdate: now.subtract(const Duration(hours: 6)),
        demandForecastTrend: 'STABLE',
        aiPredictedDemand7d: 21.0,
      ),
    ];
  }

  static List<StockAlertModel> getInitialAlerts() {
    final now = DateTime.now();
    return [
      StockAlertModel(
        id: 'alert_a_paracetamol',
        pharmacyId: 'pharmacy_a',
        pharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        currentStock: 10,
        averageDailyConsumption: 5.0,
        estimatedDaysRemaining: 2.0,
        riskLevel: AlertRiskLevel.warning,
        timestamp: now.subtract(const Duration(minutes: 25)),
        isAcknowledged: false,
        isResolved: false,
      ),
      StockAlertModel(
        id: 'alert_a_salbutamol',
        pharmacyId: 'pharmacy_a',
        pharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
        medicineId: 'med_salbutamol_inhaler',
        medicineName: 'Salbutamol Inhaler',
        currentStock: 2,
        averageDailyConsumption: 2.0,
        estimatedDaysRemaining: 1.0,
        riskLevel: AlertRiskLevel.critical,
        timestamp: now.subtract(const Duration(hours: 1)),
        isAcknowledged: true,
        isResolved: false,
        acknowledgedBy: 'Dr. Sarah Jenkins',
      ),
      StockAlertModel(
        id: 'alert_a_azithromycin',
        pharmacyId: 'pharmacy_a',
        pharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
        medicineId: 'med_azithromycin_500',
        medicineName: 'Azithromycin Tablets',
        currentStock: 0,
        averageDailyConsumption: 3.0,
        estimatedDaysRemaining: 0.0,
        riskLevel: AlertRiskLevel.outOfStock,
        timestamp: now.subtract(const Duration(hours: 5)),
        isAcknowledged: false,
        isResolved: false,
      ),
    ];
  }

  static List<StockMovementModel> getInitialMovements() {
    final now = DateTime.now();
    return [
      StockMovementModel(
        id: 'sm_001',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        movementType: MovementType.dispense,
        quantity: 5,
        previousStock: 15,
        newStock: 10,
        timestamp: now.subtract(const Duration(minutes: 25)),
        performedBy: 'Sarah Pharmacist',
        notes: 'Pediatric outpatient dispensing - 5 units',
      ),
      StockMovementModel(
        id: 'sm_002',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_amoxicillin_susp',
        medicineName: 'Amoxicillin Oral Suspension',
        movementType: MovementType.restock,
        quantity: 30,
        previousStock: 15,
        newStock: 45,
        timestamp: now.subtract(const Duration(days: 2)),
        performedBy: 'Admin Michael',
        referenceId: 'PO-2024-9182',
        notes: 'Routine supplier delivery received from Cipla distributor',
      ),
    ];
  }

  static List<RedistributionRequestModel> getInitialRequests() {
    final now = DateTime.now();
    return [
      RedistributionRequestModel(
        id: 'req_demo_01',
        requestingPharmacyId: 'pharmacy_a',
        requestingPharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
        targetPharmacyId: 'pharmacy_b',
        targetPharmacyName: '[SAMPLE DATA] Metro Cure Pharmacy',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        requestedQuantity: 20,
        urgency: RequestUrgency.urgent,
        status: RequestStatus.pending,
        distanceKm: 1.5,
        createdAt: now.subtract(const Duration(minutes: 15)),
        responseNotes: 'Urgent stockout expected in 2 days. Requesting 20 bottles from surplus.',
      ),
    ];
  }

  static List<RedistributionTransferModel> getInitialTransfers() {
    final now = DateTime.now();
    return [
      RedistributionTransferModel(
        id: 'transfer_hist_01',
        requestId: 'req_hist_past',
        sourcePharmacyId: 'pharmacy_b',
        sourcePharmacyName: '[SAMPLE DATA] Metro Cure Pharmacy',
        destinationPharmacyId: 'pharmacy_a',
        destinationPharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
        medicineId: 'med_metformin_500',
        medicineName: 'Metformin HCl',
        strength: '500mg',
        dosageForm: 'Tablet',
        agreedQuantity: 50,
        batchNumber: 'MET-TRANS-90',
        expiryDate: now.add(const Duration(days: 240)),
        status: TransferStatus.completed,
        complianceVerified: true,
        approvedBy: 'Compliance Lead Dr. Roy',
        approvedAt: now.subtract(const Duration(days: 4)),
        transitStartedAt: now.subtract(const Duration(days: 4, hours: 2)),
        completedAt: now.subtract(const Duration(days: 4)),
        trackingNotes: 'Verified intact tamper seals and valid cold-chain / room-temp protocol.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<PatientSubscriptionModel> getInitialSubscriptions() {
    final now = DateTime.now();
    return [
      PatientSubscriptionModel(
        id: 'sub_jane_01',
        patientId: 'patient_jane',
        patientName: 'Jane Doe (Patient)',
        medicineName: 'Paracetamol Syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        maxDistanceKm: 5.0,
        userLatitude: 28.6180,
        userLongitude: 77.2120,
        active: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<NotificationModel> getInitialNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_001',
        targetPharmacyId: 'pharmacy_a',
        title: '⚠️ Early Stock Warning: Paracetamol Syrup',
        body: 'Paracetamol Syrup may run out in 2.0 days. Current stock: 10 bottles. Tap to redistribute.',
        category: NotificationCategory.stockWarning,
        dataPayload: {'medicineId': 'med_paracetamol_syrup'},
        timestamp: now.subtract(const Duration(minutes: 25)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif_002',
        targetPharmacyId: 'pharmacy_b',
        title: '📦 Incoming Redistribution Request: Paracetamol Syrup',
        body: 'Apex Care Pharmacy (1.5 km away) needs 20 bottles. Your pharmacy has 92 surplus bottles.',
        category: NotificationCategory.incomingRequest,
        dataPayload: {'requestId': 'req_demo_01'},
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
    ];
  }

  static UserModel getSamplePharmacyAdmin() {
    return UserModel(
      id: 'admin_michael',
      email: 'admin@apexcare.sample.com',
      name: 'Michael Vance (Pharmacy Admin)',
      role: UserRole.pharmacyAdmin,
      pharmacyId: 'pharmacy_a',
      pharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
      phoneNumber: '+91 98765 43210',
      latitude: 28.6145,
      longitude: 77.2095,
      address: '12 Health Boulevard, Sector 14',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  static UserModel getSamplePharmacist() {
    return UserModel(
      id: 'pharmacist_sarah',
      email: 'sarah@apexcare.sample.com',
      name: 'Sarah Jenkins (Pharmacist)',
      role: UserRole.pharmacist,
      pharmacyId: 'pharmacy_a',
      pharmacyName: '[SAMPLE DATA] Apex Care Pharmacy',
      phoneNumber: '+91 98765 43211',
      latitude: 28.6145,
      longitude: 77.2095,
      address: '12 Health Boulevard, Sector 14',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );
  }

  static UserModel getSamplePatient() {
    return UserModel(
      id: 'patient_jane',
      email: 'jane.doe@sample.com',
      name: 'Jane Doe (Patient)',
      role: UserRole.patient,
      phoneNumber: '+91 98111 55667',
      latitude: 28.6180,
      longitude: 77.2120,
      address: 'Apartment 4B, Metro Green Enclave',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
  }
}
