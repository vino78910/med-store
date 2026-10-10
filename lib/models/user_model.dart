enum UserRole {
  pharmacyAdmin,
  pharmacist,
  patient;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'pharmacyadmin':
      case 'pharmacy_admin':
      case 'admin':
        return UserRole.pharmacyAdmin;
      case 'pharmacist':
        return UserRole.pharmacist;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.pharmacyAdmin:
        return 'Pharmacy Admin';
      case UserRole.pharmacist:
        return 'Pharmacist';
      case UserRole.patient:
        return 'Patient';
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? pharmacyId;
  final String? pharmacyName;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.pharmacyId,
    this.pharmacyName,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.address,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isPharmacyStaff =>
      role == UserRole.pharmacyAdmin || role == UserRole.pharmacist;

  bool get isPharmacyAdmin => role == UserRole.pharmacyAdmin;

  bool get isPatient => role == UserRole.patient;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'patient'),
      pharmacyId: map['pharmacyId'],
      pharmacyName: map['pharmacyName'],
      phoneNumber: map['phoneNumber'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'],
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? name,
    UserRole? role,
    String? pharmacyId,
    String? pharmacyName,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    String? address,
    String? fcmToken,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
