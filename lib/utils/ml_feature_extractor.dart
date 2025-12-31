import '../models/pet.dart';
import '../models/pet_personality.dart';
import '../models/interaction_history.dart';
import 'ml_constants.dart';

/// Extractor de features para modelos ML
///
/// Genera vectores de features normalizados (0-1) para cada modelo TFLite.
/// Cada modelo tiene su propio formato de entrada optimizado.
class MLFeatureExtractor {
  MLFeatureExtractor._();

  // ============================================================
  // ActionPredictor Features (15 features)
  // ============================================================

  /// Extrae features para predecir la próxima acción del usuario
  ///
  /// Features:
  /// 0: hunger (0-1)
  /// 1: happiness (0-1)
  /// 2: energy (0-1)
  /// 3: health (0-1)
  /// 4: emotional_state (0-1)
  /// 5: bond_level (0-1)
  /// 6: proactive_ratio (0-1)
  /// 7: time_of_day (0-1)
  /// 8: day_of_week (0-1)
  /// 9: minutes_since_last_interaction (0-1, capped at 360)
  /// 10: last_action_feed (0 or 1)
  /// 11: last_action_play (0 or 1)
  /// 12: last_action_clean (0 or 1)
  /// 13: last_action_rest (0 or 1)
  /// 14: last_action_minigame (0 or 1)
  static List<double> extractActionPredictorFeatures({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final features = List<double>.filled(
      MLFeatureConfig.actionPredictorInputSize,
      0.0,
    );

    // Métricas de la mascota
    features[0] = pet.hunger / 100;
    features[1] = pet.happiness / 100;
    features[2] = pet.energy / 100;
    features[3] = pet.health / 100;

    // Estado emocional y vínculo
    features[4] = personality.emotionalState.value;
    features[5] = personality.bondLevel.index / 4; // 5 niveles (0-4)

    // Patrones de comportamiento
    features[6] = history.proactiveRatio;

    // Contexto temporal
    features[7] = DateTime.now().hour / 24;
    features[8] = (DateTime.now().weekday - 1) / 6; // 0-1

    // Tiempo desde última interacción
    final minutesSinceLast = history.interactions.isNotEmpty
        ? DateTime.now()
            .difference(history.interactions.last.timestamp)
            .inMinutes
        : 0;
    features[9] = (minutesSinceLast / 360).clamp(0.0, 1.0);

    // One-hot encoding de última acción
    if (history.interactions.isNotEmpty) {
      final lastAction = history.interactions.last.type;
      switch (lastAction) {
        case InteractionType.feed:
          features[10] = 1.0;
          break;
        case InteractionType.play:
          features[11] = 1.0;
          break;
        case InteractionType.clean:
          features[12] = 1.0;
          break;
        case InteractionType.rest:
          features[13] = 1.0;
          break;
        case InteractionType.minigame:
          features[14] = 1.0;
          break;
        default:
          break;
      }
    }

    return features;
  }

  // ============================================================
  // CriticalTimePredictor Features (20 features)
  // ============================================================

  /// Extrae features para predecir tiempo hasta estado crítico
  ///
  /// Features incluyen métricas actuales, tasas de cambio históricas,
  /// y contexto de personalidad para predicción más precisa.
  static List<double> extractCriticalTimeFeatures({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final features = List<double>.filled(
      MLFeatureConfig.criticalTimePredictorInputSize,
      0.0,
    );

    // Métricas actuales (0-3)
    features[0] = pet.hunger / 100;
    features[1] = pet.happiness / 100;
    features[2] = pet.energy / 100;
    features[3] = pet.health / 100;

    // Tasas de cambio estimadas basadas en historial (4-7)
    final recentInteractions = history.getInteractionsLastHours(2);
    if (recentInteractions.length >= 2) {
      features[4] = _estimateHungerRate(recentInteractions);
      features[5] = _estimateHappinessRate(recentInteractions);
      features[6] = _estimateEnergyRate(recentInteractions);
      features[7] = _estimateHealthRate(recentInteractions);
    } else {
      // Tasas por defecto si no hay suficiente historial
      features[4] = 0.5;
      features[5] = 0.5;
      features[6] = 0.5;
      features[7] = 0.5;
    }

    // Traits de personalidad relevantes (8-13)
    features[8] = personality.getTraitIntensity(PersonalityTrait.foodie) / 100;
    features[9] = personality.getTraitIntensity(PersonalityTrait.playful) / 100;
    features[10] = personality.getTraitIntensity(PersonalityTrait.energetic) / 100;
    features[11] = personality.getTraitIntensity(PersonalityTrait.calm) / 100;
    features[12] = personality.getTraitIntensity(PersonalityTrait.anxious) / 100;
    features[13] = personality.bondLevel.index / 4;

    // Contexto temporal (14-16)
    features[14] = DateTime.now().hour / 24;
    features[15] = (DateTime.now().weekday - 1) / 6;
    features[16] = TimeOfDay.current.index / 4;

    // Estadísticas del usuario (17-19)
    features[17] = history.averageInteractionsPerDay / 20; // Cap at 20
    features[18] = history.proactiveRatio;
    features[19] = (personality.userPreferences.consistencyScore) / 100;

    return features;
  }

  // ============================================================
  // ActionRecommender Features (25 features)
  // ============================================================

  /// Extrae features para recomendar acciones personalizadas
  ///
  /// Incluye contexto completo de mascota, personalidad e historial
  /// para recomendaciones más precisas.
  static List<double> extractRecommenderFeatures({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final features = List<double>.filled(
      MLFeatureConfig.actionRecommenderInputSize,
      0.0,
    );

    // Métricas de mascota (0-4)
    features[0] = pet.hunger / 100;
    features[1] = pet.happiness / 100;
    features[2] = pet.energy / 100;
    features[3] = pet.health / 100;
    features[4] = personality.emotionalState.value;

    // Todos los traits de personalidad normalizados (5-16)
    int idx = 5;
    for (final trait in PersonalityTrait.values) {
      features[idx] = personality.getTraitIntensity(trait) / 100;
      idx++;
      if (idx > 16) break; // Solo usamos 12 traits
    }

    // Contexto de vínculo y preferencias (17-19)
    features[17] = personality.bondLevel.index / 4;
    features[18] = personality.bondPoints / 500; // Max esperado

    // Preferencias del usuario
    final favAction = personality.userPreferences.favoriteInteraction;
    features[19] = favAction != null ? _actionToIndex(favAction) / 5 : 0.5;

    // Distribución de interacciones recientes (20-24)
    final todayInteractions = history.todayInteractions;
    final totalToday = todayInteractions.length.clamp(1, 100);

    features[20] = _countActionType(todayInteractions, InteractionType.feed) / totalToday;
    features[21] = _countActionType(todayInteractions, InteractionType.play) / totalToday;
    features[22] = _countActionType(todayInteractions, InteractionType.clean) / totalToday;
    features[23] = _countActionType(todayInteractions, InteractionType.rest) / totalToday;
    features[24] = _countActionType(todayInteractions, InteractionType.minigame) / totalToday;

    return features;
  }

  // ============================================================
  // EmotionClassifier Features (16 features)
  // ============================================================

  /// Extrae features para clasificar estado emocional óptimo
  static List<double> extractEmotionFeatures({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final features = List<double>.filled(
      MLFeatureConfig.emotionClassifierInputSize,
      0.0,
    );

    // Métricas de mascota (0-3)
    features[0] = pet.hunger / 100;
    features[1] = pet.happiness / 100;
    features[2] = pet.energy / 100;
    features[3] = pet.health / 100;

    // Estado emocional actual y tendencia (4-5)
    features[4] = personality.emotionalState.value;
    features[5] = personality.emotionalState.index / 7; // 8 estados (0-7)

    // Traits emocionales relevantes (6-10)
    features[6] = personality.getTraitIntensity(PersonalityTrait.anxious) / 100;
    features[7] = personality.getTraitIntensity(PersonalityTrait.calm) / 100;
    features[8] = personality.getTraitIntensity(PersonalityTrait.playful) / 100;
    features[9] = personality.getTraitIntensity(PersonalityTrait.cuddly) / 100;
    features[10] = personality.getTraitIntensity(PersonalityTrait.shy) / 100;

    // Contexto de vínculo (11)
    features[11] = personality.bondLevel.index / 4;

    // Tiempo sin interacción (12)
    final minutesSinceLast = history.interactions.isNotEmpty
        ? DateTime.now()
            .difference(history.interactions.last.timestamp)
            .inMinutes
        : 0;
    features[12] = (minutesSinceLast / 360).clamp(0.0, 1.0);

    // Patrón de cuidado reciente (13-15)
    features[13] = history.proactiveRatio;
    features[14] = history.reactiveRatio;
    features[15] = (history.averageInteractionsPerDay / 10).clamp(0.0, 1.0);

    return features;
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Estima tasa de cambio de hambre basada en historial
  static double _estimateHungerRate(List<Interaction> interactions) {
    if (interactions.length < 2) return 0.5;

    double totalChange = 0;
    for (int i = 1; i < interactions.length; i++) {
      // Si la acción fue feed, el hambre bajó
      if (interactions[i].type == InteractionType.feed) {
        totalChange += 0.3; // Rata de cambio alta indica alimentación frecuente
      }
    }
    return (totalChange / interactions.length).clamp(0.0, 1.0);
  }

  /// Estima tasa de cambio de felicidad basada en historial
  static double _estimateHappinessRate(List<Interaction> interactions) {
    if (interactions.length < 2) return 0.5;

    double totalChange = 0;
    for (final interaction in interactions) {
      if (interaction.type == InteractionType.play ||
          interaction.type == InteractionType.minigame) {
        totalChange += 0.3;
      }
    }
    return (totalChange / interactions.length).clamp(0.0, 1.0);
  }

  /// Estima tasa de cambio de energía basada en historial
  static double _estimateEnergyRate(List<Interaction> interactions) {
    if (interactions.length < 2) return 0.5;

    double totalChange = 0;
    for (final interaction in interactions) {
      if (interaction.type == InteractionType.rest) {
        totalChange += 0.4;
      } else if (interaction.type == InteractionType.play) {
        totalChange -= 0.2; // Jugar gasta energía
      }
    }
    return ((totalChange / interactions.length) + 0.5).clamp(0.0, 1.0);
  }

  /// Estima tasa de cambio de salud basada en historial
  static double _estimateHealthRate(List<Interaction> interactions) {
    if (interactions.length < 2) return 0.5;

    double totalChange = 0;
    for (final interaction in interactions) {
      if (interaction.type == InteractionType.clean) {
        totalChange += 0.2;
      }
      // Cuidado proactivo mejora salud
      if (interaction.wasProactive) {
        totalChange += 0.1;
      }
    }
    return (totalChange / interactions.length + 0.5).clamp(0.0, 1.0);
  }

  /// Convierte tipo de interacción a índice
  static int _actionToIndex(InteractionType action) {
    switch (action) {
      case InteractionType.feed:
        return 0;
      case InteractionType.play:
        return 1;
      case InteractionType.clean:
        return 2;
      case InteractionType.rest:
        return 3;
      case InteractionType.minigame:
        return 4;
      default:
        return 5;
    }
  }

  /// Cuenta interacciones de un tipo específico
  static int _countActionType(List<Interaction> interactions, InteractionType type) {
    return interactions.where((i) => i.type == type).length;
  }
}

/// Registro de datos para entrenamiento ML
class MLTrainingRecord {
  /// Features de entrada
  final List<double> features;

  /// Acción que el usuario tomó
  final InteractionType actionTaken;

  /// Tiempo hasta que cada métrica alcanzó estado crítico (minutos)
  /// [hunger, happiness, energy, health]
  final List<double>? timeToCritical;

  /// Estado emocional resultante
  final EmotionalState? resultingEmotion;

  /// Timestamp del registro
  final DateTime timestamp;

  /// Métricas antes de la acción
  final Map<String, double> metricsBefore;

  /// Métricas después de la acción
  final Map<String, double>? metricsAfter;

  MLTrainingRecord({
    required this.features,
    required this.actionTaken,
    this.timeToCritical,
    this.resultingEmotion,
    required this.timestamp,
    required this.metricsBefore,
    this.metricsAfter,
  });

  /// Convierte a JSON para exportación
  Map<String, dynamic> toJson() {
    return {
      'features': features,
      'action_taken': actionTaken.id,
      'time_to_critical': timeToCritical,
      'resulting_emotion': resultingEmotion?.index,
      'timestamp': timestamp.toIso8601String(),
      'metrics_before': metricsBefore,
      'metrics_after': metricsAfter,
    };
  }

  /// Crea desde JSON
  factory MLTrainingRecord.fromJson(Map<String, dynamic> json) {
    return MLTrainingRecord(
      features: (json['features'] as List<dynamic>).cast<double>(),
      actionTaken: InteractionType.values.firstWhere(
        (t) => t.id == json['action_taken'],
        orElse: () => InteractionType.feed,
      ),
      timeToCritical: (json['time_to_critical'] as List<dynamic>?)?.cast<double>(),
      resultingEmotion: json['resulting_emotion'] != null
          ? EmotionalState.values[json['resulting_emotion'] as int]
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metricsBefore: (json['metrics_before'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      metricsAfter: json['metrics_after'] != null
          ? (json['metrics_after'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toDouble()))
          : null,
    );
  }
}
