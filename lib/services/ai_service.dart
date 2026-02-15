import 'dart:math';
import '../models/pet.dart';
import '../models/interaction_history.dart';
import '../models/pet_personality.dart';

enum SuggestionType {
  urgent('Urgente', '⚠️'),
  important('Importante', '❗'),
  tip('Consejo', '💡'),
  friendly('Amistoso', '💬');

  final String displayName;
  final String emoji;

  const SuggestionType(this.displayName, this.emoji);
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Random _random = Random();

  AISuggestion? generateSuggestion({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final suggestions = <AISuggestion>[];

    if (pet.hunger > 70) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.urgent,
          message: '${pet.name} tiene mucha hambre. ¡Aliméntalo pronto!',
          action: InteractionType.feed,
          priority: 10,
        ),
      );
    }

    if (pet.happiness < 40) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.urgent,
          message:
              '${pet.name} está ${personality.emotionalState.displayName.toLowerCase()}. '
              'Un poco de diversión le vendría bien.',
          action: InteractionType.play,
          priority: 8,
        ),
      );
    }

    if (pet.energy < 30) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.important,
          message: '${pet.name} está cansado. Necesita descansar.',
          action: InteractionType.rest,
          priority: 7,
        ),
      );
    }

    if (pet.health < 50) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.urgent,
          message: 'La salud de ${pet.name} está baja. Cuídalo mejor.',
          action: InteractionType.clean,
          priority: 9,
        ),
      );
    }

    final dominantTrait = personality.dominantTraits.isNotEmpty
        ? personality.dominantTraits.first
        : null;

    if (dominantTrait == PersonalityTrait.playful && pet.happiness < 70) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.tip,
          message:
              'Como ${pet.name} es tan juguetón, le encantaría jugar contigo.',
          action: InteractionType.play,
          priority: 5,
        ),
      );
    }

    if (dominantTrait == PersonalityTrait.foodie && pet.hunger > 30) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.tip,
          message:
              '${pet.name} es un poco glotón... ¡Ya está pensando en comida!',
          action: InteractionType.feed,
          priority: 4,
        ),
      );
    }

    final lastInteraction = history.interactions.isNotEmpty
        ? history.interactions.last.timestamp
        : DateTime.now();
    final minutesSinceInteraction = DateTime.now()
        .difference(lastInteraction)
        .inMinutes;

    if (minutesSinceInteraction > 60 && personality.bondLevel.index >= 2) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.friendly,
          message:
              '${pet.name} te ha extrañado. ¿Por qué no pasas tiempo con él?',
          action: null,
          priority: 3,
        ),
      );
    }

    if (history.interactionCounts[InteractionType.minigame] == 0) {
      suggestions.add(
        AISuggestion(
          type: SuggestionType.tip,
          message:
              '¡Prueba los mini-juegos! A ${pet.name} le encantará y ganarás monedas.',
          action: InteractionType.minigame,
          priority: 4,
        ),
      );
    }

    if (suggestions.isEmpty) return null;
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions.first;
  }

  String generatePetMessage({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) {
    final messages = <String>[];

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
        case PersonalityTrait.energetic:
          messages.add('${pet.name} está lleno de energía ⚡');
          break;
        case PersonalityTrait.foodie:
          messages.add('${pet.name} piensa en su próxima comida 🍕');
          break;
        case PersonalityTrait.independent:
          messages.add('${pet.name} es muy autónomo 🦁');
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
        case PersonalityTrait.anxious:
          messages.add('${pet.name} se siente nervioso sin ti 😨');
          break;
        case PersonalityTrait.shy:
          messages.add('${pet.name} se esconde tímidamente 🙈');
          break;
        case PersonalityTrait.grumpy:
          messages.add('${pet.name} está de mal humor hoy 😤');
          break;
        default:
          break;
      }
    }

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

    return messages[_random.nextInt(messages.length)];
  }

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
            '¡Delicioso! 🍽️ (+10 XP)',
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
            'Dulces sueños, ${pet.name} 🌙 (+5 XP)',
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

  PredictedNeed? predictNextNeed({
    required Pet pet,
    required InteractionHistory history,
  }) {
    final predictions = <PredictedNeed>[];

    if (pet.hunger < 100) {
      final hungerRate = 0.002;
      final timeToHungry = ((70 - pet.hunger) / hungerRate / 60).round();

      if (timeToHungry > 0 && timeToHungry < 180) {
        predictions.add(
          PredictedNeed(
            type: InteractionType.feed,
            minutesUntilNeeded: timeToHungry,
            urgency: _calculateUrgency(timeToHungry),
            message: 'Necesitará comida en ~$timeToHungry minutos',
          ),
        );
      }
    }

    if (pet.happiness > 0) {
      final happinessRate = 0.001;
      final timeToSad = ((pet.happiness - 40) / happinessRate / 60).round();

      if (timeToSad > 0 && timeToSad < 180) {
        predictions.add(
          PredictedNeed(
            type: InteractionType.play,
            minutesUntilNeeded: timeToSad,
            urgency: _calculateUrgency(timeToSad),
            message: 'Necesitará jugar en ~$timeToSad minutos',
          ),
        );
      }
    }

    if (pet.energy > 0) {
      final energyRate = 0.001;
      final timeToTired = ((pet.energy - 30) / energyRate / 60).round();

      if (timeToTired > 0 && timeToTired < 180) {
        predictions.add(
          PredictedNeed(
            type: InteractionType.rest,
            minutesUntilNeeded: timeToTired,
            urgency: _calculateUrgency(timeToTired),
            message: 'Necesitará descansar en ~$timeToTired minutos',
          ),
        );
      }
    }

    if (predictions.isEmpty) return null;

    predictions.sort(
      (a, b) => a.minutesUntilNeeded.compareTo(b.minutesUntilNeeded),
    );
    return predictions.first;
  }

  double _calculateUrgency(int minutes) {
    if (minutes < 15) return 1.0;
    if (minutes < 30) return 0.8;
    if (minutes < 60) return 0.6;
    if (minutes < 120) return 0.4;
    return 0.2;
  }
}

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
