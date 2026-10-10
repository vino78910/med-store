import 'package:flutter_test/flutter_test.dart';
import 'package:vitalmed/services/redistribution_service.dart';
import 'package:vitalmed/services/location_service.dart';
import 'package:vitalmed/services/sample_data_service.dart';

void main() {
  group('Feature 7 & 8: Nearby Pharmacy Matching & Redistribution Tests', () {
    final pharmacies = SampleDataService.getInitialPharmacies();
    final inventory = SampleDataService.getInitialInventory();

    test('Haversine distance calculation produces accurate real-world distance', () {
      // Distance between Pharmacy A (Apex Care) and Pharmacy B (Metro Cure)
      final distance = LocationService.calculateDistanceKm(
        startLatitude: 28.6145,
        startLongitude: 77.2095,
        endLatitude: 28.6250,
        endLongitude: 77.2180,
      );

      expect(distance, greaterThan(1.0));
      expect(distance, lessThan(2.0)); // Approx 1.45 km
    });

    test('Redistribution excludes the requesting pharmacy itself', () {
      final candidates = RedistributionService.findEligibleSuppliers(
        requestingPharmacyId: 'pharmacy_a',
        requestingLat: 28.6145,
        requestingLng: 77.2095,
        medicineId: 'med_paracetamol_syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        requestedQuantity: 20,
        allPharmacies: pharmacies,
        allInventory: inventory,
        searchRadiusKm: 5.0,
      );

      final containsSelf = candidates.any((c) => c.pharmacy.id == 'pharmacy_a');
      expect(containsSelf, false);
    });

    test('Candidate B with surplus is identified as ELIGIBLE', () {
      final candidates = RedistributionService.findEligibleSuppliers(
        requestingPharmacyId: 'pharmacy_a',
        requestingLat: 28.6145,
        requestingLng: 77.2095,
        medicineId: 'med_paracetamol_syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        requestedQuantity: 20,
        allPharmacies: pharmacies,
        allInventory: inventory,
        searchRadiusKm: 5.0,
      );

      final metroCure = candidates.firstWhere((c) => c.pharmacy.id == 'pharmacy_b');
      expect(metroCure.isEligible, true);
      expect(metroCure.surplusStock, greaterThanOrEqualTo(20));
      expect(metroCure.eligibilityReason, contains('Eligible'));
    });

    test('Candidate C with insufficient reserve is marked INELIGIBLE (Never creates source shortage)', () {
      final candidates = RedistributionService.findEligibleSuppliers(
        requestingPharmacyId: 'pharmacy_a',
        requestingLat: 28.6145,
        requestingLng: 77.2095,
        medicineId: 'med_paracetamol_syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        requestedQuantity: 20,
        allPharmacies: pharmacies,
        allInventory: inventory,
        searchRadiusKm: 5.0,
      );

      final greenCross = candidates.firstWhere((c) => c.pharmacy.id == 'pharmacy_c');
      // Pharmacy C only has 15 in stock, with min reserve 20 => surplus is 0
      expect(greenCross.isEligible, false);
      expect(greenCross.surplusStock, 0);
      expect(greenCross.eligibilityReason, contains('Insufficient surplus'));
    });

    test('Eligible suppliers are ranked above ineligible suppliers', () {
      final candidates = RedistributionService.findEligibleSuppliers(
        requestingPharmacyId: 'pharmacy_a',
        requestingLat: 28.6145,
        requestingLng: 77.2095,
        medicineId: 'med_paracetamol_syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        requestedQuantity: 20,
        allPharmacies: pharmacies,
        allInventory: inventory,
        searchRadiusKm: 5.0,
      );

      expect(candidates.first.pharmacy.id, 'pharmacy_b');
      expect(candidates.first.isEligible, true);
    });
  });
}
