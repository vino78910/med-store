enum MovementType {
  restock,
  dispense,
  transferIn,
  transferOut,
  adjustment;

  static MovementType fromString(String val) {
    switch (val.toUpperCase()) {
      case 'RESTOCK':
        return MovementType.restock;
      case 'DISPENSE':
        return MovementType.dispense;
      case 'TRANSFER_IN':
      case 'TRANSFERIN':
        return MovementType.transferIn;
      case 'TRANSFER_OUT':
      case 'TRANSFEROUT':
        return MovementType.transferOut;
      case 'ADJUSTMENT':
      default:
        return MovementType.adjustment;
    }
  }

  String get label {
    switch (this) {
      case MovementType.restock:
        return 'RESTOCK';
      case MovementType.dispense:
        return 'DISPENSE';
      case MovementType.transferIn:
        return 'TRANSFER IN';
      case MovementType.transferOut:
        return 'TRANSFER OUT';
      case MovementType.adjustment:
        return 'ADJUSTMENT';
    }
  }

  bool get isPositive =>
      this == MovementType.restock || this == MovementType.transferIn;
}

class StockMovementModel {
  final String id;
  final String pharmacyId;
  final String medicineId;
  final String medicineName;
  final MovementType movementType;
  final int quantity;
  final int previousStock;
  final int newStock;
  final DateTime timestamp;
  final String performedBy;
  final String? referenceId;
  final String notes;

  StockMovementModel({
    required this.id,
    required this.pharmacyId,
    required this.medicineId,
    required this.medicineName,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.timestamp,
    required this.performedBy,
    this.referenceId,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'movementType': movementType.label,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'referenceId': referenceId,
      'notes': notes,
    };
  }

  factory StockMovementModel.fromMap(Map<String, dynamic> map, String id) {
    return StockMovementModel(
      id: id,
      pharmacyId: map['pharmacyId'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      movementType: MovementType.fromString(map['movementType'] ?? 'ADJUSTMENT'),
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      previousStock: (map['previousStock'] as num?)?.toInt() ?? 0,
      newStock: (map['newStock'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      performedBy: map['performedBy'] ?? 'Staff',
      referenceId: map['referenceId'],
      notes: map['notes'] ?? '',
    );
  }
}
