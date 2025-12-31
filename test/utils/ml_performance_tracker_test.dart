import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/utils/ml_performance_tracker.dart';

void main() {
  group('ModelMetrics', () {
    late ModelMetrics metrics;

    setUp(() {
      metrics = ModelMetrics('TestModel');
    });

    test('se inicializa con valores en cero', () {
      expect(metrics.modelName, 'TestModel');
      expect(metrics.totalInferences, 0);
      expect(metrics.successfulInferences, 0);
      expect(metrics.failedInferences, 0);
      expect(metrics.successRate, 0);
      expect(metrics.averageTimeMs, 0);
      expect(metrics.minTimeMs, 0);
      expect(metrics.maxTimeMs, 0);
    });

    test('recordSuccess incrementa contadores correctamente', () {
      metrics.recordSuccess(10);
      metrics.recordSuccess(20);
      metrics.recordSuccess(15);

      expect(metrics.totalInferences, 3);
      expect(metrics.successfulInferences, 3);
      expect(metrics.failedInferences, 0);
    });

    test('recordSuccess calcula min/max correctamente', () {
      metrics.recordSuccess(10);
      metrics.recordSuccess(50);
      metrics.recordSuccess(25);

      expect(metrics.minTimeMs, 10);
      expect(metrics.maxTimeMs, 50);
    });

    test('recordSuccess calcula promedio correctamente', () {
      metrics.recordSuccess(10);
      metrics.recordSuccess(20);
      metrics.recordSuccess(30);

      expect(metrics.averageTimeMs, 20.0);
    });

    test('recordFailure incrementa contador de errores', () {
      metrics.recordSuccess(10);
      metrics.recordFailure('Test error');
      metrics.recordFailure('Another error');

      expect(metrics.totalInferences, 3);
      expect(metrics.successfulInferences, 1);
      expect(metrics.failedInferences, 2);
      expect(metrics.lastError, 'Another error');
    });

    test('successRate se calcula correctamente', () {
      metrics.recordSuccess(10);
      metrics.recordSuccess(10);
      metrics.recordFailure('error');
      metrics.recordSuccess(10);

      expect(metrics.successRate, 0.75);
    });

    test('lastInferenceTime se actualiza en inferencias exitosas', () {
      expect(metrics.lastInferenceTime, isNull);
      metrics.recordSuccess(10);
      expect(metrics.lastInferenceTime, isNotNull);
    });

    test('recentAverageTimeMs calcula promedio de muestras recientes', () {
      for (int i = 1; i <= 10; i++) {
        metrics.recordSuccess(i * 10); // 10, 20, 30, ..., 100
      }
      // Average of 10+20+30+...+100 = 550/10 = 55
      expect(metrics.recentAverageTimeMs, 55.0);
    });

    test('reset limpia todas las métricas', () {
      metrics.recordSuccess(10);
      metrics.recordFailure('error');
      metrics.reset();

      expect(metrics.totalInferences, 0);
      expect(metrics.successfulInferences, 0);
      expect(metrics.failedInferences, 0);
      expect(metrics.lastInferenceTime, isNull);
      expect(metrics.lastError, isNull);
    });

    test('toMap genera mapa con todos los valores', () {
      metrics.recordSuccess(15);
      final map = metrics.toMap();

      expect(map['model_name'], 'TestModel');
      expect(map['total_inferences'], 1);
      expect(map['successful_inferences'], 1);
      expect(map['failed_inferences'], 0);
      expect(map['success_rate'], 1.0);
      expect(map['average_time_ms'], 15.0);
    });

    test('toString genera representación legible', () {
      metrics.recordSuccess(10);
      final str = metrics.toString();

      expect(str.contains('TestModel'), true);
      expect(str.contains('1/1'), true);
    });
  });

  group('MLPerformanceTracker', () {
    late MLPerformanceTracker tracker;

    setUp(() {
      tracker = MLPerformanceTracker();
      tracker.reset(); // Limpiar estado singleton
    });

    test('es singleton', () {
      final tracker1 = MLPerformanceTracker();
      final tracker2 = MLPerformanceTracker();
      expect(identical(tracker1, tracker2), true);
    });

    test('recordInitialization registra tiempo de inicialización', () {
      tracker.recordInitialization(150);

      expect(tracker.initializationDurationMs, 150);
      expect(tracker.initializationTime, isNotNull);
    });

    test('recordInference crea métricas para modelo nuevo', () {
      expect(tracker.getMetrics('NewModel'), isNull);

      tracker.recordInference('NewModel', 10, success: true);

      expect(tracker.getMetrics('NewModel'), isNotNull);
      expect(tracker.getMetrics('NewModel')!.totalInferences, 1);
    });

    test('recordInference acumula métricas para mismo modelo', () {
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model1', 20, success: true);
      tracker.recordInference('Model1', 0, success: false, error: 'error');

      final metrics = tracker.getMetrics('Model1')!;
      expect(metrics.totalInferences, 3);
      expect(metrics.successfulInferences, 2);
      expect(metrics.failedInferences, 1);
    });

    test('allMetrics retorna todas las métricas', () {
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model2', 20, success: true);

      expect(tracker.allMetrics.length, 2);
      expect(tracker.allMetrics.containsKey('Model1'), true);
      expect(tracker.allMetrics.containsKey('Model2'), true);
    });

    test('totalInferences suma todas las inferencias', () {
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model2', 10, success: true);

      expect(tracker.totalInferences, 3);
    });

    test('totalSuccessfulInferences suma solo éxitos', () {
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model1', 0, success: false, error: 'e');
      tracker.recordInference('Model2', 10, success: true);

      expect(tracker.totalSuccessfulInferences, 2);
    });

    test('globalSuccessRate calcula tasa global', () {
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model1', 0, success: false, error: 'e');
      tracker.recordInference('Model2', 10, success: true);

      expect(tracker.globalSuccessRate, 0.75);
    });

    test('mostUsedModel identifica modelo más usado', () {
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model2', 10, success: true);
      tracker.recordInference('Model2', 10, success: true);
      tracker.recordInference('Model2', 10, success: true);

      expect(tracker.mostUsedModel, 'Model2');
    });

    test('fastestModel identifica modelo más rápido', () {
      tracker.recordInference('SlowModel', 100, success: true);
      tracker.recordInference('FastModel', 5, success: true);
      tracker.recordInference('MediumModel', 50, success: true);

      expect(tracker.fastestModel, 'FastModel');
    });

    test('reset limpia todo el tracker', () {
      tracker.recordInitialization(100);
      tracker.recordInference('Model1', 10, success: true);
      tracker.reset();

      expect(tracker.initializationDurationMs, 0);
      expect(tracker.allMetrics.isEmpty, true);
      expect(tracker.totalInferences, 0);
    });

    test('generateReport genera reporte completo', () {
      tracker.recordInitialization(100);
      tracker.recordInference('Model1', 10, success: true);

      final report = tracker.generateReport();

      expect(report.containsKey('initialization'), true);
      expect(report.containsKey('global'), true);
      expect(report.containsKey('models'), true);
      expect(report['initialization']['duration_ms'], 100);
      expect(report['global']['total_inferences'], 1);
    });

    test('toString genera reporte legible', () {
      tracker.recordInference('TestModel', 10, success: true);
      final str = tracker.toString();

      expect(str.contains('MLPerformanceTracker'), true);
      expect(str.contains('TestModel'), true);
    });

    test('globalAverageTimeMs calcula promedio ponderado', () {
      // 2 inferencias de 10ms = 20ms total
      tracker.recordInference('Model1', 10, success: true);
      tracker.recordInference('Model1', 10, success: true);
      // 1 inferencia de 40ms = 40ms total
      tracker.recordInference('Model2', 40, success: true);

      // Total: 60ms / 3 inferencias = 20ms promedio
      expect(tracker.globalAverageTimeMs, 20.0);
    });
  });

  group('Edge Cases', () {
    late MLPerformanceTracker tracker;

    setUp(() {
      tracker = MLPerformanceTracker();
      tracker.reset();
    });

    test('mostUsedModel retorna null sin métricas', () {
      expect(tracker.mostUsedModel, isNull);
    });

    test('fastestModel retorna null sin inferencias exitosas', () {
      tracker.recordInference('Model1', 0, success: false, error: 'e');
      expect(tracker.fastestModel, isNull);
    });

    test('globalSuccessRate retorna 0 sin inferencias', () {
      expect(tracker.globalSuccessRate, 0);
    });

    test('globalAverageTimeMs retorna 0 sin inferencias exitosas', () {
      tracker.recordInference('Model1', 0, success: false, error: 'e');
      expect(tracker.globalAverageTimeMs, 0);
    });

    test('ModelMetrics maneja cola de muestras recientes', () {
      final metrics = ModelMetrics('TestModel');

      // Agregar más de 100 muestras
      for (int i = 0; i < 150; i++) {
        metrics.recordSuccess(10);
      }

      // La cola debe mantener solo las últimas 100
      expect(metrics.recentAverageTimeMs, 10.0);
    });
  });
}
