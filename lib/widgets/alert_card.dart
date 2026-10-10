import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_alert_model.dart';
import '../theme/app_theme.dart';

class AlertCard extends StatelessWidget {
  final StockAlertModel alert;
  final VoidCallback onAcknowledge;
  final VoidCallback onFindNearby;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onAcknowledge,
    required this.onFindNearby,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a, dd MMM');

    Color themeColor;
    Color bg;
    IconData icon;

    switch (alert.riskLevel) {
      case AlertRiskLevel.warning:
        themeColor = AppColors.warning;
        bg = AppColors.warningBg;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertRiskLevel.critical:
        themeColor = AppColors.critical;
        bg = AppColors.criticalBg;
        icon = Icons.error_outline_rounded;
        break;
      case AlertRiskLevel.outOfStock:
        themeColor = AppColors.outOfStock;
        bg = AppColors.outOfStockBg;
        icon = Icons.do_not_disturb_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: themeColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alert.riskLevel.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeFormat.format(alert.timestamp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.medicineName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (alert.isAcknowledged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.normalBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: AppColors.normal),
                        SizedBox(width: 4),
                        Text(
                          'Acknowledged',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.normal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Alert details narrative
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alert.alertMessage,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Buttons
            Row(
              children: [
                if (!alert.isAcknowledged)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAcknowledge,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Acknowledge', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                if (!alert.isAcknowledged) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onFindNearby,
                    icon: const Icon(Icons.share_location_rounded, size: 16),
                    label: const Text('Redistribute Stock', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
