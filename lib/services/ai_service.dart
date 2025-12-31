import 'dart:math';
import '../models/pet.dart';
import '../models/interaction_history.dart';
import '../models/pet_personality.dart';
import '../models/ml_prediction.dart';
import '../utils/ml_constants.dart';
import 'ml_service.dart';

/// Servicio de IA para comportamientos adaptativos de la mascota
///
/// Este servicio analiza patrones de comportamiento del usuario,
/// aprende preferencias, y genera respuestas contextuales inteligentes.
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Random _random = Random();

  /// Genera una sugerencia basada en el estado actual y patrones
  AISuggestion? generateSuggestion({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final suggestions = <AISuggestion>[];

    // Sugerencias basadas en métricas críticas
    if (pet.hunger > 70) {
      suggestions.add(AISuggestion(
        type: SuggestionType.urgent,
        message: '${pet.name} tiene mucha hambre. ¡Aliméntalo pronto!',
        action: InteractionType.feed,
        priority: 10,
      ));
    }

    if (pet.happiness < 40) {
      suggestions.add(AISuggestion(
        type: SuggestionType.urgent,
        message: '${pet.name} está ${personality.emotionalState.displayName.toLowerCase()}. '
            'Un poco de diversión le vendría bien.',
        action: InteractionType.play,
        priority: 8,
      ));
    }

    if (pet.energy < 30) {
      suggestions.add(AISuggestion(
        type: SuggestionType.important,
        message: '${pet.name} está cansado. Necesita descansar.',
        action: InteractionType.rest,
        priority: 7,
      ));
    }

    if (pet.health < 50) {
      suggestions.add(AISuggestion(
        type: SuggestionType.urgent,
        message: 'La salud de ${pet.name} está baja. Cuídalo mejor.',
        action: InteractionType.clean,
        priority: 9,
      ));
    }

    // Sugerencias basadas en personalidad
    final dominantTrait = personality.dominantTraits.isNotEmpty
        ? personality.dominantTraits.first
        : null;

    if (dominantTrait == PersonalityTrait.playful && pet.happiness < 70) {
      suggestions.add(AISuggestion(
        type: SuggestionType.tip,
        message: 'Como ${pet.name} es tan juguetón, le encantaría jugar contigo.',
        action: InteractionType.play,
        priority: 5,
      ));
    }

    if (dominantTrait == PersonalityTrait.foodie && pet.hunger > 30) {
      suggestions.add(AISuggestion(
        type: SuggestionType.tip,
        message: '${pet.name} es un poco glotón... ¡Ya está pensando en comida!',
        action: InteractionType.feed,
        priority: 4,
      ));
    }

    // Sugerencias basadas en tiempo sin interacción
    final lastInteraction = history.interactions.isNotEmpty
        ? history.interactions.last.timestamp
        : DateTime.now();
    final minutesSinceInteraction =
        DateTime.now().difference(lastInteraction).inMinutes;

    if (minutesSinceInteraction > 60 && personality.bondLevel.index >= 2) {
      suggestions.add(AISuggestion(
        type: SuggestionType.friendly,
        message: '${pet.name} te ha extrañado. ¿Por qué no pasas tiempo con él?',
        action: null,
        priority: 3,
      ));
    }

    // Sugerencias basadas en mini-juegos
    if (history.interactionCounts[InteractionType.minigame] == 0) {
      suggestions.add(AISuggestion(
        type: SuggestionType.tip,
        message: '¡Prueba los mini-juegos! A ${pet.name} le encantará y ganarás monedas.',
        action: InteractionType.minigame,
        priority: 4,
      ));
    }

    // Ordenar por prioridad y retornar la más importante
    if (suggestions.isEmpty) return null;
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions.first;
  }

  /// Genera una sugerencia usando ML con fallback a reglas
  ///
  /// Intenta primero usar el modelo ML para predecir la acción.
  /// Si el modelo no está disponible o falla, usa las reglas heurísticas.
  Future<AISuggestion?> generateSmartSuggestion({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    // 1. Intentar usar ML
    final mlService = MLService();
    if (mlService.isInitialized) {
      try {
        final prediction = await mlService.predictNextAction(
          pet: pet,
          personality: personality,
          history: history,
        );

        if (prediction != null && prediction.confidence > 0.3) {
          final mlSuggestion = prediction.toSuggestion(petName: pet.name);

          // Convertir MLSuggestion a AISuggestion
          return AISuggestion(
            type: _mlTypeToSuggestionType(mlSuggestion.type),
            message: mlSuggestion.message,
            action: mlSuggestion.action,
            priority: mlSuggestion.priority,
          );
        }
      } catch (e) {
        // Log error pero continuar con fallback
        // En producción, loguear a Analytics
      }
    }

    // 2. Fallback a reglas heurísticas
    return generateSuggestion(
      pet: pet,
      personality: personality,
      history: history,
    );
  }

  /// Convierte tipo de sugerencia ML a tipo de sugerencia AI
  SuggestionType _mlTypeToSuggestionType(MLSuggestionType mlType) {
    switch (mlType) {
      case MLSuggestionType.confident:
        return SuggestionType.important;
      case MLSuggestionType.suggestion:
        return SuggestionType.tip;
      case MLSuggestionType.hint:
        return SuggestionType.friendly;
    }
  }

  /// Obtiene predicción ML de la próxima acción (para UI avanzada)
  Future<MLSuggestion?> getMLPrediction({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    final mlService = MLService();
    if (!mlService.isInitialized) return null;

    try {
      final prediction = await mlService.predictNextAction(
        pet: pet,
        personality: personality,
        history: history,
      );

      if (prediction == null) return null;
      return prediction.toSuggestion(petName: pet.name);
    } catch (e) {
      return null;
    }
  }

  /// Genera un mensaje contextual de la mascota
  String generatePetMessage({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final messages = <String>[];

    // Mensajes basados en estado emocional
    switch (personality.emotionalState) {
      case EmotionalState.ecstatic:
        messages.addAll([
          '¡${pet.name} está súper feliz! 🎉',
          '¡${pet.name} no puede contener su alegría! ✨',
          '${pet.name} te quiere muchísimo! 💖',
        ]);
        break;
      case EmotionalState.happy:
        messages.addAll([
          '${pet.name} está de buen humor 😊',
          '${pet.name} te mira con cariño',
          '¡Todo está bien en el mundo de ${pet.name}!',
        ]);
        break;
      case EmotionalState.content:
        messages.addAll([
          '${pet.name} está tranquilo',
          '${pet.name} parece satisfecho',
          '${pet.name} descansa plácidamente',
        ]);
        break;
      case EmotionalState.neutral:
        messages.addAll([
          '${pet.name} te observa curioso',
          '${pet.name} espera tu siguiente movimiento',
          '¿Qué harás con ${pet.name}?',
        ]);
        break;
      case EmotionalState.bored:
        messages.addAll([
          '${pet.name} bosteza... 🥱',
          '${pet.name} parece aburrido',
          '${pet.name} busca algo que hacer',
        ]);
        break;
      case EmotionalState.sad:
        messages.addAll([
          '${pet.name} está un poco triste 😢',
          '${pet.name} necesita atención',
          '${pet.name} te mira con ojos tristes',
        ]);
        break;
      case EmotionalState.lonely:
        messages.addAll([
          '${pet.name} te ha extrañado mucho 😔',
          '${pet.name} se siente solo',
          '¿Hace cuánto no juegas con ${pet.name}?',
        ]);
        break;
      case EmotionalState.anxious:
        messages.addAll([
          '${pet.name} está preocupado 😰',
          '${pet.name} necesita que lo cuides',
          '${pet.name} se siente descuidado',
        ]);
        break;
    }

    // Agregar mensajes basados en personalidad
    final dominantTrait = personality.dominantTraits.isNotEmpty
        ? personality.dominantTraits.first
        : null;

    if (dominantTrait != null) {
      switch (dominantTrait) {
        case PersonalityTrait.playful:
          messages.add('${pet.name} está listo para jugar 🎮');
          break;
        case PersonalityTrait.cuddly:
          messages.add('${pet.name} quiere mimos 🥰');
          break;
        case PersonalityTrait.curious:
          messages.add('${pet.name} explora su entorno 🔍');
          break;
        case PersonalityTrait.calm:
          messages.add('${pet.name} está sereno y relajado 😌');
          break;
        case PersonalityTrait.foodie:
          messages.add('${pet.name} piensa en su próxima comida 🍕');
          break;
        case PersonalityTrait.nocturnal:
          if (TimeOfDay.current == TimeOfDay.night ||
              TimeOfDay.current == TimeOfDay.earlyMorning) {
            messages.add('${pet.name} está más activo de noche 🦉');
          }
          break;
        case PersonalityTrait.earlyBird:
          if (TimeOfDay.current == TimeOfDay.morning) {
            messages.add('¡${pet.name} madrugó hoy! 🐓');
          }
          break;
        default:
          break;
      }
    }

    // Agregar mensajes basados en nivel de vínculo
    switch (personality.bondLevel) {
      case BondLevel.stranger:
        messages.add('${pet.name} aún está conociéndote...');
        break;
      case BondLevel.acquaintance:
        messages.add('${pet.name} está empezando a confiar en ti');
        break;
      case BondLevel.friend:
        messages.add('${pet.name} te considera su amigo');
        break;
      case BondLevel.bestFriend:
        messages.add('${pet.name} te adora 💝');
        break;
      case BondLevel.soulmate:
        messages.add('${pet.name} tiene un vínculo especial contigo ✨');
        break;
    }

    // Seleccionar mensaje aleatorio
    return messages[_random.nextInt(messages.length)];
  }

  /// Genera un mensaje de respuesta después de una acción
  String generateActionResponse({
    required InteractionType action,
    required Pet pet,
    required PetPersonality personality,
  }) {
    final responses = <String>[];

    switch (action) {
      case InteractionType.feed:
        if (personality.traits[PersonalityTrait.foodie]! > 70) {
          responses.addAll([
            '¡${pet.name} devora la comida! 🍔 (+10 XP)',
            '¡Ñam ñam! ${pet.name} estaba esperando esto 😋 (+10 XP)',
            '¡${pet.name} no dejó ni una migaja! 🍽️ (+10 XP)',
          ]);
        } else {
          responses.addAll([
            '¡Ñam ñam! 🍔 (+10 XP)',
            '${pet.name} come feliz 😊 (+10 XP)',
            '¡Delicioso! 🍽️ (+10 XP)',
          ]);
        }
        break;

      case InteractionType.play:
        if (personality.traits[PersonalityTrait.playful]! > 70) {
          responses.addAll([
            '¡${pet.name} está eufórico! 🎮 (+15 XP)',
            '¡Qué divertido! ${pet.name} quiere más 🎯 (+15 XP)',
            '${pet.name} salta de alegría 🤸 (+15 XP)',
          ]);
        } else if (personality.traits[PersonalityTrait.calm]! > 70) {
          responses.addAll([
            '${pet.name} juega tranquilamente 🎮 (+15 XP)',
            '${pet.name} se divierte a su manera 😌 (+15 XP)',
          ]);
        } else {
          responses.addAll([
            '¡Qué divertido! 🎮 (+15 XP)',
            '${pet.name} se divierte 😊 (+15 XP)',
          ]);
        }
        break;

      case InteractionType.clean:
        responses.addAll([
          '¡Qué limpio! 🧼 (+10 XP)',
          '${pet.name} brilla ✨ (+10 XP)',
          'Ahora ${pet.name} huele bien 🌸 (+10 XP)',
        ]);
        break;

      case InteractionType.rest:
        if (personality.traits[PersonalityTrait.energetic]! > 70) {
          responses.addAll([
            '${pet.name} descansa... pero ya quiere levantarse 😴 (+5 XP)',
            'Un pequeño descanso para ${pet.name} 💤 (+5 XP)',
          ]);
        } else {
          responses.addAll([
            '¡Zzz... 😴 (+5 XP)',
            '${pet.name} duerme plácidamente 💤 (+5 XP)',
            'Dulces sueños, ${pet.name} 🌙 (+5 XP)',
          ]);
        }
        break;

      case InteractionType.minigame:
        responses.addAll([
          '¡${pet.name} se divirtió mucho! 🎯',
          '¡Buen juego! ${pet.name} quiere más 🎮',
          '${pet.name} es un campeón 🏆',
        ]);
        break;

      default:
        responses.add('${pet.name} está contento');
        break;
    }

    return responses[_random.nextInt(responses.length)];
  }

  /// Predice la próxima necesidad de la mascota (versión con reglas)
  PredictedNeed? predictNextNeed({
    required Pet pet,
    required InteractionHistory history,
  }) {
    // Calcular tiempo estimado hasta cada estado crítico
    final predictions = <PredictedNeed>[];

    // Predecir hambre
    if (pet.hunger < 100) {
      final hungerRate = 0.002; // Por segundo
      final timeToHungry = ((70 - pet.hunger) / hungerRate / 60).round();
      if (timeToHungry > 0 && timeToHungry < 180) {
        predictions.add(PredictedNeed(
          type: InteractionType.feed,
          minutesUntilNeeded: timeToHungry,
          urgency: _calculateUrgency(timeToHungry),
          message: 'Necesitará comida en ~$timeToHungry minutos',
        ));
      }
    }

    // Predecir felicidad baja
    if (pet.happiness > 0) {
      final happinessRate = 0.001;
      final timeToSad = ((pet.happiness - 40) / happinessRate / 60).round();
      if (timeToSad > 0 && timeToSad < 180) {
        predictions.add(PredictedNeed(
          type: InteractionType.play,
          minutesUntilNeeded: timeToSad,
          urgency: _calculateUrgency(timeToSad),
          message: 'Necesitará jugar en ~$timeToSad minutos',
        ));
      }
    }

    // Predecir energía baja
    if (pet.energy > 0) {
      final energyRate = 0.001;
      final timeToTired = ((pet.energy - 30) / energyRate / 60).round();
      if (timeToTired > 0 && timeToTired < 180) {
        predictions.add(PredictedNeed(
          type: InteractionType.rest,
          minutesUntilNeeded: timeToTired,
          urgency: _calculateUrgency(timeToTired),
          message: 'Necesitará descansar en ~$timeToTired minutos',
        ));
      }
    }

    if (predictions.isEmpty) return null;

    // Retornar la necesidad más urgente
    predictions.sort((a, b) => a.minutesUntilNeeded.compareTo(b.minutesUntilNeeded));
    return predictions.first;
  }

  /// Predice la próxima necesidad usando ML con fallback a reglas
  ///
  /// Intenta usar CriticalTimePredictor para predicciones más precisas.
  /// Si el modelo no está disponible, usa las reglas heurísticas.
  Future<PredictedNeed?> predictNextNeedSmart({
    required Pet pet,
    required InteractionHistory history,
  }) async {
    // 1. Intentar usar ML
    final mlService = MLService();
    if (mlService.isInitialized) {
      try {
        final mlPrediction = await mlService.predictCriticalTime(
          pet: pet,
          history: history,
        );

        if (mlPrediction != null) {
          // Convertir CriticalTimePrediction a PredictedNeed
          return _criticalTimeToPredictedNeed(mlPrediction, pet);
        }
      } catch (e) {
        // Log error pero continuar con fallback
      }
    }

    // 2. Fallback a reglas heurísticas
    return predictNextNeed(pet: pet, history: history);
  }

  /// Convierte CriticalTimePrediction de ML a PredictedNeed
  PredictedNeed? _criticalTimeToPredictedNeed(
    CriticalTimePrediction prediction,
    Pet pet,
  ) {
    final minutes = prediction.getMinutesFor(prediction.mostUrgent).round();

    // Ignorar si es muy lejano (> 3 horas)
    if (minutes > 180 || minutes <= 0) return null;

    InteractionType type;
    String message;

    switch (prediction.mostUrgent) {
      case CriticalMetric.hunger:
        type = InteractionType.feed;
        message = '${pet.name} tendrá hambre en ~$minutes minutos';
      case CriticalMetric.happiness:
        type = InteractionType.play;
        message = '${pet.name} necesitará jugar en ~$minutes minutos';
      case CriticalMetric.energy:
        type = InteractionType.rest;
        message = '${pet.name} estará cansado en ~$minutes minutos';
      case CriticalMetric.health:
        type = InteractionType.clean;
        message = 'La salud de ${pet.name} bajará en ~$minutes minutos';
    }

    return PredictedNeed(
      type: type,
      minutesUntilNeeded: minutes,
      urgency: prediction.urgencyScore,
      message: message,
    );
  }

  /// Obtiene predicción ML de tiempo crítico (para UI avanzada)
  Future<CriticalTimePrediction?> getMLCriticalTimePrediction({
    required Pet pet,
    required InteractionHistory history,
  }) async {
    final mlService = MLService();
    if (!mlService.isInitialized) return null;

    try {
      return await mlService.predictCriticalTime(
        pet: pet,
        history: history,
      );
    } catch (e) {
      return null;
    }
  }

  double _calculateUrgency(int minutes) {
    if (minutes < 15) return 1.0;
    if (minutes < 30) return 0.8;
    if (minutes < 60) return 0.6;
    if (minutes < 120) return 0.4;
    return 0.2;
  }

  /// Analiza el historial y actualiza las preferencias del usuario
  UserPreferences analyzeUserPreferences(InteractionHistory history) {
    if (history.interactions.isEmpty) {
      return UserPreferences();
    }

    // Encontrar hora más frecuente
    final hourCounts = <int, int>{};
    for (final interaction in history.interactions) {
      final hour = interaction.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    int? preferredHour;
    int maxHourCount = 0;
    for (final entry in hourCounts.entries) {
      if (entry.value > maxHourCount) {
        maxHourCount = entry.value;
        preferredHour = entry.key;
      }
    }

    // Calcular consistencia
    double consistencyScore = 50.0;
    if (history.daysActive > 3) {
      final avgPerDay = history.averageInteractionsPerDay;
      if (avgPerDay >= 3 && avgPerDay <= 10) {
        consistencyScore = 80.0;
      } else if (avgPerDay >= 1) {
        consistencyScore = 60.0;
      } else {
        consistencyScore = 30.0;
      }
    }

    return UserPreferences(
      preferredHour: preferredHour,
      preferredTimeOfDay: history.mostActiveTimeOfDay,
      preferredDayOfWeek: _findMostActiveDayOfWeek(history),
      favoriteInteraction: history.mostFrequentInteraction,
      consistencyScore: consistencyScore,
    );
  }

  int? _findMostActiveDayOfWeek(InteractionHistory history) {
    if (history.dayOfWeekDistribution.isEmpty) return null;

    int? mostActive;
    int maxCount = 0;

    for (final entry in history.dayOfWeekDistribution.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostActive = entry.key;
      }
    }

    return mostActive;
  }

  /// Obtiene recomendación personalizada usando ML
  ///
  /// ActionRecommender proporciona scores para cada acción basándose
  /// en el historial completo y personalidad del pet.
  Future<ActionRecommendation?> getMLRecommendation({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    final mlService = MLService();
    if (!mlService.isInitialized) return null;

    try {
      return await mlService.recommendAction(
        pet: pet,
        personality: personality,
        history: history,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clasifica el estado emocional óptimo usando ML
  ///
  /// EmotionClassifier predice el estado emocional basándose
  /// en métricas actuales e historial de la sesión.
  Future<EmotionPrediction?> getMLEmotionPrediction({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    final mlService = MLService();
    if (!mlService.isInitialized) return null;

    try {
      return await mlService.classifyEmotion(
        pet: pet,
        personality: personality,
        history: history,
      );
    } catch (e) {
      return null;
    }
  }

  /// Genera datos para TensorFlow Lite (preparación de features)
  List<double> generateMLFeatures({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    // Features normalizadas (0-1) para el modelo ML
    return [
      pet.hunger / 100,
      pet.happiness / 100,
      pet.energy / 100,
      pet.health / 100,
      personality.emotionalState.value,
      personality.bondPoints / 500, // Normalizado al máximo esperado
      history.proactiveRatio,
      history.reactiveRatio,
      history.averageInteractionsPerDay / 10, // Normalizado
      TimeOfDay.current.index / 4, // Normalizado por número de períodos
      DateTime.now().weekday / 7, // Día de la semana normalizado
    ];
  }
}

/// Tipo de sugerencia de la IA
enum SuggestionType {
  urgent('Urgente', '⚠️'),
  important('Importante', '❗'),
  tip('Consejo', '💡'),
  friendly('Amistoso', '💬');

  final String displayName;
  final String emoji;

  const SuggestionType(this.displayName, this.emoji);
}

/// Sugerencia generada por la IA
class AISuggestion {
  final SuggestionType type;
  final String message;
  final InteractionType? action;
  final int priority;

  AISuggestion({
    required this.type,
    required this.message,
    required this.action,
    required this.priority,
  });
}

/// Predicción de necesidad futura
class PredictedNeed {
  final InteractionType type;
  final int minutesUntilNeeded;
  final double urgency;
  final String message;

  PredictedNeed({
    required this.type,
    required this.minutesUntilNeeded,
    required this.urgency,
    required this.message,
  });
}
