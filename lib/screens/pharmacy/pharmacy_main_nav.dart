import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'stockout_predictions_screen.dart';
import 'requests_screen.dart';
import 'transfer_history_screen.dart';
import 'nearby_pharmacies_screen.dart';
import 'stock_movement_screen.dart';
import 'pharmacy_profile_screen.dart';

class PharmacyMainNav extends StatefulWidget {
  const PharmacyMainNav({super.key});

  @override
  State<PharmacyMainNav> createState() => _PharmacyMainNavState();
}

class _PharmacyMainNavState extends State<PharmacyMainNav> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pendingRequests = appState.incomingRedistributionCount;

    final List<Widget> screens = [
      PharmacyDashboardScreen(onNavigateTab: _onTabSelected),
      const InventoryScreen(),
      const StockoutPredictionsScreen(),
      const RequestsScreen(),
      const TransferHistoryScreen(),
    ];

    final titles = [
      'VitalMed Dashboard',
      'Inventory Catalog',
      'Stockout Predictions',
      'Redistribution Requests',
      'Transfer Audit Trail',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: titles[_currentIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'VitalMed',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Right Medicine, Right Time, Every Life.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    appState.currentPharmacy?.name ?? 'Registered Pharmacy',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
              title: const Text('Dashboard'),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
              title: const Text('Inventory Management'),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph_rounded, color: AppColors.primary),
              title: const Text('Stockout Predictions & AI'),
              selected: _currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_location_rounded, color: AppColors.primary),
              title: const Text('Find Surplus Pharmacies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const NearbyPharmaciesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inbox_rounded, color: AppColors.primary),
              title: const Text('Incoming & Outgoing Requests'),
              selected: _currentIndex == 3,
              trailing: pendingRequests > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingRequests',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
              title: const Text('Transfer Audit History'),
              selected: _currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _onTabSelected(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              title: const Text('Stock Movement Logs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const StockMovementScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business_rounded, color: AppColors.textSecondary),
              title: const Text('Pharmacy Profile & Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const PharmacyProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Predictions',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.move_to_inbox_rounded),
                if (pendingRequests > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                    ),
                  ),
              ],
            ),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transfers',
          ),
        ],
      ),
    );
  }
}
