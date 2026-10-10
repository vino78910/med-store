enum StockStatus {
  normal,
  warning,
  critical,
  outOfStock;

  static StockStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'WARNING':
        return StockStatus.warning;
      case 'CRITICAL':
        return StockStatus.critical;
      case 'OUT OF STOCK':
      case 'OUTOFSTOCK':
        return StockStatus.outOfStock;
      case 'NORMAL':
      default:
        return StockStatus.normal;
    }
  }

  String get label {
    switch (this) {
      case StockStatus.normal:
        return 'NORMAL';
      case StockStatus.warning:
        return 'WARNING';
      case StockStatus.critical:
        return 'CRITICAL';
      case StockStatus.outOfStock:
        return 'OUT OF STOCK';
    }
  }
}

class InventoryItemModel {
  final String id;
  final String pharmacyId;
  final String medicineId;
  final String medicineName;
  final String genericName;
  final String strength;
  final String dosageForm;
  final String unit;
  final String batchNumber;
  final DateTime expiryDate;
  final int currentStock;
  final int minStockThreshold;
  final double averageDailyConsumption;
  final double estimatedDaysRemaining;
  final double warningDaysThreshold;
  final double criticalDaysThreshold;
  final StockStatus status;
  final DateTime lastStockUpdate;
  final String demandForecastTrend; // 'STABLE', 'INCREASING', 'DECREASING'
  final double? aiPredictedDemand7d;

  InventoryItemModel({
    required this.id,
    required this.pharmacyId,
    required this.medicineId,
    required this.medicineName,
    required this.genericName,
    required this.strength,
    required this.dosageForm,
    this.unit = 'units',
    required this.batchNumber,
    required this.expiryDate,
    required this.currentStock,
    this.minStockThreshold = 15,
    this.averageDailyConsumption = 2.0,
    required this.estimatedDaysRemaining,
    this.warningDaysThreshold = 3.0,
    this.criticalDaysThreshold = 1.0,
    required this.status,
    required this.lastStockUpdate,
    this.demandForecastTrend = 'STABLE',
    this.aiPredictedDemand7d,
  });

  /// Calculate surplus stock that can be safely shared with nearby pharmacies
  /// Surplus = Current Stock - (Minimum Threshold + 2-Day Buffer Demand)
  int get surplusStock {
    final int safeReserve = (minStockThreshold + (averageDailyConsumption * 2).ceil());
    final int surplus = currentStock - safeReserve;
    return surplus > 0 ? surplus : 0;
  }

  bool canSupplyQuantity(int requestedQty) {
    return surplusStock >= requestedQty;
  }

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isExpiringSoon =>
      expiryDate.isBefore(DateTime.now().add(const Duration(days: 90)));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'genericName': genericName,
      'strength': strength,
      'dosageForm': dosageForm,
      'unit': unit,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'currentStock': currentStock,
      'minStockThreshold': minStockThreshold,
      'averageDailyConsumption': averageDailyConsumption,
      'estimatedDaysRemaining': estimatedDaysRemaining,
      'warningDaysThreshold': warningDaysThreshold,
      'criticalDaysThreshold': criticalDaysThreshold,
      'status': status.label,
      'lastStockUpdate': lastStockUpdate.toIso8601String(),
      'demandForecastTrend': demandForecastTrend,
      'aiPredictedDemand7d': aiPredictedDemand7d,
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItemModel(
      id: id,
      pharmacyId: map['pharmacyId'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      genericName: map['genericName'] ?? '',
      strength: map['strength'] ?? '',
      dosageForm: map['dosageForm'] ?? 'Tablet',
      unit: map['unit'] ?? 'units',
      batchNumber: map['batchNumber'] ?? 'BATCH-001',
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate']) ??
              DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      currentStock: (map['currentStock'] as num?)?.toInt() ?? 0,
      minStockThreshold: (map['minStockThreshold'] as num?)?.toInt() ?? 15,
      averageDailyConsumption:
          (map['averageDailyConsumption'] as num?)?.toDouble() ?? 1.0,
      estimatedDaysRemaining:
          (map['estimatedDaysRemaining'] as num?)?.toDouble() ?? 999.0,
      warningDaysThreshold:
          (map['warningDaysThreshold'] as num?)?.toDouble() ?? 3.0,
      criticalDaysThreshold:
          (map['criticalDaysThreshold'] as num?)?.toDouble() ?? 1.0,
      status: StockStatus.fromString(map['status'] ?? 'NORMAL'),
      lastStockUpdate: map['lastStockUpdate'] != null
          ? DateTime.tryParse(map['lastStockUpdate']) ?? DateTime.now()
          : DateTime.now(),
      demandForecastTrend: map['demandForecastTrend'] ?? 'STABLE',
      aiPredictedDemand7d: (map['aiPredictedDemand7d'] as num?)?.toDouble(),
    );
  }

  InventoryItemModel copyWith({
    int? currentStock,
    int? minStockThreshold,
    double? averageDailyConsumption,
    double? estimatedDaysRemaining,
    double? warningDaysThreshold,
    double? criticalDaysThreshold,
    StockStatus? status,
    DateTime? lastStockUpdate,
    String? batchNumber,
    DateTime? expiryDate,
    String? demandForecastTrend,
    double? aiPredictedDemand7d,
  }) {
    return InventoryItemModel(
      id: id,
      pharmacyId: pharmacyId,
      medicineId: medicineId,
      medicineName: medicineName,
      genericName: genericName,
      strength: strength,
      dosageForm: dosageForm,
      unit: unit,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      currentStock: currentStock ?? this.currentStock,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      averageDailyConsumption:
          averageDailyConsumption ?? this.averageDailyConsumption,
      estimatedDaysRemaining:
          estimatedDaysRemaining ?? this.estimatedDaysRemaining,
      warningDaysThreshold: warningDaysThreshold ?? this.warningDaysThreshold,
      criticalDaysThreshold:
          criticalDaysThreshold ?? this.criticalDaysThreshold,
      status: status ?? this.status,
      lastStockUpdate: lastStockUpdate ?? this.lastStockUpdate,
      demandForecastTrend: demandForecastTrend ?? this.demandForecastTrend,
      aiPredictedDemand7d: aiPredictedDemand7d ?? this.aiPredictedDemand7d,
    );
  }
}
