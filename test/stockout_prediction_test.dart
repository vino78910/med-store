import 'package:flutter_test/flutter_test.dart';
import 'package:vitalmed/services/stock_monitor_service.dart';
import 'package:vitalmed/models/inventory_item_model.dart';
import 'package:vitalmed/models/stock_alert_model.dart';

void main() {
  group('Feature 5: Stockout Prediction & Early Alerts Tests', () {
    const thresholds = StockoutThresholds(
      warningDays: 3.0,
      criticalDays: 1.0,
    );

    test('Formula: Days Remaining = Available Stock / Average Daily Burn', () {
      final result = StockMonitorService.evaluateStock(
        currentStock: 10,
        averageDailyConsumption: 5.0,
        thresholds: thresholds,
      );

      expect(result.estimatedDaysRemaining, 2.0);
      expect(result.status, StockStatus.warning);
      expect(result.riskLevel, AlertRiskLevel.warning);
      expect(result.alertRequired, true);
    });

    test('Critical alert triggered when stockout expected within 1 day', () {
      final result = StockMonitorService.evaluateStock(
        currentStock: 2,
        averageDailyConsumption: 2.0,
        thresholds: thresholds,
      );

      expect(result.estimatedDaysRemaining, 1.0);
      expect(result.status, StockStatus.critical);
      expect(result.riskLevel, AlertRiskLevel.critical);
      expect(result.alertRequired, true);
    });

    test('OUT OF STOCK condition when stock reaches 0', () {
      final result = StockMonitorService.evaluateStock(
        currentStock: 0,
        averageDailyConsumption: 3.0,
        thresholds: thresholds,
      );

      expect(result.estimatedDaysRemaining, 0.0);
      expect(result.status, StockStatus.outOfStock);
      expect(result.riskLevel, AlertRiskLevel.outOfStock);
      expect(result.alertRequired, true);
    });

    test('Healthy stock level returns NORMAL status without alert', () {
      final result = StockMonitorService.evaluateStock(
        currentStock: 100,
        averageDailyConsumption: 2.0,
        thresholds: thresholds,
      );

      expect(result.estimatedDaysRemaining, 50.0);
      expect(result.status, StockStatus.normal);
      expect(result.riskLevel, isNull);
      expect(result.alertRequired, false);
    });

    test('Safe handling of zero consumption or insufficient historical data', () {
      final result = StockMonitorService.evaluateStock(
        currentStock: 25,
        averageDailyConsumption: 0.0, // Zero burn rate
        thresholds: thresholds,
      );

      expect(result.estimatedDaysRemaining, 999.0);
      expect(result.status, StockStatus.normal);
      expect(result.alertRequired, false);
    });

    test('AI Demand Forecasting model evaluates historical trends', () {
      // Historical increasing daily consumption: 2, 2, 3, 4, 5, 6, 8
      final history = [2, 2, 3, 4, 5, 6, 8];

      final result = StockMonitorService.evaluateStock(
        currentStock: 30,
        averageDailyConsumption: 4.5,
        thresholds: thresholds,
        historicalDailyConsumption: history,
      );

      expect(result.trendDirection, 'INCREASING');
      expect(result.modelType, 'AI-Powered Weighted Trend Model');
      expect(result.aiPredictedDemand7d, isNotNull);
      expect(result.confidenceScore, greaterThan(0.5));
    });
  });
}
