import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pharmacy_model.dart';
import '../../services/patient_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';

class PharmacyDetailScreen extends StatelessWidget {
  final PharmacyModel pharmacy;
  final String medicineName;
  final String strength;
  final String dosageForm;
  final PatientAvailabilityStatus availability;
  final DateTime lastStockUpdate;
  final VoidCallback onSubscribeAlert;

  const PharmacyDetailScreen({
    super.key,
    required this.pharmacy,
    required this.medicineName,
    required this.strength,
    required this.dosageForm,
    required this.availability,
    required this.lastStockUpdate,
    required this.onSubscribeAlert,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a, dd MMM yyyy');

    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;

    switch (availability) {
      case PatientAvailabilityStatus.available:
        badgeColor = AppColors.normal;
        badgeBg = AppColors.normalBg;
        badgeIcon = Icons.check_circle_rounded;
        break;
      case PatientAvailabilityStatus.lowStock:
        badgeColor = AppColors.warning;
        badgeBg = AppColors.warningBg;
        badgeIcon = Icons.warning_rounded;
        break;
      case PatientAvailabilityStatus.unavailable:
        badgeColor = AppColors.outOfStock;
        badgeBg = AppColors.outOfStockBg;
        badgeIcon = Icons.cancel_rounded;
        break;
      case PatientAvailabilityStatus.availabilityUnconfirmed:
        badgeColor = const Color(0xFF6366F1);
        badgeBg = const Color(0xFFEEF2FF);
        badgeIcon = Icons.help_outline_rounded;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pharmacy.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 14, color: badgeColor),
                            const SizedBox(width: 4),
                            Text(
                              availability.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pharmacy.distanceKm != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            LocationService.formatDistance(pharmacy.distanceKm!),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pharmacy.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: AppColors.normal),
                      const SizedBox(width: 6),
                      Text(
                        'Verified Pharmacy License: ${pharmacy.licenseNumber}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Medicine availability details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Searched Medicine Status',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$medicineName ($strength, $dosageForm)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          availability.description,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Last Reported Stock Update: ${timeFormat.format(lastStockUpdate)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Operating Hours & Contact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Operating Hours & Contact',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time_rounded, 'Hours', pharmacy.operatingHours),
                  _buildInfoRow(Icons.phone_outlined, 'Phone', pharmacy.phone),
                  _buildInfoRow(Icons.email_outlined, 'Email', pharmacy.email),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dialing ${pharmacy.name}: ${pharmacy.phone}')),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded),
                    label: const Text('Call Pharmacy'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening Navigation to ${pharmacy.latitude}, ${pharmacy.longitude}...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            if (availability != PatientAvailabilityStatus.available) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSubscribeAlert,
                  icon: const Icon(Icons.notifications_active_rounded, color: AppColors.secondary),
                  label: const Text('Notify Me When Restocked'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 1),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
