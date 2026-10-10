import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item_model.dart';
import '../theme/app_theme.dart';
import 'stock_status_badge.dart';

class MedicineCard extends StatelessWidget {
  final InventoryItemModel item;
  final VoidCallback onRestock;
  final VoidCallback onDispense;
  final VoidCallback onRedistribute;

  const MedicineCard({
    super.key,
    required this.item,
    required this.onRestock,
    required this.onDispense,
    required this.onRedistribute,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    final isLowOrCritical =
        item.status == StockStatus.warning ||
        item.status == StockStatus.critical ||
        item.status == StockStatus.outOfStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowOrCritical
              ? (item.status == StockStatus.critical
                  ? AppColors.critical.withOpacity(0.4)
                  : AppColors.warning.withOpacity(0.4))
              : AppColors.border,
          width: isLowOrCritical ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Name & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.medicineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.genericName} • ${item.strength} (${item.dosageForm})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StockStatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),

            // Middle row: Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    label: 'Current Stock',
                    value: '${item.currentStock} ${item.unit}',
                    isHighlighted: isLowOrCritical,
                    highlightColor: item.status == StockStatus.critical
                        ? AppColors.critical
                        : (item.status == StockStatus.warning
                            ? AppColors.warning
                            : AppColors.textPrimary),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Est. Days Left',
                    value: item.currentStock == 0
                        ? '0 days'
                        : '${item.estimatedDaysRemaining} days',
                    isHighlighted: isLowOrCritical,
                    highlightColor: item.status == StockStatus.critical
                        ? AppColors.critical
                        : (item.status == StockStatus.warning
                            ? AppColors.warning
                            : AppColors.textPrimary),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Daily Burn',
                    value: '${item.averageDailyConsumption} /day',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Expiry',
                    value: dateFormat.format(item.expiryDate),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestock,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Restock', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: item.currentStock > 0 ? onDispense : null,
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: const Text('Dispense', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (isLowOrCritical) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRedistribute,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: const Text('Redistribute', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    bool isHighlighted = false,
    Color highlightColor = AppColors.textPrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: highlightColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
