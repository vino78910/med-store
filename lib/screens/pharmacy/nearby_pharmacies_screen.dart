import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/redistribution_service.dart';
import '../../services/location_service.dart';
import '../../models/redistribution_request_model.dart';
import '../../theme/app_theme.dart';
import 'requests_screen.dart';

class NearbyPharmaciesScreen extends StatefulWidget {
  final String? preselectedMedicineId;

  const NearbyPharmaciesScreen({
    super.key,
    this.preselectedMedicineId,
  });

  @override
  State<NearbyPharmaciesScreen> createState() => _NearbyPharmaciesScreenState();
}

class _NearbyPharmaciesScreenState extends State<NearbyPharmaciesScreen> {
  String? _selectedMedicineId;
  double _radiusKm = 5.0;
  int _requestedQuantity = 20;
  RequestUrgency _urgency = RequestUrgency.urgent;

  @override
  void initState() {
    super.initState();
    _selectedMedicineId = widget.preselectedMedicineId ?? 'med_paracetamol_syrup';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final inventory = appState.currentPharmacyInventory;

    // Selected item
    final selectedItem = inventory.firstWhere(
      (item) => item.medicineId == _selectedMedicineId,
      orElse: () => inventory.isNotEmpty ? inventory.first : SampleDataService.getInitialInventory().first,
    );

    // Candidates evaluated by RedistributionService
    final candidates = appState.getEligibleSuppliersForMedicine(
      medicineId: selectedItem.medicineId,
      strength: selectedItem.strength,
      dosageForm: selectedItem.dosageForm,
      requestedQuantity: _requestedQuantity,
      radiusKm: _radiusKm,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Surplus Pharmacies'),
      ),
      body: Column(
        children: [
          // Filter & Configuration Card
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Selector
                Row(
                  children: [
                    const Icon(Icons.medication_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedItem.medicineId,
                          isExpanded: true,
                          items: inventory
                              .map((item) => DropdownMenuItem(
                                    value: item.medicineId,
                                    child: Text(
                                      '${item.medicineName} (${item.strength})',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMedicineId = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Radius Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Radius: ${_radiusKm.toStringAsFixed(0)} km',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${candidates.where((c) => c.isEligible).length} Eligible Nearby',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.normal),
                    ),
                  ],
                ),
                Slider(
                  value: _radiusKm,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  label: '${_radiusKm.toStringAsFixed(0)} km',
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _radiusKm = val),
                ),

                // Requested Quantity Counter & Urgency
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Quantity Needed: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('$_requestedQuantity units', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: _requestedQuantity > 5
                              ? () => setState(() => _requestedQuantity -= 5)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => setState(() => _requestedQuantity += 5),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Candidate Pharmacies List
          Expanded(
            child: candidates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Nearby Pharmacies Found',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try expanding the radius slider beyond ${_radiusKm.toStringAsFixed(0)} km.',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      return _buildCandidateCard(context, candidate, selectedItem, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    CandidatePharmacy candidate,
    dynamic selectedItem,
    AppState appState,
  ) {
    final pharmacy = candidate.pharmacy;
    final isEligible = candidate.isEligible;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEligible ? AppColors.normal.withOpacity(0.5) : AppColors.border,
          width: isEligible ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Pharmacy Name & Distance Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pharmacy.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LocationService.formatDistance(candidate.distanceKm),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            pharmacy.address,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Stock & Surplus Breakdown
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total In Stock', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text('${candidate.inventoryItem.currentStock} units', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Safe Surplus', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text(
                        '${candidate.surplusStock} units',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isEligible ? AppColors.normal : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Match Rank', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      Text('${(candidate.suitabilityScore * 100).toInt()}% Match', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Eligibility Status Narrative
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isEligible ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 16,
                color: isEligible ? AppColors.normal : AppColors.warning,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  candidate.eligibilityReason,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isEligible ? AppColors.normal : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Request Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isEligible
                  ? () => _sendRequest(context, appState, candidate, selectedItem)
                  : null,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(
                isEligible ? 'Request $_requestedQuantity Units' : 'Ineligible for Sharing',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendRequest(
    BuildContext context,
    AppState appState,
    CandidatePharmacy candidate,
    dynamic selectedItem,
  ) {
    appState.sendRedistributionRequest(
      targetCandidate: candidate,
      medicineId: selectedItem.medicineId,
      medicineName: selectedItem.medicineName,
      strength: selectedItem.strength,
      dosageForm: selectedItem.dosageForm,
      quantity: _requestedQuantity,
      urgency: _urgency,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.normal),
            SizedBox(width: 8),
            Text('Request Dispatched', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Successfully sent redistribution request to ${candidate.pharmacy.name} for $_requestedQuantity bottles of ${selectedItem.medicineName}.\n\n'
          'They will receive an instant notification in their Incoming Requests screen.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => const RequestsScreen()),
              );
            },
            child: const Text('View Requests Tracker'),
          ),
        ],
      ),
    );
  }
}
