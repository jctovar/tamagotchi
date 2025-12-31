import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/ml_prediction.dart';
import '../models/pet.dart';
import '../models/pet_personality.dart';
import '../models/interaction_history.dart';
import '../utils/ml_constants.dart';
import '../utils/ml_performance_tracker.dart';
import 'analytics_service.dart';

/// Servicio de Machine Learning para inferencia con TensorFlow Lite
///
/// Gestiona la carga de modelos, ejecución de inferencias, y proporciona
/// predicciones inteligentes basadas en el estado del pet y el comportamiento
/// del usuario.
///
/// Uso:
/// ```dart
/// final mlService = MLService();
/// await mlService.initialize();
///
/// final prediction = await mlService.predictNextAction(
///   pet: myPet,
///   personality: myPersonality,
///   history: myHistory,
/// );
/// ```
class MLService {
  // Singleton
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  // Interpreters para cada modelo
  Interpreter? _actionPredictor;
  Interpreter? _criticalTimePredictor;
  Interpreter? _actionRecommender;
  Interpreter? _emotionClassifier;

  // Estado
  bool _isInitialized = false;
  String? _lastError;
  DateTime? _lastInferenceTime;
  final List<String> _availableModels = [];

  // Performance tracking
  final MLPerformanceTracker _performanceTracker = MLPerformanceTracker();

  /// Indica si el servicio está inicializado y listo para usar
  bool get isInitialized => _isInitialized;

  /// Último error durante inicialización o inferencia
  String? get lastError => _lastError;

  /// Tiempo de la última inferencia exitosa
  DateTime? get lastInferenceTime => _lastInferenceTime;

  /// Lista de modelos disponibles
  List<String> get availableModels => List.unmodifiable(_availableModels);

  /// Tracker de rendimiento para métricas de inferencia
  MLPerformanceTracker get performanceTracker => _performanceTracker;

  /// Obtiene el estado actual del servicio ML
  MLStatus get status => MLStatus(
        isInitialized: _isInitialized,
        availableModels: _availableModels,
        lastInferenceTime: _lastInferenceTime,
        error: _lastError,
      );

  /// Inicializa el servicio cargando todos los modelos disponibles
  ///
  /// Si un modelo no está disponible, se ignora y se continúa con los demás.
  /// El servicio se considera inicializado si al menos un modelo se cargó.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[MLService] Ya está inicializado');
      return;
    }

    debugPrint('[MLService] Iniciando inicialización...');
    final stopwatch = Stopwatch()..start();
    _availableModels.clear();
    _lastError = null;

    // Intentar cargar cada modelo
    await _loadModel(
      MLModelPaths.actionPredictor,
      'ActionPredictor',
      (interpreter) => _actionPredictor = interpreter,
    );

    await _loadModel(
      MLModelPaths.criticalTimePredictor,
      'CriticalTimePredictor',
      (interpreter) => _criticalTimePredictor = interpreter,
    );

    await _loadModel(
      MLModelPaths.actionRecommender,
      'ActionRecommender',
      (interpreter) => _actionRecommender = interpreter,
    );

    await _loadModel(
      MLModelPaths.emotionClassifier,
      'EmotionClassifier',
      (interpreter) => _emotionClassifier = interpreter,
    );

    stopwatch.stop();
    _isInitialized = _availableModels.isNotEmpty;

    // Registrar métricas de inicialización
    _performanceTracker.recordInitialization(stopwatch.elapsedMilliseconds);

    // Log a Analytics
    AnalyticsService.logMLServiceInitialized(
      modelsLoaded: _availableModels,
      initializationTimeMs: stopwatch.elapsedMilliseconds,
      success: _isInitialized,
    );

    if (_isInitialized) {
      debugPrint(
          '[MLService] Inicializado con ${_availableModels.length} modelos en ${stopwatch.elapsedMilliseconds}ms');
    } else {
      debugPrint('[MLService] No se pudo cargar ningún modelo');
      _lastError ??= 'No se encontraron modelos ML';
    }
  }

  /// Carga un modelo individual
  Future<void> _loadModel(
    String path,
    String name,
    void Function(Interpreter) onLoaded,
  ) async {
    try {
      final options = InterpreterOptions()
        ..threads = MLPerformanceConfig.numThreads;

      final interpreter = await Interpreter.fromAsset(path, options: options);
      onLoaded(interpreter);
      _availableModels.add(name);
      debugPrint('[MLService] Modelo $name cargado correctamente');
    } catch (e) {
      debugPrint('[MLService] No se pudo cargar modelo $name: $e');
      // No es un error crítico, simplemente el modelo no está disponible
    }
  }

  /// Predice la próxima acción del usuario
  ///
  /// Retorna null si el modelo no está disponible o hay un error.
  Future<ActionPrediction?> predictNextAction({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    const modelName = 'ActionPredictor';

    if (_actionPredictor == null) {
      debugPrint('[MLService] $modelName no disponible');
      AnalyticsService.logMLFallback(
        modelName: modelName,
        reason: 'model_not_loaded',
      );
      return null;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Extraer features
      final features = _extractActionFeatures(pet, personality, history);

      // Preparar input/output tensors
      final input = [features];
      final output = List.filled(MLFeatureConfig.actionPredictorOutputSize, 0.0)
          .reshape([1, MLFeatureConfig.actionPredictorOutputSize]);

      // Ejecutar inferencia
      _actionPredictor!.run(input, output);

      stopwatch.stop();
      _lastInferenceTime = DateTime.now();

      // Registrar métricas
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: true,
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: true,
      );

      debugPrint(
          '[MLService] Inferencia $modelName en ${stopwatch.elapsedMilliseconds}ms');

      // Convertir a predicción
      return ActionPrediction.fromProbabilities(
        (output[0] as List).cast<double>(),
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint('[MLService] Error en predictNextAction: $e');
      debugPrint(stack.toString());
      _lastError = e.toString();

      // Registrar error
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: false,
        error: e.toString(),
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: false,
        errorType: e.runtimeType.toString(),
      );

      return null;
    }
  }

  /// Predice el tiempo hasta que cada métrica alcance estado crítico
  ///
  /// Retorna null si el modelo no está disponible o hay un error.
  Future<CriticalTimePrediction?> predictCriticalTime({
    required Pet pet,
    required InteractionHistory history,
  }) async {
    const modelName = 'CriticalTimePredictor';

    if (_criticalTimePredictor == null) {
      debugPrint('[MLService] $modelName no disponible');
      AnalyticsService.logMLFallback(
        modelName: modelName,
        reason: 'model_not_loaded',
      );
      return null;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Extraer features
      final features = _extractCriticalTimeFeatures(pet, history);

      // Preparar input/output tensors
      final input = [features];
      final output =
          List.filled(MLFeatureConfig.criticalTimePredictorOutputSize, 0.0)
              .reshape([1, MLFeatureConfig.criticalTimePredictorOutputSize]);

      // Ejecutar inferencia
      _criticalTimePredictor!.run(input, output);

      stopwatch.stop();
      _lastInferenceTime = DateTime.now();

      // Registrar métricas
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: true,
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: true,
      );

      debugPrint(
          '[MLService] Inferencia $modelName en ${stopwatch.elapsedMilliseconds}ms');

      // Convertir a predicción
      return CriticalTimePrediction.fromModelOutput(
        (output[0] as List).cast<double>(),
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint('[MLService] Error en predictCriticalTime: $e');
      debugPrint(stack.toString());
      _lastError = e.toString();

      // Registrar error
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: false,
        error: e.toString(),
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: false,
        errorType: e.runtimeType.toString(),
      );

      return null;
    }
  }

  /// Genera recomendaciones de acciones personalizadas
  ///
  /// Retorna null si el modelo no está disponible o hay un error.
  Future<ActionRecommendation?> recommendAction({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    const modelName = 'ActionRecommender';

    if (_actionRecommender == null) {
      debugPrint('[MLService] $modelName no disponible');
      AnalyticsService.logMLFallback(
        modelName: modelName,
        reason: 'model_not_loaded',
      );
      return null;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Extraer features
      final features = _extractRecommenderFeatures(pet, personality, history);

      // Preparar input/output tensors
      final input = [features];
      final output =
          List.filled(MLFeatureConfig.actionRecommenderOutputSize, 0.0)
              .reshape([1, MLFeatureConfig.actionRecommenderOutputSize]);

      // Ejecutar inferencia
      _actionRecommender!.run(input, output);

      stopwatch.stop();
      _lastInferenceTime = DateTime.now();

      // Registrar métricas
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: true,
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: true,
      );

      debugPrint(
          '[MLService] Inferencia $modelName en ${stopwatch.elapsedMilliseconds}ms');

      // Convertir a recomendación
      return ActionRecommendation.fromModelOutput(
        (output[0] as List).cast<double>(),
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint('[MLService] Error en recommendAction: $e');
      debugPrint(stack.toString());
      _lastError = e.toString();

      // Registrar error
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: false,
        error: e.toString(),
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: false,
        errorType: e.runtimeType.toString(),
      );

      return null;
    }
  }

  /// Clasifica el estado emocional óptimo
  ///
  /// Retorna null si el modelo no está disponible o hay un error.
  Future<EmotionPrediction?> classifyEmotion({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    const modelName = 'EmotionClassifier';

    if (_emotionClassifier == null) {
      debugPrint('[MLService] $modelName no disponible');
      AnalyticsService.logMLFallback(
        modelName: modelName,
        reason: 'model_not_loaded',
      );
      return null;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Extraer features
      final features = _extractEmotionFeatures(pet, personality, history);

      // Preparar input/output tensors
      final input = [features];
      final output =
          List.filled(MLFeatureConfig.emotionClassifierOutputSize, 0.0)
              .reshape([1, MLFeatureConfig.emotionClassifierOutputSize]);

      // Ejecutar inferencia
      _emotionClassifier!.run(input, output);

      stopwatch.stop();
      _lastInferenceTime = DateTime.now();

      // Registrar métricas
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: true,
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: true,
      );

      debugPrint(
          '[MLService] Inferencia $modelName en ${stopwatch.elapsedMilliseconds}ms');

      // Convertir a predicción
      return EmotionPrediction.fromProbabilities(
        (output[0] as List).cast<double>(),
      );
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint('[MLService] Error en classifyEmotion: $e');
      debugPrint(stack.toString());
      _lastError = e.toString();

      // Registrar error
      _performanceTracker.recordInference(
        modelName,
        stopwatch.elapsedMilliseconds,
        success: false,
        error: e.toString(),
      );

      AnalyticsService.logMLInference(
        modelName: modelName,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        success: false,
        errorType: e.runtimeType.toString(),
      );

      return null;
    }
  }

  // ==================== Extractores de Features ====================

  /// Extrae features para ActionPredictor (15 features)
  List<double> _extractActionFeatures(
    Pet pet,
    PetPersonality personality,
    InteractionHistory history,
  ) {
    // Obtener última acción como one-hot (4 valores)
    final lastActionOneHot = _getLastActionOneHot(history);

    return [
      // Métricas de la mascota (4)
      pet.hunger / 100.0,
      pet.happiness / 100.0,
      pet.energy / 100.0,
      pet.health / 100.0,

      // Estado emocional (1)
      personality.emotionalState.value,

      // Nivel de vínculo (1)
      personality.bondPoints / 500.0,

      // Patrones de interacción (2)
      history.proactiveRatio,
      history.reactiveRatio,

      // Frecuencia de interacciones (1)
      (history.averageInteractionsPerDay / 10.0).clamp(0.0, 1.0),

      // Contexto temporal (2)
      _getCurrentTimeOfDayNormalized(),
      DateTime.now().weekday / 7.0,

      // Última acción (one-hot, 4 valores para simplificar)
      ...lastActionOneHot,
    ];
  }

  /// Extrae features para CriticalTimePredictor (20 features)
  List<double> _extractCriticalTimeFeatures(
    Pet pet,
    InteractionHistory history,
  ) {
    // Obtener tiempos desde última acción de cada tipo
    final timeSinceActions = _getTimeSinceLastActions(history);

    return [
      // Métricas actuales (4)
      pet.hunger / 100.0,
      pet.happiness / 100.0,
      pet.energy / 100.0,
      pet.health / 100.0,

      // Tasas de cambio estimadas (4) - basadas en historial
      _estimateDecayRate(history, InteractionType.feed),
      _estimateDecayRate(history, InteractionType.play),
      _estimateDecayRate(history, InteractionType.rest),
      _estimateDecayRate(history, InteractionType.clean),

      // Tiempo desde última acción (4)
      ...timeSinceActions,

      // Patrones de usuario (4)
      history.proactiveRatio,
      history.reactiveRatio,
      (history.averageInteractionsPerDay / 10.0).clamp(0.0, 1.0),
      _getConsistencyScore(history),

      // Contexto temporal (4)
      _getCurrentTimeOfDayNormalized(),
      DateTime.now().weekday / 7.0,
      _getHoursSinceLastInteraction(history),
      _isTypicalActiveTime(history) ? 1.0 : 0.0,
    ];
  }

  /// Extrae features para ActionRecommender (25 features)
  List<double> _extractRecommenderFeatures(
    Pet pet,
    PetPersonality personality,
    InteractionHistory history,
  ) {
    // Base: 11 features existentes de generateMLFeatures()
    final baseFeatures = [
      pet.hunger / 100.0,
      pet.happiness / 100.0,
      pet.energy / 100.0,
      pet.health / 100.0,
      personality.emotionalState.value,
      personality.bondPoints / 500.0,
      history.proactiveRatio,
      history.reactiveRatio,
      (history.averageInteractionsPerDay / 10.0).clamp(0.0, 1.0),
      _getCurrentTimeOfDayNormalized(),
      DateTime.now().weekday / 7.0,
    ];

    // Agregar 12 traits de personalidad normalizados
    final traitFeatures = personality.traits.values
        .map((v) => v / 100.0)
        .take(12)
        .toList();

    // Completar si faltan traits
    while (traitFeatures.length < 12) {
      traitFeatures.add(0.5);
    }

    // Features adicionales (2)
    final additionalFeatures = [
      _getSuggestionFollowRate(history),
      _getTimeSinceLastSuggestion(history),
    ];

    return [...baseFeatures, ...traitFeatures, ...additionalFeatures];
  }

  /// Extrae features para EmotionClassifier (16 features)
  List<double> _extractEmotionFeatures(
    Pet pet,
    PetPersonality personality,
    InteractionHistory history,
  ) {
    // Historial de estados emocionales (sliding window de 8)
    final emotionHistory = _getEmotionHistory(history, 8);

    return [
      // Métricas de la mascota (4)
      pet.hunger / 100.0,
      pet.happiness / 100.0,
      pet.energy / 100.0,
      pet.health / 100.0,

      // Historial emocional (8)
      ...emotionHistory,

      // Contexto de sesión (4)
      _getSessionDurationNormalized(),
      _getInteractionsThisSession(history),
      _getCurrentTimeOfDayNormalized(),
      personality.bondPoints / 500.0,
    ];
  }

  // ==================== Helpers ====================

  List<double> _getLastActionOneHot(InteractionHistory history) {
    final lastInteraction = history.getLastInteractions(1).firstOrNull;
    final oneHot = [0.0, 0.0, 0.0, 0.0]; // feed, play, clean, rest

    if (lastInteraction != null) {
      switch (lastInteraction.type) {
        case InteractionType.feed:
          oneHot[0] = 1.0;
        case InteractionType.play:
          oneHot[1] = 1.0;
        case InteractionType.clean:
          oneHot[2] = 1.0;
        case InteractionType.rest:
          oneHot[3] = 1.0;
        default:
          break;
      }
    }
    return oneHot;
  }

  double _getCurrentTimeOfDayNormalized() {
    final hour = DateTime.now().hour;
    return hour / 24.0;
  }

  List<double> _getTimeSinceLastActions(InteractionHistory history) {
    final result = <double>[];
    final types = [
      InteractionType.feed,
      InteractionType.play,
      InteractionType.rest,
      InteractionType.clean,
    ];

    for (final type in types) {
      final last = history.interactions
          .where((i) => i.type == type)
          .toList()
          .reversed
          .firstOrNull;

      if (last != null) {
        final minutes =
            DateTime.now().difference(last.timestamp).inMinutes.toDouble();
        result.add((minutes / 1440.0).clamp(0.0, 1.0)); // Normalizado a 24h
      } else {
        result.add(1.0); // Sin registro = mucho tiempo
      }
    }

    return result;
  }

  double _estimateDecayRate(InteractionHistory history, InteractionType type) {
    // Simplificado: retorna un valor basado en la frecuencia de la acción
    final count =
        history.interactions.where((i) => i.type == type).length.toDouble();
    final total = history.interactions.length.toDouble();

    if (total == 0) return 0.5;
    return (count / total).clamp(0.0, 1.0);
  }

  double _getConsistencyScore(InteractionHistory history) {
    if (history.interactions.isEmpty) return 0.0;

    final days = history.daysActive;
    if (days == 0) return 0.0;

    final avgPerDay = history.interactions.length / days;
    return (avgPerDay / 10.0).clamp(0.0, 1.0);
  }

  double _getHoursSinceLastInteraction(InteractionHistory history) {
    final last = history.getLastInteractions(1).firstOrNull;
    if (last == null) return 1.0;

    final hours =
        DateTime.now().difference(last.timestamp).inHours.toDouble();
    return (hours / 24.0).clamp(0.0, 1.0);
  }

  bool _isTypicalActiveTime(InteractionHistory history) {
    // Simplificado: considera activo si hay interacciones recientes
    final recentCount = history.getInteractionsLastHours(2).length;
    return recentCount > 0;
  }

  double _getSuggestionFollowRate(InteractionHistory history) {
    // Simplificado: basado en ratio de interacciones proactivas
    return history.proactiveRatio;
  }

  double _getTimeSinceLastSuggestion(InteractionHistory history) {
    // Simplificado: usa última interacción como proxy
    return _getHoursSinceLastInteraction(history);
  }

  List<double> _getEmotionHistory(InteractionHistory history, int count) {
    // Simplificado: genera valores basados en interacciones recientes
    final recent = history.getLastInteractions(count);
    final result = <double>[];

    for (int i = 0; i < count; i++) {
      if (i < recent.length) {
        // Usar felicidad de la interacción como proxy de emoción
        result.add(recent[i].happinessBefore / 100.0);
      } else {
        result.add(0.5); // Neutral por defecto
      }
    }

    return result;
  }

  double _getSessionDurationNormalized() {
    // Simplificado: devuelve un valor fijo por ahora
    return 0.5;
  }

  double _getInteractionsThisSession(InteractionHistory history) {
    // Contar interacciones en la última hora
    final count = history.getInteractionsLastHours(1).length.toDouble();
    return (count / 20.0).clamp(0.0, 1.0);
  }

  /// Envía estadísticas de rendimiento a Analytics
  ///
  /// Llamar periódicamente (ej: al cerrar la app o cada N minutos)
  Future<void> flushPerformanceStats() async {
    for (final modelName in _availableModels) {
      final metrics = _performanceTracker.getMetrics(modelName);
      if (metrics != null && metrics.totalInferences > 0) {
        await AnalyticsService.logMLPerformanceStats(
          modelName: modelName,
          totalInferences: metrics.totalInferences,
          successfulInferences: metrics.successfulInferences,
          averageTimeMs: metrics.averageTimeMs,
          minTimeMs: metrics.minTimeMs.toDouble(),
          maxTimeMs: metrics.maxTimeMs.toDouble(),
        );
      }
    }
    debugPrint('[MLService] Performance stats enviados a Analytics');
  }

  /// Obtiene un reporte de rendimiento completo
  Map<String, dynamic> getPerformanceReport() =>
      _performanceTracker.generateReport();

  /// Resetea las métricas de rendimiento
  void resetPerformanceMetrics() {
    _performanceTracker.reset();
    debugPrint('[MLService] Métricas de rendimiento reseteadas');
  }

  /// Libera recursos de todos los modelos
  void dispose() {
    // Enviar stats finales antes de cerrar
    flushPerformanceStats();

    _actionPredictor?.close();
    _criticalTimePredictor?.close();
    _actionRecommender?.close();
    _emotionClassifier?.close();

    _actionPredictor = null;
    _criticalTimePredictor = null;
    _actionRecommender = null;
    _emotionClassifier = null;

    _isInitialized = false;
    _availableModels.clear();

    debugPrint('[MLService] Recursos liberados');
  }
}
