enum TransferStatus {
  pending,
  accepted,
  rejected,
  approved,
  inTransit,
  completed,
  cancelled;

  static TransferStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'ACCEPTED':
        return TransferStatus.accepted;
      case 'REJECTED':
        return TransferStatus.rejected;
      case 'APPROVED':
        return TransferStatus.approved;
      case 'IN TRANSIT':
      case 'INTRANSIT':
        return TransferStatus.inTransit;
      case 'COMPLETED':
        return TransferStatus.completed;
      case 'CANCELLED':
        return TransferStatus.cancelled;
      case 'PENDING':
      default:
        return TransferStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case TransferStatus.pending:
        return 'PENDING';
      case TransferStatus.accepted:
        return 'ACCEPTED';
      case TransferStatus.rejected:
        return 'REJECTED';
      case TransferStatus.approved:
        return 'APPROVED';
      case TransferStatus.inTransit:
        return 'IN TRANSIT';
      case TransferStatus.completed:
        return 'COMPLETED';
      case TransferStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

class RedistributionTransferModel {
  final String id;
  final String requestId;
  final String sourcePharmacyId; // Supplying pharmacy
  final String sourcePharmacyName;
  final String destinationPharmacyId; // Requesting pharmacy
  final String destinationPharmacyName;
  final String medicineId;
  final String medicineName;
  final String strength;
  final String dosageForm;
  final int agreedQuantity;
  final String batchNumber;
  final DateTime expiryDate;
  final TransferStatus status;
  final bool complianceVerified;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? transitStartedAt;
  final DateTime? completedAt;
  final String trackingNotes;
  final DateTime createdAt;

  RedistributionTransferModel({
    required this.id,
    required this.requestId,
    required this.sourcePharmacyId,
    required this.sourcePharmacyName,
    required this.destinationPharmacyId,
    required this.destinationPharmacyName,
    required this.medicineId,
    required this.medicineName,
    required this.strength,
    required this.dosageForm,
    required this.agreedQuantity,
    required this.batchNumber,
    required this.expiryDate,
    this.status = TransferStatus.pending,
    this.complianceVerified = true,
    this.approvedBy,
    this.approvedAt,
    this.transitStartedAt,
    this.completedAt,
    this.trackingNotes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'sourcePharmacyId': sourcePharmacyId,
      'sourcePharmacyName': sourcePharmacyName,
      'destinationPharmacyId': destinationPharmacyId,
      'destinationPharmacyName': destinationPharmacyName,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'strength': strength,
      'dosageForm': dosageForm,
      'agreedQuantity': agreedQuantity,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'status': status.label,
      'complianceVerified': complianceVerified,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'transitStartedAt': transitStartedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'trackingNotes': trackingNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RedistributionTransferModel.fromMap(
      Map<String, dynamic> map, String id) {
    return RedistributionTransferModel(
      id: id,
      requestId: map['requestId'] ?? '',
      sourcePharmacyId: map['sourcePharmacyId'] ?? '',
      sourcePharmacyName: map['sourcePharmacyName'] ?? '',
      destinationPharmacyId: map['destinationPharmacyId'] ?? '',
      destinationPharmacyName: map['destinationPharmacyName'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      strength: map['strength'] ?? '',
      dosageForm: map['dosageForm'] ?? 'Tablet',
      agreedQuantity: (map['agreedQuantity'] as num?)?.toInt() ?? 0,
      batchNumber: map['batchNumber'] ?? 'BATCH-TRANSFER',
      expiryDate: map['expiryDate'] != null
          ? DateTime.tryParse(map['expiryDate']) ??
              DateTime.now().add(const Duration(days: 180))
          : DateTime.now().add(const Duration(days: 180)),
      status: TransferStatus.fromString(map['status'] ?? 'PENDING'),
      complianceVerified: map['complianceVerified'] ?? true,
      approvedBy: map['approvedBy'],
      approvedAt:
          map['approvedAt'] != null ? DateTime.tryParse(map['approvedAt']) : null,
      transitStartedAt: map['transitStartedAt'] != null
          ? DateTime.tryParse(map['transitStartedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
      trackingNotes: map['trackingNotes'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  RedistributionTransferModel copyWith({
    TransferStatus? status,
    bool? complianceVerified,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? transitStartedAt,
    DateTime? completedAt,
    String? trackingNotes,
  }) {
    return RedistributionTransferModel(
      id: id,
      requestId: requestId,
      sourcePharmacyId: sourcePharmacyId,
      sourcePharmacyName: sourcePharmacyName,
      destinationPharmacyId: destinationPharmacyId,
      destinationPharmacyName: destinationPharmacyName,
      medicineId: medicineId,
      medicineName: medicineName,
      strength: strength,
      dosageForm: dosageForm,
      agreedQuantity: agreedQuantity,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      status: status ?? this.status,
      complianceVerified: complianceVerified ?? this.complianceVerified,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      transitStartedAt: transitStartedAt ?? this.transitStartedAt,
      completedAt: completedAt ?? this.completedAt,
      trackingNotes: trackingNotes ?? this.trackingNotes,
      createdAt: createdAt,
    );
  }
}
