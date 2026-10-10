import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class PharmacyProfileScreen extends StatelessWidget {
  const PharmacyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pharmacy = appState.currentPharmacy;
    final user = appState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy & Staff Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.local_pharmacy_rounded, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pharmacy?.name ?? 'VitalMed Registered Pharmacy',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.normalBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'VERIFIED LICENSE • ${pharmacy?.licenseNumber ?? 'DL-ACTIVE'}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.normal),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pharmacy Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Operating Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.place_outlined, 'Address', pharmacy?.address ?? 'Central District'),
                  _buildDetailRow(Icons.phone_outlined, 'Phone', pharmacy?.phone ?? '+91 98765 43210'),
                  _buildDetailRow(Icons.email_outlined, 'Email', pharmacy?.email ?? 'contact@pharmacy.com'),
                  _buildDetailRow(Icons.access_time, 'Hours', pharmacy?.operatingHours ?? '8:00 AM - 10:00 PM'),
                  _buildDetailRow(Icons.gps_fixed, 'GPS Coordinates', '${pharmacy?.latitude ?? 28.6145}, ${pharmacy?.longitude ?? 77.2095}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Active User Staff Member
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Logged In Staff Member', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.person_outline, 'Name', user?.name ?? 'Michael Vance'),
                  _buildDetailRow(Icons.badge_outlined, 'Assigned Role', user?.role.displayName ?? 'Pharmacy Admin'),
                  _buildDetailRow(Icons.alternate_email, 'Email', user?.email ?? 'admin@apexcare.sample.com'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reset Sample Data Button (Feature 16)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  appState.resetDemoState();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.primary,
                      content: Text('Reset sample data to initial hackathon demonstration baseline!'),
                    ),
                  );
                },
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset Demo Scenario Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
