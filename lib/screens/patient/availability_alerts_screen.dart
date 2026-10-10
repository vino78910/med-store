import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../models/patient_subscription_model.dart';
import '../../theme/app_theme.dart';

class AvailabilityAlertsScreen extends StatelessWidget {
  const AvailabilityAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final subscriptions = appState.currentPatientSubscriptions;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Alerts'),
      ),
      body: subscriptions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active_outlined, size: 54, color: AppColors.textMuted.withOpacity(0.5)),
                    const SizedBox(height: 14),
                    const Text(
                      'No Active Alerts',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'When a medicine is out of stock in your area, subscribe to receive automated push alerts the moment a nearby pharmacy restocks it.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSubscriptionDialog(context, appState),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create New Medicine Alert'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                return _buildSubscriptionCard(context, sub, appState, dateFormat);
              },
            ),
      floatingActionButton: subscriptions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSubscriptionDialog(context, appState),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Alert'),
            )
          : null,
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    PatientSubscriptionModel sub,
    AppState appState,
    DateFormat dateFormat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.normalBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: AppColors.normal),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE MONITORING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.critical, size: 20),
                tooltip: 'Cancel Subscription',
                onPressed: () {
                  appState.unsubscribePatient(sub.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cancelled alert subscription for ${sub.medicineName}.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            sub.medicineName,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
          ),
          Text(
            '${sub.strength} • ${sub.dosageForm}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.radar_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Searching pharmacies within ${sub.maxDistanceKm.toStringAsFixed(0)} km radius.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Subscribed on ${dateFormat.format(sub.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context, AppState appState) {
    final medController = TextEditingController();
    final strengthController = TextEditingController(text: '250mg/5ml');
    String form = 'Syrup';
    double radius = 10.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Subscribe to Restock Alert', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter details of the scarce medicine you are looking for:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: medController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name *',
                    hintText: 'e.g. Paracetamol Syrup',
                    prefixIcon: Icon(Icons.medication, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: strengthController,
                  decoration: const InputDecoration(
                    labelText: 'Strength',
                    hintText: 'e.g. 250mg/5ml',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: form,
                  decoration: const InputDecoration(labelText: 'Dosage Form'),
                  items: ['Syrup', 'Tablet', 'Suspension', 'Inhaler', 'Capsule']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => form = val);
                  },
                ),
                const SizedBox(height: 10),
                Text('Distance Radius: ${radius.toStringAsFixed(0)} km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Slider(
                  value: radius,
                  min: 1.0,
                  max: 25.0,
                  divisions: 24,
                  onChanged: (val) => setDialogState(() => radius = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = medController.text.trim();
                if (name.isEmpty) return;

                appState.subscribeToMedicineAvailability(
                  medicineName: name,
                  strength: strengthController.text.trim(),
                  dosageForm: form,
                  radiusKm: radius,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.normal,
                    content: Text('Created restock alert for $name!'),
                  ),
                );
              },
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }
}
