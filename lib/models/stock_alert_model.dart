enum AlertRiskLevel {
  warning,
  critical,
  outOfStock;

  static AlertRiskLevel fromString(String val) {
    switch (val.toUpperCase()) {
      case 'CRITICAL':
        return AlertRiskLevel.critical;
      case 'OUT OF STOCK':
      case 'OUTOFSTOCK':
        return AlertRiskLevel.outOfStock;
      case 'WARNING':
      default:
        return AlertRiskLevel.warning;
    }
  }

  String get label {
    switch (this) {
      case AlertRiskLevel.warning:
        return 'WARNING';
      case AlertRiskLevel.critical:
        return 'CRITICAL';
      case AlertRiskLevel.outOfStock:
        return 'OUT OF STOCK';
    }
  }
}

class StockAlertModel {
  final String id;
  final String pharmacyId;
  final String pharmacyName;
  final String medicineId;
  final String medicineName;
  final int currentStock;
  final double averageDailyConsumption;
  final double estimatedDaysRemaining;
  final AlertRiskLevel riskLevel;
  final DateTime timestamp;
  final bool isAcknowledged;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? acknowledgedBy;
  final String? resolutionNote;

  StockAlertModel({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.medicineId,
    required this.medicineName,
    required this.currentStock,
    required this.averageDailyConsumption,
    required this.estimatedDaysRemaining,
    required this.riskLevel,
    required this.timestamp,
    this.isAcknowledged = false,
    this.isResolved = false,
    this.resolvedAt,
    this.acknowledgedBy,
    this.resolutionNote,
  });

  String get alertMessage {
    if (riskLevel == AlertRiskLevel.outOfStock) {
      return '$medicineName is completely OUT OF STOCK! Immediate redistribution or order required.';
    }
    return '${riskLevel.label}: $medicineName may run out in ${estimatedDaysRemaining.toStringAsFixed(1)} days. Current stock: $currentStock units.';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'currentStock': currentStock,
      'averageDailyConsumption': averageDailyConsumption,
      'estimatedDaysRemaining': estimatedDaysRemaining,
      'riskLevel': riskLevel.label,
      'timestamp': timestamp.toIso8601String(),
      'isAcknowledged': isAcknowledged,
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'acknowledgedBy': acknowledgedBy,
      'resolutionNote': resolutionNote,
    };
  }

  factory StockAlertModel.fromMap(Map<String, dynamic> map, String id) {
    return StockAlertModel(
      id: id,
      pharmacyId: map['pharmacyId'] ?? '',
      pharmacyName: map['pharmacyName'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      currentStock: (map['currentStock'] as num?)?.toInt() ?? 0,
      averageDailyConsumption:
          (map['averageDailyConsumption'] as num?)?.toDouble() ?? 1.0,
      estimatedDaysRemaining:
          (map['estimatedDaysRemaining'] as num?)?.toDouble() ?? 0.0,
      riskLevel: AlertRiskLevel.fromString(map['riskLevel'] ?? 'WARNING'),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isAcknowledged: map['isAcknowledged'] ?? false,
      isResolved: map['isResolved'] ?? false,
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.tryParse(map['resolvedAt'])
          : null,
      acknowledgedBy: map['acknowledgedBy'],
      resolutionNote: map['resolutionNote'],
    );
  }

  StockAlertModel copyWith({
    bool? isAcknowledged,
    bool? isResolved,
    DateTime? resolvedAt,
    String? acknowledgedBy,
    String? resolutionNote,
  }) {
    return StockAlertModel(
      id: id,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      medicineId: medicineId,
      medicineName: medicineName,
      currentStock: currentStock,
      averageDailyConsumption: averageDailyConsumption,
      estimatedDaysRemaining: estimatedDaysRemaining,
      riskLevel: riskLevel,
      timestamp: timestamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }
}
