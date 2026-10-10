import 'package:flutter/material.dart';
import '../models/inventory_item_model.dart';
import '../theme/app_theme.dart';

class StockStatusBadge extends StatelessWidget {
  final StockStatus status;
  final bool compact;

  const StockStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case StockStatus.normal:
        bg = AppColors.normalBg;
        text = AppColors.normal;
        icon = Icons.check_circle_rounded;
        break;
      case StockStatus.warning:
        bg = AppColors.warningBg;
        text = AppColors.warning;
        icon = Icons.warning_rounded;
        break;
      case StockStatus.critical:
        bg = AppColors.criticalBg;
        text = AppColors.critical;
        icon = Icons.error_rounded;
        break;
      case StockStatus.outOfStock:
        bg = AppColors.outOfStockBg;
        text = AppColors.outOfStock;
        icon = Icons.do_not_disturb_on_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.padBorder(Border.all(color: text.withOpacity(0.3), width: 1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: text),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: text,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
