enum RequestStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  static RequestStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'ACCEPTED':
        return RequestStatus.accepted;
      case 'REJECTED':
        return RequestStatus.rejected;
      case 'CANCELLED':
        return RequestStatus.cancelled;
      case 'PENDING':
      default:
        return RequestStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'PENDING';
      case RequestStatus.accepted:
        return 'ACCEPTED';
      case RequestStatus.rejected:
        return 'REJECTED';
      case RequestStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

enum RequestUrgency {
  normal,
  urgent,
  emergency;

  static RequestUrgency fromString(String val) {
    switch (val.toUpperCase()) {
      case 'URGENT':
        return RequestUrgency.urgent;
      case 'EMERGENCY':
        return RequestUrgency.emergency;
      case 'NORMAL':
      default:
        return RequestUrgency.normal;
    }
  }

  String get label {
    switch (this) {
      case RequestUrgency.normal:
        return 'NORMAL';
      case RequestUrgency.urgent:
        return 'URGENT';
      case RequestUrgency.emergency:
        return 'EMERGENCY';
    }
  }
}

class RedistributionRequestModel {
  final String id;
  final String requestingPharmacyId;
  final String requestingPharmacyName;
  final String targetPharmacyId; // Eligible recipient pharmacy
  final String targetPharmacyName;
  final String medicineId;
  final String medicineName;
  final String strength;
  final String dosageForm;
  final int requestedQuantity;
  final RequestUrgency urgency;
  final RequestStatus status;
  final double distanceKm;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final String? responseNotes;

  RedistributionRequestModel({
    required this.id,
    required this.requestingPharmacyId,
    required this.requestingPharmacyName,
    required this.targetPharmacyId,
    required this.targetPharmacyName,
    required this.medicineId,
    required this.medicineName,
    required this.strength,
    required this.dosageForm,
    required this.requestedQuantity,
    this.urgency = RequestUrgency.normal,
    this.status = RequestStatus.pending,
    this.distanceKm = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.responseNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestingPharmacyId': requestingPharmacyId,
      'requestingPharmacyName': requestingPharmacyName,
      'targetPharmacyId': targetPharmacyId,
      'targetPharmacyName': targetPharmacyName,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'strength': strength,
      'dosageForm': dosageForm,
      'requestedQuantity': requestedQuantity,
      'urgency': urgency.label,
      'status': status.label,
      'distanceKm': distanceKm,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'responseNotes': responseNotes,
    };
  }

  factory RedistributionRequestModel.fromMap(
      Map<String, dynamic> map, String id) {
    return RedistributionRequestModel(
      id: id,
      requestingPharmacyId: map['requestingPharmacyId'] ?? '',
      requestingPharmacyName: map['requestingPharmacyName'] ?? '',
      targetPharmacyId: map['targetPharmacyId'] ?? '',
      targetPharmacyName: map['targetPharmacyName'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      strength: map['strength'] ?? '',
      dosageForm: map['dosageForm'] ?? 'Tablet',
      requestedQuantity: (map['requestedQuantity'] as num?)?.toInt() ?? 0,
      urgency: RequestUrgency.fromString(map['urgency'] ?? 'NORMAL'),
      status: RequestStatus.fromString(map['status'] ?? 'PENDING'),
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      rejectionReason: map['rejectionReason'],
      responseNotes: map['responseNotes'],
    );
  }

  RedistributionRequestModel copyWith({
    RequestStatus? status,
    DateTime? updatedAt,
    String? rejectionReason,
    String? responseNotes,
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
      status: status ?? this.status,
      distanceKm: distanceKm,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      responseNotes: responseNotes ?? this.responseNotes,
    );
  }
}
