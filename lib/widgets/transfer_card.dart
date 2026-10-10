import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/redistribution_transfer_model.dart';
import '../theme/app_theme.dart';

class TransferCard extends StatelessWidget {
  final RedistributionTransferModel transfer;
  final bool isSourcePharmacy;
  final VoidCallback? onApprove;
  final VoidCallback? onDispatch;
  final VoidCallback? onComplete;

  const TransferCard({
    super.key,
    required this.transfer,
    required this.isSourcePharmacy,
    this.onApprove,
    this.onDispatch,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    Color statusColor;
    Color statusBg;

    switch (transfer.status) {
      case TransferStatus.completed:
        statusColor = AppColors.normal;
        statusBg = AppColors.normalBg;
        break;
      case TransferStatus.inTransit:
        statusColor = AppColors.secondary;
        statusBg = AppColors.secondaryLight;
        break;
      case TransferStatus.approved:
        statusColor = const Color(0xFF6366F1); // Indigo
        statusBg = const Color(0xFFEEF2FF);
        break;
      case TransferStatus.accepted:
        statusColor = AppColors.warning;
        statusBg = AppColors.warningBg;
        break;
      case TransferStatus.rejected:
      case TransferStatus.cancelled:
        statusColor = AppColors.critical;
        statusBg = AppColors.criticalBg;
        break;
      case TransferStatus.pending:
      default:
        statusColor = AppColors.textSecondary;
        statusBg = AppColors.background;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
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
            // Top Row: Transfer ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRANSFER #${transfer.id.replaceAll('trans_', '').substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transfer.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Medicine & Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transfer.medicineName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${transfer.agreedQuantity} units',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Source -> Destination Flow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.outbox_rounded, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      const Text(
                        'From: ',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          transfer.sourcePharmacyName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.move_to_inbox_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'To:     ',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          transfer.destinationPharmacyName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Compliance & Batch Details
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.normal),
                const SizedBox(width: 6),
                const Text(
                  'Compliance Verified • Batch: ',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  transfer.batchNumber,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),

            if (transfer.trackingNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Note: ${transfer.trackingNotes}',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
              ),
            ],

            const SizedBox(height: 12),

            // Action Workflow Buttons based on Transfer Status
            if (transfer.status == TransferStatus.accepted && onApprove != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.rule_folder_rounded, size: 16),
                  label: const Text('Verify Compliance & Approve Transfer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            else if (transfer.status == TransferStatus.approved && onDispatch != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDispatch,
                  icon: const Icon(Icons.local_shipping_rounded, size: 16),
                  label: const Text('Dispatch Medicine (Mark In Transit)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            else if (transfer.status == TransferStatus.inTransit && onComplete != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.task_alt_rounded, size: 16),
                  label: const Text('Confirm Receipt & Update Inventory'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.normal,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            else if (transfer.status == TransferStatus.completed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.normalBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.normal),
                    const SizedBox(width: 6),
                    Text(
                      'Completed & Inventory Synchronized (${dateFormat.format(transfer.completedAt ?? transfer.createdAt)})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.normal),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
