import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/alert_card.dart';
import 'add_edit_medicine_screen.dart';
import 'nearby_pharmacies_screen.dart';
import 'inventory_screen.dart';

class PharmacyDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const PharmacyDashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final alerts = appState.currentPharmacyAlerts;
    final pharmacy = appState.currentPharmacy;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // In real Firestore, this syncs with Firestore stream
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pharmacy Header Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LIVE INVENTORY SYNC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          pharmacy?.licenseNumber ?? 'LICENSED',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      pharmacy?.name ?? 'VitalMed Partner Pharmacy',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacy?.address ?? 'Central District',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          pharmacy?.operatingHours ?? '8:00 AM - 10:00 PM',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Stock Status Overview Grid (Feature 2)
              const Text(
                'Inventory Status Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Total Medicines',
                      value: '${appState.totalMedicinesCount}',
                      subtitle: 'Active Catalog',
                      icon: Icons.medication_rounded,
                      color: AppColors.primary,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Available (NORMAL)',
                      value: '${appState.availableMedicinesCount}',
                      subtitle: 'Healthy Levels',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.normal,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Low Stock (WARNING)',
                      value: '${appState.lowStockMedicinesCount}',
                      subtitle: '<= 3 days left',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Critical (CRITICAL)',
                      value: '${appState.criticalStockMedicinesCount}',
                      subtitle: '<= 1 day left',
                      icon: Icons.error_outline_rounded,
                      color: AppColors.critical,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'OUT OF STOCK',
                      value: '${appState.outOfStockMedicinesCount}',
                      subtitle: 'Stock = 0 units',
                      icon: Icons.do_not_disturb_on_rounded,
                      color: AppColors.outOfStock,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Active Stock Alerts',
                      value: '${appState.recentAlertsCount}',
                      subtitle: 'Needs attention',
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.critical,
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Section 2: Redistribution Activity Metrics (Feature 2)
              const Text(
                'Redistribution Pipeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Incoming Requests',
                      value: '${appState.incomingRedistributionCount}',
                      subtitle: 'From nearby clinics',
                      icon: Icons.move_to_inbox_rounded,
                      color: AppColors.secondary,
                      onTap: () => onNavigateTab(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Pending Requests',
                      value: '${appState.pendingRequestsCount}',
                      subtitle: 'Awaiting response',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      onTap: () => onNavigateTab(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              MetricCard(
                title: 'Completed Medicine Transfers',
                value: '${appState.completedTransfersCount}',
                subtitle: 'Audited & synchronized transfers',
                icon: Icons.swap_horiz_rounded,
                color: const Color(0xFF6366F1),
                onTap: () => onNavigateTab(4),
              ),

              const SizedBox(height: 20),

              // Quick Actions
              const Text(
                'Quick Operations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const AddEditMedicineScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Medicine', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onNavigateTab(1),
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: const Text('View Inventory', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section 3: Recent Stock Alerts (Feature 2 & Feature 6)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Stock Alerts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (alerts.isNotEmpty)
                    Text(
                      '${alerts.length} unresolved',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.critical,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (alerts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.task_alt_rounded, color: AppColors.normal, size: 36),
                      SizedBox(height: 8),
                      Text(
                        'All Medicine Stocks Healthy',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No medicines are expected to run out within threshold limits.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...alerts.map(
                  (alert) => AlertCard(
                    alert: alert,
                    onAcknowledge: () => appState.acknowledgeAlert(alert.id),
                    onFindNearby: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => NearbyPharmaciesScreen(
                            preselectedMedicineId: alert.medicineId,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
