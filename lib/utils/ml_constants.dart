/// Constantes y configuración para el sistema de Machine Learning
///
/// Contiene rutas de modelos, nombres de features, y configuración
/// para el sistema de inferencia TensorFlow Lite.
library;

/// Rutas de los modelos TensorFlow Lite en assets
class MLModelPaths {
  MLModelPaths._();

  /// Modelo para predecir la próxima acción del usuario
  static const String actionPredictor = 'assets/models/action_predictor.tflite';

  /// Modelo para predecir tiempo hasta estado crítico
  static const String criticalTimePredictor =
      'assets/models/critical_time.tflite';

  /// Modelo para recomendar acciones personalizadas
  static const String actionRecommender =
      'assets/models/action_recommender.tflite';

  /// Modelo para clasificar estado emocional óptimo
  static const String emotionClassifier =
      'assets/models/emotion_classifier.tflite';
}

/// Configuración de features para cada modelo
class MLFeatureConfig {
  MLFeatureConfig._();

  /// Número de features de entrada para ActionPredictor
  static const int actionPredictorInputSize = 15;

  /// Número de clases de salida para ActionPredictor
  static const int actionPredictorOutputSize = 6;

  /// Número de features de entrada para CriticalTimePredictor
  static const int criticalTimePredictorInputSize = 20;

  /// Número de salidas para CriticalTimePredictor (4 métricas)
  static const int criticalTimePredictorOutputSize = 4;

  /// Número de features de entrada para ActionRecommender
  static const int actionRecommenderInputSize = 25;

  /// Número de salidas para ActionRecommender (6 scores + 1 urgencia)
  static const int actionRecommenderOutputSize = 7;

  /// Número de features de entrada para EmotionClassifier
  static const int emotionClassifierInputSize = 16;

  /// Número de estados emocionales (salidas)
  static const int emotionClassifierOutputSize = 8;
}

/// Tipos de acciones que el modelo puede predecir
enum PredictedAction {
  feed(0, 'Alimentar', '🍔'),
  play(1, 'Jugar', '🎮'),
  clean(2, 'Limpiar', '🧼'),
  rest(3, 'Descansar', '😴'),
  minigame(4, 'Mini-juego', '🎯'),
  other(5, 'Otra', '❓');

  const PredictedAction(this.id, this.displayName, this.emoji);

  final int id;
  final String displayName;
  final String emoji;

  /// Obtiene la acción desde un índice
  static PredictedAction fromIndex(int idx) {
    return PredictedAction.values.firstWhere(
      (action) => action.id == idx,
      orElse: () => PredictedAction.other,
    );
  }
}

/// Métricas que pueden alcanzar estado crítico
enum CriticalMetric {
  hunger(0, 'Hambre', 70.0),
  happiness(1, 'Felicidad', 30.0),
  energy(2, 'Energía', 20.0),
  health(3, 'Salud', 30.0);

  const CriticalMetric(this.id, this.displayName, this.criticalThreshold);

  final int id;
  final String displayName;

  /// Umbral en el que la métrica se considera crítica
  final double criticalThreshold;

  static CriticalMetric fromIndex(int idx) {
    return CriticalMetric.values.firstWhere(
      (metric) => metric.id == idx,
      orElse: () => CriticalMetric.hunger,
    );
  }
}

/// Configuración de rendimiento para inferencia ML
class MLPerformanceConfig {
  MLPerformanceConfig._();

  /// Tiempo máximo de espera para inferencia (ms)
  static const int inferenceTimeoutMs = 1000;

  /// Umbral para considerar inferencia lenta (ms)
  static const int slowInferenceThresholdMs = 100;

  /// Número de threads para inferencia (0 = automático)
  static const int numThreads = 2;

  /// Usar GPU delegate si está disponible
  static const bool useGpuDelegate = false;

  /// Usar NNAPI delegate en Android si está disponible
  static const bool useNnapiDelegate = true;
}

/// Versiones de los modelos para tracking
class MLModelVersions {
  MLModelVersions._();

  static const String actionPredictor = '1.0.0';
  static const String criticalTimePredictor = '1.0.0';
  static const String actionRecommender = '1.0.0';
  static const String emotionClassifier = '1.0.0';
}
