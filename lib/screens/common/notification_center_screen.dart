import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../models/notification_model.dart';
import '../../theme/app_theme.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allNotifs = appState.currentNotifications;
    final timeFormat = DateFormat('hh:mm a, dd MMM');

    final filteredNotifs = _selectedCategory == null
        ? allNotifs
        : allNotifs.where((n) => n.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Centre'),
        actions: [
          TextButton.icon(
            onPressed: allNotifs.any((n) => !n.isRead)
                ? () => appState.markAllNotificationsAsRead()
                : null,
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category filter horizontal chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', null),
                ...NotificationCategory.values.map(
                  (cat) => _buildFilterChip(cat.label, cat),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Notifications list
          Expanded(
            child: filteredNotifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No notifications in this category',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      final notif = filteredNotifs[index];
                      return _buildNotificationTile(context, notif, appState, timeFormat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primaryDark,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notif,
    AppState appState,
    DateFormat timeFormat,
  ) {
    Color iconColor;
    IconData icon;

    switch (notif.category) {
      case NotificationCategory.stockWarning:
        iconColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationCategory.criticalAlert:
        iconColor = AppColors.critical;
        icon = Icons.error_outline_rounded;
        break;
      case NotificationCategory.outOfStockAlert:
        iconColor = AppColors.outOfStock;
        icon = Icons.do_not_disturb_rounded;
        break;
      case NotificationCategory.incomingRequest:
        iconColor = AppColors.secondary;
        icon = Icons.move_to_inbox_rounded;
        break;
      case NotificationCategory.transferUpdate:
        iconColor = const Color(0xFF6366F1);
        icon = Icons.swap_horiz_rounded;
        break;
      case NotificationCategory.patientAvailability:
        iconColor = AppColors.normal;
        icon = Icons.notifications_active_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        appState.markNotificationAsRead(notif.id);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppColors.primaryLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeFormat.format(notif.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
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
