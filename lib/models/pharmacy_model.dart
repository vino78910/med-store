class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String operatingHours;
  final String licenseNumber;
  final bool isVerified;
  final double rating;
  final double? distanceKm; // Computed dynamically for UI distance badges

  PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    required this.operatingHours,
    required this.licenseNumber,
    this.isVerified = true,
    this.rating = 4.8,
    this.distanceKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'operatingHours': operatingHours,
      'licenseNumber': licenseNumber,
      'isVerified': isVerified,
      'rating': rating,
    };
  }

  factory PharmacyModel.fromMap(Map<String, dynamic> map, String id) {
    return PharmacyModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      operatingHours: map['operatingHours'] ?? '8:00 AM - 10:00 PM',
      licenseNumber: map['licenseNumber'] ?? '',
      isVerified: map['isVerified'] ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  PharmacyModel withDistance(double distance) {
    return PharmacyModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
      operatingHours: operatingHours,
      licenseNumber: licenseNumber,
      isVerified: isVerified,
      rating: rating,
      distanceKm: distance,
    );
  }
}
