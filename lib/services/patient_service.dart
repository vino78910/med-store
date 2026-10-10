import '../models/pharmacy_model.dart';
import '../models/inventory_item_model.dart';
import '../models/patient_subscription_model.dart';
import '../models/notification_model.dart';
import 'location_service.dart';

enum PatientAvailabilityStatus {
  available,
  lowStock,
  unavailable,
  availabilityUnconfirmed;

  String get label {
    switch (this) {
      case PatientAvailabilityStatus.available:
        return 'AVAILABLE';
      case PatientAvailabilityStatus.lowStock:
        return 'LOW STOCK';
      case PatientAvailabilityStatus.unavailable:
        return 'UNAVAILABLE';
      case PatientAvailabilityStatus.availabilityUnconfirmed:
        return 'AVAILABILITY UNCONFIRMED';
    }
  }

  String get description {
    switch (this) {
      case PatientAvailabilityStatus.available:
        return 'In stock according to latest reported inventory.';
      case PatientAvailabilityStatus.lowStock:
        return 'Limited availability reported. Call ahead to confirm.';
      case PatientAvailabilityStatus.unavailable:
        return 'Currently reported as unavailable.';
      case PatientAvailabilityStatus.availabilityUnconfirmed:
        return 'Inventory record is older than 48 hours. Please call pharmacy.';
    }
  }
}

class PatientSearchResult {
  final PharmacyModel pharmacy;
  final String medicineName;
  final String strength;
  final String dosageForm;
  final PatientAvailabilityStatus availability;
  final DateTime lastStockUpdate;
  final double distanceKm;
  final String phone;
  final String operatingHours;
  final String address;

  PatientSearchResult({
    required this.pharmacy,
    required this.medicineName,
    required this.strength,
    required this.dosageForm,
    required this.availability,
    required this.lastStockUpdate,
    required this.distanceKm,
    required this.phone,
    required this.operatingHours,
    required this.address,
  });
}

class PatientService {
  /// Search medicines nearby for patients, strictly protecting private wholesale stock counts
  static List<PatientSearchResult> searchMedicineNearby({
    required String searchQuery,
    String? selectedStrength,
    String? selectedDosageForm,
    required double userLat,
    required double userLng,
    double maxDistanceKm = 10.0,
    required List<PharmacyModel> pharmacies,
    required List<InventoryItemModel> inventory,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final List<PatientSearchResult> results = [];

    final pharmacyMap = {for (var p in pharmacies) p.id: p};

    for (final item in inventory) {
      // 1. Medicine query match
      final nameMatches = item.medicineName.toLowerCase().contains(query) ||
          item.genericName.toLowerCase().contains(query);
      if (!nameMatches && query.isNotEmpty) continue;

      // 2. Strength and dosage form filter
      if (selectedStrength != null &&
          selectedStrength.isNotEmpty &&
          item.strength.toLowerCase() != selectedStrength.toLowerCase()) {
        continue;
      }
      if (selectedDosageForm != null &&
          selectedDosageForm.isNotEmpty &&
          item.dosageForm.toLowerCase() != selectedDosageForm.toLowerCase()) {
        continue;
      }

      final pharmacy = pharmacyMap[item.pharmacyId];
      if (pharmacy == null) continue;

      // 3. Distance calculation
      final distance = LocationService.calculateDistanceKm(
        startLatitude: userLat,
        startLongitude: userLng,
        endLatitude: pharmacy.latitude,
        endLongitude: pharmacy.longitude,
      );

      if (distance > maxDistanceKm) continue;

      // 4. Availability status classification (protecting exact counts!)
      final hoursSinceUpdate =
          DateTime.now().difference(item.lastStockUpdate).inHours;
      PatientAvailabilityStatus availability;

      if (hoursSinceUpdate > 48) {
        availability = PatientAvailabilityStatus.availabilityUnconfirmed;
      } else if (item.currentStock <= 0) {
        availability = PatientAvailabilityStatus.unavailable;
      } else if (item.currentStock < 8) {
        availability = PatientAvailabilityStatus.lowStock;
      } else {
        availability = PatientAvailabilityStatus.available;
      }

      results.add(
        PatientSearchResult(
          pharmacy: pharmacy.withDistance(distance),
          medicineName: item.medicineName,
          strength: item.strength,
          dosageForm: item.dosageForm,
          availability: availability,
          lastStockUpdate: item.lastStockUpdate,
          distanceKm: distance,
          phone: pharmacy.phone,
          operatingHours: pharmacy.operatingHours,
          address: pharmacy.address,
        ),
      );
    }

    // Sort: Available first, then closest distance
    results.sort((a, b) {
      if (a.availability == PatientAvailabilityStatus.available &&
          b.availability != PatientAvailabilityStatus.available) {
        return -1;
      }
      if (a.availability != PatientAvailabilityStatus.available &&
          b.availability == PatientAvailabilityStatus.available) {
        return 1;
      }
      return a.distanceKm.compareTo(b.distanceKm);
    });

    return results;
  }

  /// Check patient subscriptions and trigger notifications when restocked
  static List<NotificationModel> checkSubscriptionsForRestock({
    required InventoryItemModel restockedItem,
    required PharmacyModel pharmacy,
    required List<PatientSubscriptionModel> subscriptions,
  }) {
    if (restockedItem.currentStock <= 0) return [];

    final List<NotificationModel> triggeredNotifications = [];

    for (final sub in subscriptions) {
      if (!sub.active) continue;

      final nameMatch = restockedItem.medicineName
          .toLowerCase()
          .contains(sub.medicineName.toLowerCase());
      final strengthMatch = sub.strength.isEmpty ||
          restockedItem.strength.toLowerCase() == sub.strength.toLowerCase();
      final formMatch = sub.dosageForm.isEmpty ||
          restockedItem.dosageForm.toLowerCase() ==
              sub.dosageForm.toLowerCase();

      if (!nameMatch || !strengthMatch || !formMatch) continue;

      // Distance check if patient coordinates are available
      double distance = 1.5;
      if (sub.userLatitude != null && sub.userLongitude != null) {
        distance = LocationService.calculateDistanceKm(
          startLatitude: sub.userLatitude!,
          startLongitude: sub.userLongitude!,
          endLatitude: pharmacy.latitude,
          endLongitude: pharmacy.longitude,
        );
        if (distance > sub.maxDistanceKm) continue;
      }

      final notif = NotificationModel(
        id: 'NOTIF-SUB-${DateTime.now().millisecondsSinceEpoch}-${sub.id}',
        targetUserId: sub.patientId,
        title: 'Medicine Now Available: ${restockedItem.medicineName}',
        body:
            '${restockedItem.medicineName} (${restockedItem.strength}) is now in stock at ${pharmacy.name} (${LocationService.formatDistance(distance)}).',
        category: NotificationCategory.patientAvailability,
        dataPayload: {
          'pharmacyId': pharmacy.id,
          'pharmacyName': pharmacy.name,
          'medicineName': restockedItem.medicineName,
          'phone': pharmacy.phone,
          'address': pharmacy.address,
          'distanceKm': distance,
        },
        timestamp: DateTime.now(),
        isRead: false,
      );

      triggeredNotifications.add(notif);
    }

    return triggeredNotifications;
  }
}
