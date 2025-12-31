import '../utils/ml_constants.dart';
import 'interaction_history.dart';

/// Resultado de predicción del modelo ActionPredictor
///
/// Contiene las probabilidades de cada acción que el usuario
/// podría realizar a continuación.
class ActionPrediction {
  ActionPrediction({
    required this.probabilities,
    required this.predictedAction,
    required this.confidence,
    required this.timestamp,
  });

  /// Probabilidades para cada acción (6 valores, suma ~1.0)
  final List<double> probabilities;

  /// Acción con mayor probabilidad
  final PredictedAction predictedAction;

  /// Confianza de la predicción (0.0 - 1.0)
  final double confidence;

  /// Momento de la predicción
  final DateTime timestamp;

  /// Crea una predicción desde las probabilidades del modelo
  factory ActionPrediction.fromProbabilities(List<double> probs) {
    if (probs.length != MLFeatureConfig.actionPredictorOutputSize) {
      throw ArgumentError(
        'Se esperaban ${MLFeatureConfig.actionPredictorOutputSize} probabilidades, '
        'pero se recibieron ${probs.length}',
      );
    }

    // Encontrar índice con mayor probabilidad
    int maxIdx = 0;
    double maxProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIdx = i;
      }
    }

    return ActionPrediction(
      probabilities: List.unmodifiable(probs),
      predictedAction: PredictedAction.fromIndex(maxIdx),
      confidence: maxProb,
      timestamp: DateTime.now(),
    );
  }

  /// Obtiene las top N acciones más probables
  List<MapEntry<PredictedAction, double>> getTopActions(int n) {
    final actionList = <MapEntry<PredictedAction, double>>[];
    for (int i = 0; i < probabilities.length; i++) {
      actionList.add(MapEntry(PredictedAction.fromIndex(i), probabilities[i]));
    }
    actionList.sort((a, b) => b.value.compareTo(a.value));
    return actionList.take(n).toList();
  }

  /// Verifica si la predicción tiene alta confianza (>70%)
  bool get isHighConfidence => confidence > 0.7;

  /// Verifica si la predicción tiene confianza media (40-70%)
  bool get isMediumConfidence => confidence > 0.4 && confidence <= 0.7;

  /// Verifica si la predicción tiene baja confianza (<40%)
  bool get isLowConfidence => confidence <= 0.4;

  /// Convierte la acción predicha a InteractionType
  InteractionType? get interactionType {
    switch (predictedAction) {
      case PredictedAction.feed:
        return InteractionType.feed;
      case PredictedAction.play:
        return InteractionType.play;
      case PredictedAction.clean:
        return InteractionType.clean;
      case PredictedAction.rest:
        return InteractionType.rest;
      case PredictedAction.minigame:
        return InteractionType.minigame;
      case PredictedAction.other:
        return null;
    }
  }

  /// Convierte la predicción a una sugerencia de IA
  MLSuggestion toSuggestion({required String petName}) {
    final action = interactionType;
    String message;
    MLSuggestionType type;

    if (isHighConfidence) {
      type = MLSuggestionType.confident;
      message = _getConfidentMessage(petName);
    } else if (isMediumConfidence) {
      type = MLSuggestionType.suggestion;
      message = _getSuggestionMessage(petName);
    } else {
      type = MLSuggestionType.hint;
      message = _getHintMessage(petName);
    }

    return MLSuggestion(
      type: type,
      message: message,
      action: action,
      confidence: confidence,
      predictedAction: predictedAction,
    );
  }

  String _getConfidentMessage(String petName) {
    switch (predictedAction) {
      case PredictedAction.feed:
        return '$petName tiene hambre. ¡Es hora de comer!';
      case PredictedAction.play:
        return '$petName quiere jugar contigo.';
      case PredictedAction.clean:
        return '$petName necesita un baño.';
      case PredictedAction.rest:
        return '$petName está cansado. Déjalo descansar.';
      case PredictedAction.minigame:
        return '¡$petName quiere jugar un mini-juego!';
      case PredictedAction.other:
        return '$petName está bien por ahora.';
    }
  }

  String _getSuggestionMessage(String petName) {
    switch (predictedAction) {
      case PredictedAction.feed:
        return 'Quizás $petName tenga un poco de hambre.';
      case PredictedAction.play:
        return '$petName podría querer jugar.';
      case PredictedAction.clean:
        return 'Podrías limpiar a $petName.';
      case PredictedAction.rest:
        return '$petName parece algo cansado.';
      case PredictedAction.minigame:
        return '¿Qué tal un mini-juego con $petName?';
      case PredictedAction.other:
        return '$petName está tranquilo.';
    }
  }

  String _getHintMessage(String petName) {
    switch (predictedAction) {
      case PredictedAction.feed:
        return 'Considera alimentar a $petName.';
      case PredictedAction.play:
        return 'Considera jugar con $petName.';
      case PredictedAction.clean:
        return 'Considera limpiar a $petName.';
      case PredictedAction.rest:
        return 'Considera dejar descansar a $petName.';
      case PredictedAction.minigame:
        return 'Los mini-juegos son divertidos.';
      case PredictedAction.other:
        return '$petName espera tu decisión.';
    }
  }

  @override
  String toString() {
    return 'ActionPrediction(action: ${predictedAction.displayName}, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Tipo de sugerencia generada por ML
enum MLSuggestionType {
  confident('Predicción', '🎯'),
  suggestion('Sugerencia', '💡'),
  hint('Idea', '💭');

  final String displayName;
  final String emoji;

  const MLSuggestionType(this.displayName, this.emoji);
}

/// Sugerencia generada por el modelo ML
class MLSuggestion {
  final MLSuggestionType type;
  final String message;
  final InteractionType? action;
  final double confidence;
  final PredictedAction predictedAction;

  MLSuggestion({
    required this.type,
    required this.message,
    required this.action,
    required this.confidence,
    required this.predictedAction,
  });

  /// Prioridad basada en confianza (mayor = más urgente)
  int get priority => (confidence * 10).round();

  @override
  String toString() {
    return 'MLSuggestion(${type.displayName}: $message, '
        'confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
  }
}

/// Resultado de predicción del modelo CriticalTimePredictor
///
/// Predice cuántos minutos faltan para que cada métrica
/// alcance un estado crítico.
class CriticalTimePrediction {
  CriticalTimePrediction({
    required this.minutesToCritical,
    required this.mostUrgent,
    required this.urgencyScore,
    required this.timestamp,
  });

  /// Minutos hasta estado crítico para cada métrica
  /// [hunger, happiness, energy, health]
  final List<double> minutesToCritical;

  /// Métrica más urgente (menos tiempo hasta crítico)
  final CriticalMetric mostUrgent;

  /// Score de urgencia general (0.0 = sin urgencia, 1.0 = crítico ahora)
  final double urgencyScore;

  /// Momento de la predicción
  final DateTime timestamp;

  /// Crea una predicción desde los valores del modelo
  factory CriticalTimePrediction.fromModelOutput(List<double> output) {
    if (output.length != MLFeatureConfig.criticalTimePredictorOutputSize) {
      throw ArgumentError(
        'Se esperaban ${MLFeatureConfig.criticalTimePredictorOutputSize} valores, '
        'pero se recibieron ${output.length}',
      );
    }

    // Encontrar métrica más urgente
    int minIndex = 0;
    double minTime = output[0];
    for (int i = 1; i < output.length; i++) {
      if (output[i] < minTime && output[i] > 0) {
        minTime = output[i];
        minIndex = i;
      }
    }

    // Calcular urgencia (inverso del tiempo mínimo, normalizado)
    final urgency = minTime > 0 ? (1.0 - (minTime / 180.0)).clamp(0.0, 1.0) : 1.0;

    return CriticalTimePrediction(
      minutesToCritical: List.unmodifiable(output),
      mostUrgent: CriticalMetric.fromIndex(minIndex),
      urgencyScore: urgency,
      timestamp: DateTime.now(),
    );
  }

  /// Obtiene minutos hasta crítico para una métrica específica
  double getMinutesFor(CriticalMetric metric) {
    return minutesToCritical[metric.id];
  }

  /// Verifica si alguna métrica está en estado urgente (<30 min)
  bool get isUrgent => minutesToCritical.any((m) => m < 30 && m > 0);

  /// Verifica si alguna métrica está en estado crítico (<10 min)
  bool get isCritical => minutesToCritical.any((m) => m < 10 && m > 0);

  @override
  String toString() {
    return 'CriticalTimePrediction(mostUrgent: ${mostUrgent.displayName}, '
        'minutes: ${getMinutesFor(mostUrgent).toStringAsFixed(0)}, '
        'urgency: ${(urgencyScore * 100).toStringAsFixed(0)}%)';
  }
}

/// Resultado de predicción del modelo ActionRecommender
///
/// Proporciona recomendaciones personalizadas basadas en
/// el historial y personalidad de la mascota.
class ActionRecommendation {
  ActionRecommendation({
    required this.scores,
    required this.recommendedAction,
    required this.urgency,
    required this.reason,
    required this.timestamp,
  });

  /// Scores de recomendación para cada acción (0.0 - 1.0)
  final List<double> scores;

  /// Acción más recomendada
  final PredictedAction recommendedAction;

  /// Nivel de urgencia de la recomendación (0.0 - 1.0)
  final double urgency;

  /// Razón de la recomendación (generada basada en scores)
  final String reason;

  /// Momento de la recomendación
  final DateTime timestamp;

  /// Crea una recomendación desde los valores del modelo
  factory ActionRecommendation.fromModelOutput(List<double> output) {
    if (output.length != MLFeatureConfig.actionRecommenderOutputSize) {
      throw ArgumentError(
        'Se esperaban ${MLFeatureConfig.actionRecommenderOutputSize} valores, '
        'pero se recibieron ${output.length}',
      );
    }

    // Los primeros 6 valores son scores, el último es urgencia
    final scores = output.sublist(0, 6);
    final urgency = output[6].clamp(0.0, 1.0);

    // Encontrar acción con mayor score
    int maxIndex = 0;
    double maxScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    final action = PredictedAction.fromIndex(maxIndex);
    final reason = _generateReason(action, maxScore, urgency);

    return ActionRecommendation(
      scores: List.unmodifiable(scores),
      recommendedAction: action,
      urgency: urgency,
      reason: reason,
      timestamp: DateTime.now(),
    );
  }

  static String _generateReason(
    PredictedAction action,
    double score,
    double urgency,
  ) {
    if (urgency > 0.8) {
      return '¡Tu mascota necesita ${action.displayName.toLowerCase()} urgentemente!';
    } else if (urgency > 0.5) {
      return 'Sería bueno ${action.displayName.toLowerCase()} pronto';
    } else if (score > 0.7) {
      return 'Tu mascota disfrutaría ${action.displayName.toLowerCase()}';
    } else {
      return 'Podrías considerar ${action.displayName.toLowerCase()}';
    }
  }

  /// Verifica si la recomendación es urgente
  bool get isUrgent => urgency > 0.7;

  @override
  String toString() {
    return 'ActionRecommendation(action: ${recommendedAction.displayName}, '
        'urgency: ${(urgency * 100).toStringAsFixed(0)}%)';
  }
}

/// Resultado de predicción del modelo EmotionClassifier
///
/// Clasifica el estado emocional óptimo basado en el contexto actual.
class EmotionPrediction {
  EmotionPrediction({
    required this.probabilities,
    required this.predictedEmotion,
    required this.emotionIndex,
    required this.confidence,
    required this.timestamp,
  });

  /// Probabilidades para cada estado emocional (8 valores)
  final List<double> probabilities;

  /// Estado emocional predicho
  final String predictedEmotion;

  /// Índice del estado emocional (0-7)
  final int emotionIndex;

  /// Confianza de la predicción
  final double confidence;

  /// Momento de la predicción
  final DateTime timestamp;

  /// Nombres de los estados emocionales
  static const List<String> emotionNames = [
    'Extasiado',
    'Feliz',
    'Contento',
    'Neutral',
    'Aburrido',
    'Triste',
    'Solo',
    'Ansioso',
  ];

  /// Emojis para cada estado emocional
  static const List<String> emotionEmojis = [
    '🤩',
    '😊',
    '🙂',
    '😐',
    '😑',
    '😢',
    '😔',
    '😰',
  ];

  /// Crea una predicción desde las probabilidades del modelo
  factory EmotionPrediction.fromProbabilities(List<double> probs) {
    if (probs.length != MLFeatureConfig.emotionClassifierOutputSize) {
      throw ArgumentError(
        'Se esperaban ${MLFeatureConfig.emotionClassifierOutputSize} probabilidades, '
        'pero se recibieron ${probs.length}',
      );
    }

    // Encontrar índice con mayor probabilidad
    int maxIdx = 0;
    double maxProb = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        maxIdx = i;
      }
    }

    return EmotionPrediction(
      probabilities: List.unmodifiable(probs),
      predictedEmotion: emotionNames[maxIdx],
      emotionIndex: maxIdx,
      confidence: maxProb,
      timestamp: DateTime.now(),
    );
  }

  /// Obtiene el emoji del estado emocional predicho
  String get emoji => emotionEmojis[emotionIndex];

  /// Verifica si el estado emocional es positivo (índice 0-2)
  bool get isPositive => emotionIndex <= 2;

  /// Verifica si el estado emocional es negativo (índice 5-7)
  bool get isNegative => emotionIndex >= 5;

  /// Verifica si el estado emocional es neutral (índice 3-4)
  bool get isNeutral => emotionIndex == 3 || emotionIndex == 4;

  @override
  String toString() {
    return 'EmotionPrediction(emotion: $predictedEmotion $emoji, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Estado general del sistema ML
class MLStatus {
  MLStatus({
    required this.isInitialized,
    required this.availableModels,
    required this.lastInferenceTime,
    this.error,
  });

  /// Si el sistema ML está inicializado
  final bool isInitialized;

  /// Lista de modelos disponibles
  final List<String> availableModels;

  /// Tiempo de la última inferencia exitosa
  final DateTime? lastInferenceTime;

  /// Error si hubo alguno durante inicialización
  final String? error;

  /// Crea un estado de error
  factory MLStatus.error(String errorMessage) {
    return MLStatus(
      isInitialized: false,
      availableModels: [],
      lastInferenceTime: null,
      error: errorMessage,
    );
  }

  /// Crea un estado no inicializado
  factory MLStatus.notInitialized() {
    return MLStatus(
      isInitialized: false,
      availableModels: [],
      lastInferenceTime: null,
    );
  }

  @override
  String toString() {
    if (!isInitialized) {
      return 'MLStatus(not initialized${error != null ? ', error: $error' : ''})';
    }
    return 'MLStatus(initialized, models: ${availableModels.length})';
  }
}
