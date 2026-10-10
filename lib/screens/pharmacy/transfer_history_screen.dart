import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/redistribution_transfer_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/transfer_card.dart';

class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  TransferStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final transfers = appState.currentPharmacyTransfers;
    final currentPharmacyId = appState.currentUser?.pharmacyId;

    final filteredTransfers = _filterStatus == null
        ? transfers
        : transfers.where((t) => t.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redistribution Transfers'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All Statuses', null),
                _buildFilterChip('Accepted', TransferStatus.accepted),
                _buildFilterChip('Approved', TransferStatus.approved),
                _buildFilterChip('In Transit', TransferStatus.inTransit),
                _buildFilterChip('Completed', TransferStatus.completed),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          Expanded(
            child: filteredTransfers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text('No Transfers in this state', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransfers.length,
                    itemBuilder: (context, index) {
                      final transfer = filteredTransfers[index];
                      final isSource = transfer.sourcePharmacyId == currentPharmacyId;

                      return TransferCard(
                        transfer: transfer,
                        isSourcePharmacy: isSource,
                        onApprove: transfer.status == TransferStatus.accepted
                            ? () => _showComplianceApprovalDialog(context, appState, transfer)
                            : null,
                        onDispatch: transfer.status == TransferStatus.approved
                            ? () => appState.dispatchTransfer(transfer.id)
                            : null,
                        onComplete: transfer.status == TransferStatus.inTransit
                            ? () {
                                appState.completeTransfer(transfer.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.normal,
                                    content: Text('Atomic dual-inventory sync completed! Stock updated at both pharmacies.'),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransferStatus? status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterStatus = status),
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

  void _showComplianceApprovalDialog(
    BuildContext context,
    AppState appState,
    RedistributionTransferModel transfer,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Regulatory Compliance Check', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Before finalizing transfer approval, verify the following legal & safety requirements:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _buildCheckItem('Medicine & strength exact match: ${transfer.medicineName} (${transfer.strength})'),
            _buildCheckItem('Batch Number verified: ${transfer.batchNumber}'),
            _buildCheckItem('Cold-chain / room temperature packaging standards checked'),
            _buildCheckItem('Both pharmacies hold active drug distribution licenses'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              appState.approveTransfer(transfer.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.normal,
                  content: Text('Compliance verified! Transfer approved and cleared for physical courier dispatch.'),
                ),
              );
            },
            child: const Text('Verify & Approve Transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.normal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
