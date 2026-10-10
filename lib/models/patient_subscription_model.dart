class PatientSubscriptionModel {
  final String id;
  final String patientId;
  final String patientName;
  final String medicineName;
  final String? genericName;
  final String strength;
  final String dosageForm;
  final double maxDistanceKm;
  final double? userLatitude;
  final double? userLongitude;
  final bool active;
  final DateTime createdAt;
  final int notifiedCount;
  final DateTime? lastNotifiedAt;

  PatientSubscriptionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.medicineName,
    this.genericName,
    required this.strength,
    required this.dosageForm,
    this.maxDistanceKm = 10.0,
    this.userLatitude,
    this.userLongitude,
    this.active = true,
    required this.createdAt,
    this.notifiedCount = 0,
    this.lastNotifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'medicineName': medicineName,
      'genericName': genericName,
      'strength': strength,
      'dosageForm': dosageForm,
      'maxDistanceKm': maxDistanceKm,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'notifiedCount': notifiedCount,
      'lastNotifiedAt': lastNotifiedAt?.toIso8601String(),
    };
  }

  factory PatientSubscriptionModel.fromMap(
      Map<String, dynamic> map, String id) {
    return PatientSubscriptionModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      medicineName: map['medicineName'] ?? '',
      genericName: map['genericName'],
      strength: map['strength'] ?? '',
      dosageForm: map['dosageForm'] ?? 'Tablet',
      maxDistanceKm: (map['maxDistanceKm'] as num?)?.toDouble() ?? 10.0,
      userLatitude: (map['userLatitude'] as num?)?.toDouble(),
      userLongitude: (map['userLongitude'] as num?)?.toDouble(),
      active: map['active'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      notifiedCount: (map['notifiedCount'] as num?)?.toInt() ?? 0,
      lastNotifiedAt: map['lastNotifiedAt'] != null
          ? DateTime.tryParse(map['lastNotifiedAt'])
          : null,
    );
  }

  PatientSubscriptionModel copyWith({
    bool? active,
    int? notifiedCount,
    DateTime? lastNotifiedAt,
  }) {
    return PatientSubscriptionModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      medicineName: medicineName,
      genericName: genericName,
      strength: strength,
      dosageForm: dosageForm,
      maxDistanceKm: maxDistanceKm,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      active: active ?? this.active,
      createdAt: createdAt,
      notifiedCount: notifiedCount ?? this.notifiedCount,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
    );
  }
}
