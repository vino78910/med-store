import 'dart:math';
import '../models/inventory_item_model.dart';
import '../models/stock_alert_model.dart';

class StockoutThresholds {
  final double warningDays;
  final double criticalDays;

  const StockoutThresholds({
    this.warningDays = 3.0,
    this.criticalDays = 1.0,
  });
}

class ForecastResult {
  final double estimatedDaysRemaining;
  final StockStatus status;
  final AlertRiskLevel? riskLevel;
  final String statusDescription;
  final bool alertRequired;
  // Advanced demand forecasting fields
  final double? aiPredictedDemand7d;
  final String trendDirection; // 'STABLE', 'INCREASING', 'DECREASING'
  final double confidenceScore; // 0.0 - 1.0
  final String modelType; // 'Basic Inventory Forecast' or 'AI-Powered Weighted Trend Model'

  ForecastResult({
    required this.estimatedDaysRemaining,
    required this.status,
    this.riskLevel,
    required this.statusDescription,
    required this.alertRequired,
    this.aiPredictedDemand7d,
    required this.trendDirection,
    required this.confidenceScore,
    required this.modelType,
  });
}

class StockMonitorService {
  /// Recalculates stock metrics, estimated days remaining, and status
  static ForecastResult evaluateStock({
    required int currentStock,
    required double averageDailyConsumption,
    StockoutThresholds thresholds = const StockoutThresholds(),
    List<int>? historicalDailyConsumption,
  }) {
    // 1. Safe handling for zero or negative stock
    if (currentStock <= 0) {
      return ForecastResult(
        estimatedDaysRemaining: 0.0,
        status: StockStatus.outOfStock,
        riskLevel: AlertRiskLevel.outOfStock,
        statusDescription: 'Stock reaches zero. Item is completely unavailable.',
        alertRequired: true,
        aiPredictedDemand7d: averageDailyConsumption * 7,
        trendDirection: 'CRITICAL_DEPLETED',
        confidenceScore: 1.0,
        modelType: 'Deterministic Inventory Status',
      );
    }

    // 2. Safe handling of zero daily consumption or insufficient historical data
    double daysRemaining;
    if (averageDailyConsumption <= 0.0) {
      // No recorded consumption; stock is not actively diminishing
      daysRemaining = 999.0;
    } else {
      daysRemaining = double.parse(
        (currentStock / averageDailyConsumption).toStringAsFixed(1),
      );
    }

    // 3. Status determination based on configurable thresholds
    StockStatus status;
    AlertRiskLevel? riskLevel;
    String description;
    bool alertRequired = false;

    if (daysRemaining <= thresholds.criticalDays) {
      status = StockStatus.critical;
      riskLevel = AlertRiskLevel.critical;
      description =
          'CRITICAL: Stockout expected within ${daysRemaining.toStringAsFixed(1)} days (Threshold: <= ${thresholds.criticalDays} day).';
      alertRequired = true;
    } else if (daysRemaining <= thresholds.warningDays) {
      status = StockStatus.warning;
      riskLevel = AlertRiskLevel.warning;
      description =
          'WARNING: Stockout expected within ${daysRemaining.toStringAsFixed(1)} days (Threshold: <= ${thresholds.warningDays} days).';
      alertRequired = true;
    } else {
      status = StockStatus.normal;
      riskLevel = null;
      description = 'NORMAL: Stock is healthy (> ${thresholds.warningDays} days remaining).';
      alertRequired = false;
    }

    // 4. Advanced Demand Forecasting Model (when historical consumption data is present)
    double? predicted7dDemand;
    String trend = 'STABLE';
    double confidence = 0.70;
    String modelType = 'Basic Inventory Forecast';

    if (historicalDailyConsumption != null && historicalDailyConsumption.length >= 7) {
      modelType = 'AI-Powered Weighted Trend Model';
      final forecast = _calculateWeightedTrendDemand(historicalDailyConsumption);
      predicted7dDemand = forecast.projected7d;
      trend = forecast.trend;
      confidence = forecast.confidence;

      // If trend is accelerating rapidly, adjust warning threshold proactively
      if (trend == 'INCREASING' && daysRemaining <= (thresholds.warningDays + 1.0)) {
        status = StockStatus.warning;
        riskLevel = AlertRiskLevel.warning;
        alertRequired = true;
      }
    }

    return ForecastResult(
      estimatedDaysRemaining: daysRemaining,
      status: status,
      riskLevel: riskLevel,
      statusDescription: description,
      alertRequired: alertRequired,
      aiPredictedDemand7d: predicted7dDemand,
      trendDirection: trend,
      confidenceScore: confidence,
      modelType: modelType,
    );
  }

  /// AI / Demand Forecasting: Weighted Linear Regression & Exponential Decay
  static ({double projected7d, String trend, double confidence})
      _calculateWeightedTrendDemand(List<int> history) {
    final int n = history.length;
    double weightedSum = 0;
    double weightTotal = 0;

    for (int i = 0; i < n; i++) {
      // Recent days get exponentially higher weight
      final double weight = pow(1.2, i).toDouble();
      weightedSum += history[i] * weight;
      weightTotal += weight;
    }

    final double weightedAvgDaily = weightedSum / weightTotal;
    final double projected7d = double.parse((weightedAvgDaily * 7).toStringAsFixed(1));

    // Slope calculation
    final double firstHalfAvg =
        history.take(n ~/ 2).reduce((a, b) => a + b) / (n ~/ 2);
    final double secondHalfAvg =
        history.skip(n ~/ 2).reduce((a, b) => a + b) / (n - n ~/ 2);

    String trend = 'STABLE';
    if (secondHalfAvg > firstHalfAvg * 1.25) {
      trend = 'INCREASING';
    } else if (secondHalfAvg < firstHalfAvg * 0.75) {
      trend = 'DECREASING';
    }

    // Confidence depends on consistency / standard deviation
    double variance = 0;
    for (var val in history) {
      variance += pow(val - weightedAvgDaily, 2);
    }
    final double stdDev = sqrt(variance / n);
    final double cv = stdDev / (weightedAvgDaily > 0 ? weightedAvgDaily : 1.0);
    final double confidence = max(0.5, min(0.95, 1.0 - (cv * 0.3)));

    return (
      projected7d: projected7d,
      trend: trend,
      confidence: double.parse(confidence.toStringAsFixed(2)),
    );
  }

  /// Check whether an existing alert should be resolved or updated
  static bool shouldResolveAlert(
    StockAlertModel alert,
    InventoryItemModel currentItem,
  ) {
    if (currentItem.currentStock > 0 &&
        currentItem.status == StockStatus.normal) {
      return true;
    }
    return false;
  }
}
