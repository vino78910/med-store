import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../models/redistribution_request_model.dart';
import '../../theme/app_theme.dart';
import '../../services/location_service.dart';
import 'transfer_history_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final incoming = appState.incomingRequests;
    final outgoing = appState.outgoingRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Incoming Requests'),
                  if (incoming.any((r) => r.status == RequestStatus.pending)) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${incoming.where((r) => r.status == RequestStatus.pending).length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Outgoing Requests'),
                  if (outgoing.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text('(${outgoing.length})', style: const TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomingTab(context, incoming, appState),
          _buildOutgoingTab(context, outgoing),
        ],
      ),
    );
  }

  Widget _buildIncomingTab(
    BuildContext context,
    List<RedistributionRequestModel> requests,
    AppState appState,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text('No Incoming Requests', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('When nearby clinics request surplus stock, they will appear here.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return _buildIncomingRequestCard(context, req, appState);
      },
    );
  }

  Widget _buildIncomingRequestCard(
    BuildContext context,
    RedistributionRequestModel req,
    AppState appState,
  ) {
    final dateFormat = DateFormat('hh:mm a, dd MMM');
    final isPending = req.status == RequestStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.secondary.withOpacity(0.5) : AppColors.border,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: req.urgency == RequestUrgency.emergency
                      ? AppColors.criticalBg
                      : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${req.urgency.label} REQUEST',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: req.urgency == RequestUrgency.emergency
                        ? AppColors.critical
                        : AppColors.warning,
                  ),
                ),
              ),
              Text(
                dateFormat.format(req.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            req.medicineName,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
          ),
          Text(
            '${req.strength} • ${req.dosageForm}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Requesting Clinic:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      req.requestingPharmacyName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Distance:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      LocationService.formatDistance(req.distanceKm),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity Needed:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      '${req.requestedQuantity} bottles',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, appState, req),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.critical,
                      side: const BorderSide(color: AppColors.critical),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      appState.acceptRedistributionRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.normal,
                          content: Text('Accepted request! Transfer initialized and waiting for compliance verification.'),
                        ),
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (c) => const TransferHistoryScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Accept & Transfer'),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Text(
                'Status: ${req.status.label}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: req.status == RequestStatus.accepted ? AppColors.normal : AppColors.critical,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    AppState appState,
    RedistributionRequestModel req,
  ) {
    final reasonController = TextEditingController(text: 'Insufficient local safety stock reserve.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide reason for declining to notify requesting clinic:', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: () {
              appState.rejectRedistributionRequest(req.id, reasonController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Confirm Decline'),
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingTab(BuildContext context, List<RedistributionRequestModel> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No outgoing requests created yet.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(req.medicineName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: req.status == RequestStatus.accepted
                          ? AppColors.normalBg
                          : (req.status == RequestStatus.rejected ? AppColors.criticalBg : AppColors.warningBg),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      req.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: req.status == RequestStatus.accepted
                            ? AppColors.normal
                            : (req.status == RequestStatus.rejected ? AppColors.critical : AppColors.warning),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Sent to: ${req.targetPharmacyName} • ${req.requestedQuantity} units', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (req.responseNotes != null) ...[
                const SizedBox(height: 6),
                Text('Notes: ${req.responseNotes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
              ],
            ],
          ),
        );
      },
    );
  }
}
