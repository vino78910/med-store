import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/inventory_item_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/medicine_card.dart';
import 'add_edit_medicine_screen.dart';
import 'nearby_pharmacies_screen.dart';
import 'stock_movement_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  StockStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final inventory = appState.currentPharmacyInventory;

    final filteredList = inventory.where((item) {
      final matchesQuery = _searchQuery.isEmpty ||
          item.medicineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.genericName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == null ||
          item.status == _selectedStatusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Stock Movement Audit History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const StockMovementScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
            tooltip: 'Add New Medicine',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddEditMedicineScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by medicine, generic name...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip('All Statuses', null),
                      _buildStatusFilterChip('NORMAL', StockStatus.normal),
                      _buildStatusFilterChip('WARNING', StockStatus.warning),
                      _buildStatusFilterChip('CRITICAL', StockStatus.critical),
                      _buildStatusFilterChip('OUT OF STOCK', StockStatus.outOfStock),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Inventory List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'No inventory items matched',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try adjusting your search query or status filter.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return MedicineCard(
                        item: item,
                        onRestock: () => _showRestockDialog(context, appState, item),
                        onDispense: () => _showDispenseDialog(context, appState, item),
                        onRedistribute: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => NearbyPharmaciesScreen(
                                preselectedMedicineId: item.medicineId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, StockStatus? status) {
    final isSelected = _selectedStatusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedStatusFilter = status),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primaryDark,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
        ),
      ),
    );
  }

  void _showRestockDialog(
    BuildContext context,
    AppState appState,
    InventoryItemModel item,
  ) {
    final qtyController = TextEditingController();
    final batchController = TextEditingController(text: item.batchNumber);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Restock: ${item.medicineName}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current available stock: ${item.currentStock} ${item.unit}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Quantity to add *',
                  hintText: 'e.g. 50',
                  prefixIcon: Icon(Icons.add_shopping_cart, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number',
                  prefixIcon: Icon(Icons.qr_code, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                if (qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive quantity.')),
                  );
                  return;
                }
                appState.restockMedicine(
                  itemId: item.id,
                  quantityToAdd: qty,
                  batchNumber: batchController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.normal,
                    content: Text('Successfully restocked $qty ${item.unit} of ${item.medicineName}!'),
                  ),
                );
              },
              child: const Text('Confirm Restock'),
            ),
          ],
        );
      },
    );
  }

  void _showDispenseDialog(
    BuildContext context,
    AppState appState,
    InventoryItemModel item,
  ) {
    final qtyController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Dispense: ${item.medicineName}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available in inventory: ${item.currentStock} ${item.unit}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Quantity to dispense *',
                  hintText: 'Max ${item.currentStock}',
                  prefixIcon: const Icon(Icons.receipt_long, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Prescription / Patient Note',
                  hintText: 'e.g. Rx #8291 Outpatient',
                  prefixIcon: Icon(Icons.notes, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                if (qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive quantity.')),
                  );
                  return;
                }
                if (qty > item.currentStock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.critical,
                      content: Text('Validation Error: Cannot dispense $qty. Available stock is only ${item.currentStock} (prevents negative stock).'),
                    ),
                  );
                  return;
                }

                final success = appState.dispenseMedicine(
                  itemId: item.id,
                  quantityToDispense: qty,
                  patientOrPrescriptionRef: notesController.text.trim(),
                );

                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primaryDark,
                      content: Text('Dispensed $qty ${item.unit}. Available stock updated.'),
                    ),
                  );
                }
              },
              child: const Text('Confirm Dispense'),
            ),
          ],
        );
      },
    );
  }
}
