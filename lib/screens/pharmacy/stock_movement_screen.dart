import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../models/stock_movement_model.dart';
import '../../theme/app_theme.dart';

class StockMovementScreen extends StatelessWidget {
  const StockMovementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pharmacyId = appState.currentUser?.pharmacyId;
    final movements = appState.currentPharmacyInventory.isEmpty
        ? <StockMovementModel>[]
        : appState.getInitialMovementsFiltered(pharmacyId);

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movement Audit Log'),
      ),
      body: movements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text('No Stock Movements Recorded', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Restocks, sales, and redistribution transfers will appear here.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final move = movements[index];
                final isPositive = move.isPositive;

                Color color;
                IconData icon;

                switch (move.movementType) {
                  case MovementType.restock:
                    color = AppColors.normal;
                    icon = Icons.add_circle_outline;
                    break;
                  case MovementType.transferIn:
                    color = AppColors.secondary;
                    icon = Icons.move_to_inbox_rounded;
                    break;
                  case MovementType.transferOut:
                    color = const Color(0xFF6366F1);
                    icon = Icons.outbox_rounded;
                    break;
                  case MovementType.dispense:
                    color = AppColors.warning;
                    icon = Icons.shopping_bag_outlined;
                    break;
                  case MovementType.adjustment:
                  default:
                    color = AppColors.textSecondary;
                    icon = Icons.tune_rounded;
                    break;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  move.medicineName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${isPositive ? '+' : '-'}${move.quantity}',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${move.movementType.label} • Prior: ${move.previousStock} → New: ${move.newStock}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            if (move.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                move.notes,
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              'By ${move.performedBy} • ${dateFormat.format(move.timestamp)}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

extension AppStateMovementExtension on AppState {
  List<StockMovementModel> getInitialMovementsFiltered(String? pharmacyId) {
    // Returns full reactive movement log
    return SampleDataService.getInitialMovements();
  }
}
