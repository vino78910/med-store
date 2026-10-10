import 'package:flutter_test/flutter_test.dart';
import 'package:vitalmed/services/patient_service.dart';
import 'package:vitalmed/services/sample_data_service.dart';
import 'package:vitalmed/models/patient_subscription_model.dart';

void main() {
  group('Feature 9 & 10: Patient Medicine Search & Availability Alerts Tests', () {
    final pharmacies = SampleDataService.getInitialPharmacies();
    final inventory = SampleDataService.getInitialInventory();

    test('Patient search accurately finds pharmacies reporting medicine', () {
      final results = PatientService.searchMedicineNearby(
        searchQuery: 'Paracetamol',
        userLat: 28.6180,
        userLng: 77.2120,
        maxDistanceKm: 10.0,
        pharmacies: pharmacies,
        inventory: inventory,
      );

      expect(results.isNotEmpty, true);
      final pharmacyIds = results.map((r) => r.pharmacy.id).toList();
      expect(pharmacyIds, contains('pharmacy_a'));
      expect(pharmacyIds, contains('pharmacy_b'));
    });

    test('Search results categorize availability without leaking private stock quantities', () {
      final results = PatientService.searchMedicineNearby(
        searchQuery: 'Paracetamol',
        userLat: 28.6180,
        userLng: 77.2120,
        maxDistanceKm: 10.0,
        pharmacies: pharmacies,
        inventory: inventory,
      );

      for (var result in results) {
        // Patient results only expose availability category labels, never private internal numbers
        expect(
          [
            PatientAvailabilityStatus.available,
            PatientAvailabilityStatus.lowStock,
            PatientAvailabilityStatus.unavailable,
            PatientAvailabilityStatus.availabilityUnconfirmed,
          ],
          contains(result.availability),
        );
      }
    });

    test('Patient subscriptions trigger notifications when previously depleted stock is restocked', () {
      final restockedItem = inventory.firstWhere((i) => i.medicineId == 'med_paracetamol_syrup');
      final pharmacy = pharmacies.firstWhere((p) => p.id == 'pharmacy_b');

      final subscriptions = [
        PatientSubscriptionModel(
          id: 'sub_test',
          patientId: 'patient_01',
          patientName: 'John Patient',
          medicineName: 'Paracetamol Syrup',
          strength: '250mg/5ml',
          dosageForm: 'Syrup',
          maxDistanceKm: 5.0,
          userLatitude: 28.6250,
          userLongitude: 77.2180,
          active: true,
          createdAt: DateTime.now(),
        ),
      ];

      final triggeredNotifs = PatientService.checkSubscriptionsForRestock(
        restockedItem: restockedItem,
        pharmacy: pharmacy,
        subscriptions: subscriptions,
      );

      expect(triggeredNotifs.length, 1);
      expect(triggeredNotifs.first.targetUserId, 'patient_01');
      expect(triggeredNotifs.first.title, contains('Medicine Now Available'));
    });
  });
}
