import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../models/inventory_item_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stock_status_badge.dart';
import 'nearby_pharmacies_screen.dart';

class StockoutPredictionsScreen extends StatefulWidget {
  const StockoutPredictionsScreen({super.key});

  @override
  State<StockoutPredictionsScreen> createState() => _StockoutPredictionsScreenState();
}

class _StockoutPredictionsScreenState extends State<StockoutPredictionsScreen> {
  double _warningDays = 3.0;
  double _criticalDays = 1.0;
  bool _isEditingThresholds = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _warningDays = appState.thresholds.warningDays;
    _criticalDays = appState.thresholds.criticalDays;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final inventory = appState.currentPharmacyInventory;
    final isAdmin = appState.currentUser?.isPharmacyAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockout Predictions'),
        actions: [
          if (isAdmin)
            TextButton.icon(
              onPressed: () {
                setState(() => _isEditingThresholds = !_isEditingThresholds);
              },
              icon: Icon(_isEditingThresholds ? Icons.check : Icons.tune_rounded, size: 16),
              label: Text(_isEditingThresholds ? 'Done' : 'Configure', style: const TextStyle(fontSize: 12)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forecast Methodology Banner
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
                  const Row(
                    children: [
                      Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Two-Tier Forecasting Engine',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Tier 1 (Core Inventory Metric): Estimated Days Remaining = Current Stock / Average Daily Burn\n'
                      'Tier 2 (AI Demand Trend Model): Weighted exponential moving velocity projecting 7-day surge risk.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Threshold Configuration Panel (Admin configurable - Feature 5)
            if (_isEditingThresholds) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Configure Early Alert Thresholds',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryDark),
                        ),
                        Text('ADMIN ONLY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('WARNING Alert Trigger: ${_warningDays.toStringAsFixed(1)} days remaining'),
                    Slider(
                      value: _warningDays,
                      min: 1.0,
                      max: 7.0,
                      divisions: 12,
                      label: '${_warningDays.toStringAsFixed(1)} days',
                      activeColor: AppColors.warning,
                      onChanged: (val) => setState(() => _warningDays = val),
                    ),
                    const SizedBox(height: 8),
                    Text('CRITICAL Alert Trigger: ${_criticalDays.toStringAsFixed(1)} days remaining'),
                    Slider(
                      value: _criticalDays,
                      min: 0.5,
                      max: 3.0,
                      divisions: 5,
                      label: '${_criticalDays.toStringAsFixed(1)} days',
                      activeColor: AppColors.critical,
                      onChanged: (val) => setState(() => _criticalDays = val),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          appState.updateThresholds(
                            warningDays: _warningDays,
                            criticalDays: _criticalDays,
                          );
                          setState(() => _isEditingThresholds = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.normal,
                              content: Text('Thresholds updated & inventory recalculated across connected devices.'),
                            ),
                          );
                        },
                        child: const Text('Save & Apply Thresholds'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Current Active Threshold Badges
            Row(
              children: [
                _buildThresholdPill('WARNING', '<= ${_warningDays.toStringAsFixed(1)} days', AppColors.warningBg, AppColors.warning),
                const SizedBox(width: 8),
                _buildThresholdPill('CRITICAL', '<= ${_criticalDays.toStringAsFixed(1)} days', AppColors.criticalBg, AppColors.critical),
                const SizedBox(width: 8),
                _buildThresholdPill('OUT OF STOCK', '= 0 units', AppColors.outOfStockBg, AppColors.outOfStock),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Item-by-Item Stockout Risk Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ...inventory.map((item) => _buildPredictionCard(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdPill(String label, String value, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: text.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: text)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text)),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, InventoryItemModel item) {
    final isAtRisk = item.status != StockStatus.normal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAtRisk ? (item.status == StockStatus.critical ? AppColors.critical : AppColors.warning) : AppColors.border,
          width: isAtRisk ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                ),
              ),
              StockStatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.genericName} • ${item.strength}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildParam('Available Stock', '${item.currentStock} ${item.unit}'),
              ),
              Expanded(
                child: _buildParam('Avg Daily Burn', '${item.averageDailyConsumption} /day'),
              ),
              Expanded(
                child: _buildParam(
                  'Days Remaining',
                  item.currentStock == 0 ? '0.0 days' : '${item.estimatedDaysRemaining} days',
                  isWarning: isAtRisk,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AI Demand Trend Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  item.demandForecastTrend == 'INCREASING'
                      ? Icons.trending_up_rounded
                      : (item.demandForecastTrend == 'DECREASING' ? Icons.trending_down_rounded : Icons.trending_flat_rounded),
                  color: item.demandForecastTrend == 'INCREASING' ? AppColors.critical : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Demand Velocity: ${item.demandForecastTrend} '
                    '(${item.aiPredictedDemand7d != null ? 'Projected 7d consumption: ${item.aiPredictedDemand7d} units' : 'Stable'})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          if (isAtRisk) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => NearbyPharmaciesScreen(
                        preselectedMedicineId: item.medicineId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.share_location_rounded, size: 16),
                label: Text('Find Nearby Pharmacies with Surplus (${item.medicineName})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParam(String label, String value, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isWarning ? FontWeight.w800 : FontWeight.w600,
            color: isWarning ? AppColors.critical : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
