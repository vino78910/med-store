import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../screens/common/notification_center_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showRoleBadge;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showRoleBadge = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final unreadCount = appState.unreadNotificationsCount;

    return AppBar(
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (showRoleBadge && user != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showRoleSwitchDialog(context, appState),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.role.displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.swap_horiz, size: 12, color: AppColors.primaryDark),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (user?.pharmacyName != null && user!.isPharmacyStaff)
            Text(
              user.pharmacyName!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        // Role Quick Switcher action
        IconButton(
          tooltip: 'Switch Demo Perspective',
          icon: const Icon(Icons.switch_account_rounded, color: AppColors.primary),
          onPressed: () => _showRoleSwitchDialog(context, appState),
        ),

        // Notification Bell with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const NotificationCenterScreen(),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.critical,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showRoleSwitchDialog(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Switch Perspective (Demo Mode)',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text(
                  'Test end-to-end shortage alert, redistribution, and patient search from different roles:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _buildRoleTile(
                  ctx,
                  appState,
                  title: '1. Pharmacy Admin (Apex Care)',
                  subtitle: 'Has low stock on Paracetamol Syrup (WARNING: 2 days left)',
                  role: UserRole.pharmacyAdmin,
                  pharmacyId: 'pharmacy_a',
                  icon: Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                ),
                _buildRoleTile(
                  ctx,
                  appState,
                  title: '2. Pharmacist (Metro Cure Pharmacy)',
                  subtitle: 'Has surplus Paracetamol Syrup (120 units) to fulfill requests',
                  role: UserRole.pharmacist,
                  pharmacyId: 'pharmacy_b',
                  icon: Icons.local_pharmacy_rounded,
                  color: AppColors.secondary,
                ),
                _buildRoleTile(
                  ctx,
                  appState,
                  title: '3. Patient (Jane Doe)',
                  subtitle: 'Searches nearby pharmacies & subscribes to stock alerts',
                  role: UserRole.patient,
                  pharmacyId: null,
                  icon: Icons.person_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleTile(
    BuildContext context,
    AppState appState, {
    required String title,
    required String subtitle,
    required UserRole role,
    required String? pharmacyId,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = appState.currentUser?.role == role &&
        (pharmacyId == null || appState.currentUser?.pharmacyId == pharmacyId);

    return InkWell(
      onTap: () {
        appState.switchDemoRole(role);
        if (pharmacyId != null) {
          appState.switchActivePharmacy(pharmacyId);
        }
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
