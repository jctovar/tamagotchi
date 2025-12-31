import 'dart:collection';

/// Métricas de rendimiento para un modelo ML individual
class ModelMetrics {
  final String modelName;
  final Queue<int> _recentInferenceTimes = Queue();
  int _totalInferences = 0;
  int _successfulInferences = 0;
  int _failedInferences = 0;
  int _minTimeMs = 0;
  int _maxTimeMs = 0;
  int _totalTimeMs = 0;
  DateTime? _lastInferenceTime;
  String? _lastError;

  static const int _maxRecentSamples = 100;

  ModelMetrics(this.modelName);

  /// Registra una inferencia exitosa
  void recordSuccess(int timeMs) {
    _totalInferences++;
    _successfulInferences++;
    _totalTimeMs += timeMs;
    _lastInferenceTime = DateTime.now();

    if (_minTimeMs == 0 || timeMs < _minTimeMs) {
      _minTimeMs = timeMs;
    }
    if (timeMs > _maxTimeMs) {
      _maxTimeMs = timeMs;
    }

    _recentInferenceTimes.add(timeMs);
    while (_recentInferenceTimes.length > _maxRecentSamples) {
      _recentInferenceTimes.removeFirst();
    }
  }

  /// Registra una inferencia fallida
  void recordFailure(String error) {
    _totalInferences++;
    _failedInferences++;
    _lastError = error;
  }

  /// Total de inferencias realizadas
  int get totalInferences => _totalInferences;

  /// Inferencias exitosas
  int get successfulInferences => _successfulInferences;

  /// Inferencias fallidas
  int get failedInferences => _failedInferences;

  /// Tasa de éxito (0-1)
  double get successRate =>
      _totalInferences > 0 ? _successfulInferences / _totalInferences : 0;

  /// Tiempo promedio de inferencia en ms
  double get averageTimeMs =>
      _successfulInferences > 0 ? _totalTimeMs / _successfulInferences : 0;

  /// Tiempo mínimo de inferencia en ms
  int get minTimeMs => _minTimeMs;

  /// Tiempo máximo de inferencia en ms
  int get maxTimeMs => _maxTimeMs;

  /// Tiempo promedio de las últimas N inferencias
  double get recentAverageTimeMs {
    if (_recentInferenceTimes.isEmpty) return 0;
    final sum = _recentInferenceTimes.reduce((a, b) => a + b);
    return sum / _recentInferenceTimes.length;
  }

  /// Última vez que se ejecutó una inferencia
  DateTime? get lastInferenceTime => _lastInferenceTime;

  /// Último error registrado
  String? get lastError => _lastError;

  /// Reinicia todas las métricas
  void reset() {
    _recentInferenceTimes.clear();
    _totalInferences = 0;
    _successfulInferences = 0;
    _failedInferences = 0;
    _minTimeMs = 0;
    _maxTimeMs = 0;
    _totalTimeMs = 0;
    _lastInferenceTime = null;
    _lastError = null;
  }

  /// Convierte a mapa para serialización/analytics
  Map<String, dynamic> toMap() => {
        'model_name': modelName,
        'total_inferences': _totalInferences,
        'successful_inferences': _successfulInferences,
        'failed_inferences': _failedInferences,
        'success_rate': successRate,
        'average_time_ms': averageTimeMs,
        'recent_average_time_ms': recentAverageTimeMs,
        'min_time_ms': _minTimeMs,
        'max_time_ms': _maxTimeMs,
        'last_inference': _lastInferenceTime?.toIso8601String(),
        'last_error': _lastError,
      };

  @override
  String toString() =>
      'ModelMetrics($modelName: $successfulInferences/$totalInferences ok, avg ${averageTimeMs.toStringAsFixed(1)}ms)';
}

/// Tracker de rendimiento para todos los modelos ML
///
/// Uso:
/// ```dart
/// final tracker = MLPerformanceTracker();
/// final stopwatch = Stopwatch()..start();
/// // ... ejecutar inferencia ...
/// stopwatch.stop();
/// tracker.recordInference('ActionPredictor', stopwatch.elapsedMilliseconds, success: true);
/// ```
class MLPerformanceTracker {
  // Singleton
  static final MLPerformanceTracker _instance = MLPerformanceTracker._internal();
  factory MLPerformanceTracker() => _instance;
  MLPerformanceTracker._internal();

  final Map<String, ModelMetrics> _modelMetrics = {};
  DateTime? _initializationTime;
  int _initializationDurationMs = 0;

  /// Registra el tiempo de inicialización del servicio ML
  void recordInitialization(int durationMs) {
    _initializationTime = DateTime.now();
    _initializationDurationMs = durationMs;
  }

  /// Registra una inferencia para un modelo
  void recordInference(
    String modelName,
    int timeMs, {
    required bool success,
    String? error,
  }) {
    _modelMetrics.putIfAbsent(modelName, () => ModelMetrics(modelName));
    final metrics = _modelMetrics[modelName]!;

    if (success) {
      metrics.recordSuccess(timeMs);
    } else {
      metrics.recordFailure(error ?? 'Unknown error');
    }
  }

  /// Obtiene las métricas de un modelo específico
  ModelMetrics? getMetrics(String modelName) => _modelMetrics[modelName];

  /// Obtiene todas las métricas
  Map<String, ModelMetrics> get allMetrics =>
      Map.unmodifiable(_modelMetrics);

  /// Tiempo de inicialización del servicio
  int get initializationDurationMs => _initializationDurationMs;

  /// Cuándo se inicializó el servicio
  DateTime? get initializationTime => _initializationTime;

  /// Total de inferencias en todos los modelos
  int get totalInferences =>
      _modelMetrics.values.fold(0, (sum, m) => sum + m.totalInferences);

  /// Total de inferencias exitosas
  int get totalSuccessfulInferences =>
      _modelMetrics.values.fold(0, (sum, m) => sum + m.successfulInferences);

  /// Tasa de éxito global
  double get globalSuccessRate =>
      totalInferences > 0 ? totalSuccessfulInferences / totalInferences : 0;

  /// Tiempo promedio global de inferencia
  double get globalAverageTimeMs {
    final totalTime =
        _modelMetrics.values.fold(0.0, (sum, m) => sum + m.averageTimeMs * m.successfulInferences);
    return totalSuccessfulInferences > 0
        ? totalTime / totalSuccessfulInferences
        : 0;
  }

  /// Modelo más usado
  String? get mostUsedModel {
    if (_modelMetrics.isEmpty) return null;
    return _modelMetrics.entries
        .reduce((a, b) =>
            a.value.totalInferences > b.value.totalInferences ? a : b)
        .key;
  }

  /// Modelo más rápido (por promedio)
  String? get fastestModel {
    final candidates = _modelMetrics.entries
        .where((e) => e.value.successfulInferences > 0)
        .toList();
    if (candidates.isEmpty) return null;
    return candidates
        .reduce(
            (a, b) => a.value.averageTimeMs < b.value.averageTimeMs ? a : b)
        .key;
  }

  /// Reinicia todas las métricas
  void reset() {
    _modelMetrics.clear();
    _initializationTime = null;
    _initializationDurationMs = 0;
  }

  /// Genera un resumen completo
  Map<String, dynamic> generateReport() => {
        'initialization': {
          'time': _initializationTime?.toIso8601String(),
          'duration_ms': _initializationDurationMs,
        },
        'global': {
          'total_inferences': totalInferences,
          'successful_inferences': totalSuccessfulInferences,
          'success_rate': globalSuccessRate,
          'average_time_ms': globalAverageTimeMs,
          'most_used_model': mostUsedModel,
          'fastest_model': fastestModel,
        },
        'models': _modelMetrics.map((k, v) => MapEntry(k, v.toMap())),
      };

  @override
  String toString() {
    final buffer = StringBuffer('MLPerformanceTracker Report\n');
    buffer.writeln('=' * 40);
    buffer.writeln('Total inferencias: $totalInferences');
    buffer.writeln('Tasa de éxito: ${(globalSuccessRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('Tiempo promedio: ${globalAverageTimeMs.toStringAsFixed(1)}ms');
    buffer.writeln('\nPor modelo:');
    for (final entry in _modelMetrics.entries) {
      buffer.writeln('  ${entry.value}');
    }
    return buffer.toString();
  }
}
