import 'package:flutter_test/flutter_test.dart';
import 'package:vitalmed/services/redistribution_service.dart';
import 'package:vitalmed/models/inventory_item_model.dart';
import 'package:vitalmed/models/redistribution_transfer_model.dart';

void main() {
  group('Feature 3 & 8: Inventory & Atomic Redistribution Transfer Tests', () {
    test('Atomic transfer completion updates dual inventories and maintains stock invariants', () {
      final now = DateTime.now();

      // Source Pharmacy B with 120 units
      final sourceItem = InventoryItemModel(
        id: 'inv_b_para',
        pharmacyId: 'pharmacy_b',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        genericName: 'Acetaminophen Oral Suspension',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        batchNumber: 'PARA-B9',
        expiryDate: now.add(const Duration(days: 300)),
        currentStock: 120,
        minStockThreshold: 20,
        averageDailyConsumption: 4.0,
        estimatedDaysRemaining: 30.0,
        status: StockStatus.normal,
        lastStockUpdate: now,
      );

      // Destination Pharmacy A with 10 units (WARNING status: 2 days left)
      final destItem = InventoryItemModel(
        id: 'inv_a_para',
        pharmacyId: 'pharmacy_a',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        genericName: 'Acetaminophen Oral Suspension',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        batchNumber: 'PARA-B1',
        expiryDate: now.add(const Duration(days: 200)),
        currentStock: 10,
        minStockThreshold: 25,
        averageDailyConsumption: 5.0,
        estimatedDaysRemaining: 2.0,
        status: StockStatus.warning,
        lastStockUpdate: now,
      );

      // Approved transfer of 20 bottles
      final transfer = RedistributionTransferModel(
        id: 'trans_test_01',
        requestId: 'req_01',
        sourcePharmacyId: 'pharmacy_b',
        sourcePharmacyName: 'Metro Cure Pharmacy',
        destinationPharmacyId: 'pharmacy_a',
        destinationPharmacyName: 'Apex Care Pharmacy',
        medicineId: 'med_paracetamol_syrup',
        medicineName: 'Paracetamol Syrup',
        strength: '250mg/5ml',
        dosageForm: 'Syrup',
        agreedQuantity: 20,
        batchNumber: 'PARA-B9',
        expiryDate: now.add(const Duration(days: 300)),
        status: TransferStatus.approved,
        createdAt: now,
      );

      // Execute Atomic Transfer
      final result = RedistributionService.completeTransferLocally(
        transfer: transfer,
        sourceItem: sourceItem,
        destItem: destItem,
        completedByUserId: 'Chief Pharmacist',
      );

      // 1. Source stock decreased by agreed quantity (120 - 20 = 100)
      expect(result.updatedSourceItem.currentStock, 100);
      expect(result.updatedSourceItem.status, StockStatus.normal);

      // 2. Destination stock increased by agreed quantity (10 + 20 = 30)
      expect(result.updatedDestItem.currentStock, 30);

      // 3. Destination days remaining recalculated (30 / 5.0 = 6.0 days -> NORMAL!)
      expect(result.updatedDestItem.estimatedDaysRemaining, 6.0);
      expect(result.updatedDestItem.status, StockStatus.normal);

      // 4. Transfer status transitioned to COMPLETED
      expect(result.completedTransfer.status, TransferStatus.completed);

      // 5. Dual stock movements logged
      expect(result.sourceMovement.movementType.label, 'TRANSFER OUT');
      expect(result.sourceMovement.quantity, 20);
      expect(result.destMovement.movementType.label, 'TRANSFER IN');
      expect(result.destMovement.quantity, 20);
    });

    test('Prevents transfer completion if source stock is less than agreed quantity', () {
      final now = DateTime.now();
      final lowSourceItem = InventoryItemModel(
        id: 'inv_low',
        pharmacyId: 'p1',
        medicineId: 'm1',
        medicineName: 'Test Med',
        genericName: 'Test Gen',
        strength: '10mg',
        dosageForm: 'Tablet',
        batchNumber: 'B1',
        expiryDate: now.add(const Duration(days: 100)),
        currentStock: 5, // only 5 available
        estimatedDaysRemaining: 2.0,
        status: StockStatus.warning,
        lastStockUpdate: now,
      );

      final destItem = InventoryItemModel(
        id: 'inv_dest',
        pharmacyId: 'p2',
        medicineId: 'm1',
        medicineName: 'Test Med',
        genericName: 'Test Gen',
        strength: '10mg',
        dosageForm: 'Tablet',
        batchNumber: 'B2',
        expiryDate: now.add(const Duration(days: 100)),
        currentStock: 0,
        estimatedDaysRemaining: 0.0,
        status: StockStatus.outOfStock,
        lastStockUpdate: now,
      );

      final transfer = RedistributionTransferModel(
        id: 'trans_fail',
        requestId: 'req_fail',
        sourcePharmacyId: 'p1',
        sourcePharmacyName: 'P1',
        destinationPharmacyId: 'p2',
        destinationPharmacyName: 'P2',
        medicineId: 'm1',
        medicineName: 'Test Med',
        strength: '10mg',
        dosageForm: 'Tablet',
        agreedQuantity: 20, // requested 20 when source has 5
        batchNumber: 'B1',
        expiryDate: now.add(const Duration(days: 100)),
        createdAt: now,
      );

      expect(
        () => RedistributionService.completeTransferLocally(
          transfer: transfer,
          sourceItem: lowSourceItem,
          destItem: destItem,
          completedByUserId: 'Staff',
        ),
        throwsException,
      );
    });
  });
}
