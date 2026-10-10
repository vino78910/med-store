class MedicineModel {
  final String id;
  final String name;
  final String genericName;
  final String strength;
  final String dosageForm;
  final String category;
  final String manufacturer;
  final String description;
  final bool isPrescriptionRequired;
  final String unit;

  MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.strength,
    required this.dosageForm,
    required this.category,
    required this.manufacturer,
    required this.description,
    this.isPrescriptionRequired = false,
    this.unit = 'units',
  });

  String get fullDisplayName => '$name ($strength, $dosageForm)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'strength': strength,
      'dosageForm': dosageForm,
      'category': category,
      'manufacturer': manufacturer,
      'description': description,
      'isPrescriptionRequired': isPrescriptionRequired,
      'unit': unit,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      id: id,
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      strength: map['strength'] ?? '',
      dosageForm: map['dosageForm'] ?? 'Tablet',
      category: map['category'] ?? 'General',
      manufacturer: map['manufacturer'] ?? '',
      description: map['description'] ?? '',
      isPrescriptionRequired: map['isPrescriptionRequired'] ?? false,
      unit: map['unit'] ?? 'units',
    );
  }
}
