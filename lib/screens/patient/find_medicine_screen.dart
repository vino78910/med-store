import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../services/patient_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import 'availability_alerts_screen.dart';

class FindMedicineScreen extends StatefulWidget {
  final String? initialQuery;

  const FindMedicineScreen({super.key, this.initialQuery});

  @override
  State<FindMedicineScreen> createState() => _FindMedicineScreenState();
}

class _FindMedicineScreenState extends State<FindMedicineScreen> {
  final _searchController = TextEditingController();
  String? _selectedDosageForm;
  double _radiusKm = 10.0;

  final List<String> _dosageForms = [
    'All Forms',
    'Syrup',
    'Tablet',
    'Suspension',
    'Capsule',
    'Inhaler',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    } else {
      _searchController.text = 'Paracetamol';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final results = appState.searchMedicinesForPatient(
      query: _searchController.text.trim(),
      dosageForm: _selectedDosageForm == 'All Forms' ? null : _selectedDosageForm,
      radiusKm: _radiusKm,
    );

    final timeFormat = DateFormat('hh:mm a, dd MMM');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Medicine Nearby'),
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search medicine by name or generic...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Dosage Form Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _dosageForms.map((form) {
                      final isSelected = (_selectedDosageForm ?? 'All Forms') == form;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(form),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedDosageForm = form);
                          },
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
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Radius Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distance Radius: ${_radiusKm.toStringAsFixed(0)} km',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${results.length} Pharmacies Found',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
                Slider(
                  value: _radiusKm,
                  min: 1.0,
                  max: 25.0,
                  divisions: 24,
                  label: '${_radiusKm.toStringAsFixed(0)} km',
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _radiusKm = val),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Results List
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medication_liquid_rounded, size: 54, color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 14),
                          Text(
                            'No pharmacies reporting stock for "${_searchController.text}"',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Would you like to subscribe to notifications when a nearby pharmacy restocks this medicine?',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _subscribeForAlert(context, appState),
                            icon: const Icon(Icons.notification_add_rounded, size: 16),
                            label: const Text('Subscribe to Restock Alert'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return _buildPatientResultCard(context, item, timeFormat, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientResultCard(
    BuildContext context,
    PatientSearchResult result,
    DateFormat timeFormat,
    AppState appState,
  ) {
    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;

    switch (result.availability) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Status Header
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
                    Icon(badgeIcon, size: 13, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      result.availability.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LocationService.formatDistance(result.distanceKm),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pharmacy & Medicine
          Text(
            result.pharmacy.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            '${result.medicineName} (${result.strength}, ${result.dosageForm})',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            result.address,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          // Availability Disclaimer (Protects private internal counts)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${result.availability.description} Updated ${timeFormat.format(result.lastStockUpdate)}.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Call & Directions & Subscribe
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dialing ${result.pharmacy.name}: ${result.phone}')),
                    );
                  },
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                  label: const Text('Call Pharmacy', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showDirectionsModal(context, result);
                  },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Directions', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              if (result.availability == PatientAvailabilityStatus.unavailable ||
                  result.availability == PatientAvailabilityStatus.lowStock) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Notify me when stock increases',
                  icon: const Icon(Icons.notification_add_outlined, color: AppColors.secondary),
                  onPressed: () {
                    appState.subscribeToMedicineAvailability(
                      medicineName: result.medicineName,
                      strength: result.strength,
                      dosageForm: result.dosageForm,
                      radiusKm: _radiusKm,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.normal,
                        content: Text('Subscribed to alerts for ${result.medicineName}! You will be notified when restocked.'),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDirectionsModal(BuildContext context, PatientSearchResult result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.navigation_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.pharmacy.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.address, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Hours: ${result.operatingHours}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Approx. ${LocationService.formatDistance(result.distanceKm)} from your current location.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening Maps navigation to ${result.pharmacy.latitude}, ${result.pharmacy.longitude}...'),
                    ),
                  );
                },
                icon: const Icon(Icons.turn_right_rounded),
                label: const Text('Start Turn-by-Turn Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeForAlert(BuildContext context, AppState appState) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    appState.subscribeToMedicineAvailability(
      medicineName: query,
      strength: 'Standard',
      dosageForm: _selectedDosageForm ?? 'Syrup',
      radiusKm: _radiusKm,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.normal,
        content: Text('Alert created! You will be notified the moment $query becomes available nearby.'),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (c) => const AvailabilityAlertsScreen()),
    );
  }
}
