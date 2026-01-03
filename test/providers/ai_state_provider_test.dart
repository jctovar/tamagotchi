import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_personality.dart';
import 'package:tamagotchi/models/interaction_history.dart';

/// Tests para la lógica core de AI State (Personality e Interaction History)
///
/// NOTA: Los tests completos del provider con Riverpod requieren mock de servicios.
/// Estos tests se enfocan en la lógica de los modelos que son utilizados por el provider.
/// Para tests de integración completos, ver integration tests.

void main() {
  group('PetPersonality Model', () {
    test('PetPersonality se crea con valores por defecto correctos', () {
      // Act
      final personality = PetPersonality();

      // Assert
      expect(personality.emotionalState, EmotionalState.neutral);
      expect(personality.bondLevel, BondLevel.stranger);
      expect(personality.bondPoints, 0);
      expect(personality.traits.length, PersonalityTrait.values.length);

      // Todos los traits deben empezar en 50.0
      for (final trait in PersonalityTrait.values) {
        expect(personality.getTraitIntensity(trait), 50.0);
      }
    });

    test('getTraitIntensity retorna la intensidad correcta', () {
      // Arrange
      final traits = {
        PersonalityTrait.playful: 80.0,
        PersonalityTrait.calm: 30.0,
        PersonalityTrait.foodie: 65.0,
      };
      final personality = PetPersonality(traits: traits);

      // Act & Assert
      expect(personality.getTraitIntensity(PersonalityTrait.playful), 80.0);
      expect(personality.getTraitIntensity(PersonalityTrait.calm), 30.0);
      expect(personality.getTraitIntensity(PersonalityTrait.foodie), 65.0);
    });

    test('dominantTraits retorna los 3 traits más altos', () {
      // Arrange
      final traits = {
        PersonalityTrait.playful: 95.0,
        PersonalityTrait.calm: 30.0,
        PersonalityTrait.foodie: 85.0,
        PersonalityTrait.energetic: 90.0,
        PersonalityTrait.cuddly: 50.0,
      };
      final personality = PetPersonality(traits: traits);

      // Act
      final dominant = personality.dominantTraits;

      // Assert
      expect(dominant.length, 3);
      expect(dominant[0], PersonalityTrait.playful); // 95.0
      expect(dominant[1], PersonalityTrait.energetic); // 90.0
      expect(dominant[2], PersonalityTrait.foodie); // 85.0
    });

    test('personalityDescription genera descripción correcta', () {
      // Arrange
      final traits = {
        PersonalityTrait.playful: 95.0,
        PersonalityTrait.calm: 30.0,
        PersonalityTrait.foodie: 85.0,
        PersonalityTrait.energetic: 90.0,
      };
      final personality = PetPersonality(traits: traits);

      // Act
      final description = personality.personalityDescription;

      // Assert
      expect(description, contains('juguetón'));
      expect(description, contains('energético'));
      expect(description, contains('glotón'));
    });

    test('updateFromInteraction incrementa bondPoints por interacción normal', () {
      // Arrange
      final personality = PetPersonality(bondPoints: 10);
      final interaction = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      // Act
      final updated = personality.updateFromInteraction(interaction);

      // Assert
      expect(updated.bondPoints, 11); // +1 por interacción
    });

    test('updateFromInteraction incrementa bondPoints extra por cuidado proactivo', () {
      // Arrange
      final personality = PetPersonality(bondPoints: 10);
      final proactiveInteraction = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 30, // < 50
        happinessBefore: 80, // > 50
        energyBefore: 70, // > 50
        healthBefore: 90, // > 60
      );

      // Act
      final updated = personality.updateFromInteraction(proactiveInteraction);

      // Assert
      // Debe ser 10 + 1 (interacción) + 2 (proactivo) = 13
      expect(updated.bondPoints, 13);
    });

    test('updateFromInteraction de tipo play aumenta trait playful', () {
      // Arrange
      final initialPlayful = 50.0;
      final personality = PetPersonality();
      final playInteraction = Interaction.now(
        type: InteractionType.play,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      // Act
      final updated = personality.updateFromInteraction(playInteraction);

      // Assert
      expect(updated.getTraitIntensity(PersonalityTrait.playful),
             greaterThan(initialPlayful));
    });

    test('updateFromInteraction de tipo minigame da puntos extra de vínculo', () {
      // Arrange
      final personality = PetPersonality(bondPoints: 10);
      final minigameInteraction = Interaction.now(
        type: InteractionType.minigame,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      // Act
      final updated = personality.updateFromInteraction(minigameInteraction);

      // Assert
      // 10 + 1 (interacción) + 3 (mini-juego) = 14
      expect(updated.bondPoints, 14);
    });

    test('updateFromInteraction no incrementa bondPoints para appOpen/appClose', () {
      // Arrange
      final personality = PetPersonality(bondPoints: 10);
      final appOpenInteraction = Interaction.now(
        type: InteractionType.appOpen,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      // Act
      final updated = personality.updateFromInteraction(appOpenInteraction);

      // Assert
      expect(updated.bondPoints, 10); // No cambia
    });

    test('updateEmotionalState calcula estado happy con métricas buenas', () {
      // Arrange
      final personality = PetPersonality();

      // Act
      final updated = personality.updateEmotionalState(
        hunger: 20, // Baja hambre = bueno
        happiness: 90, // Alta felicidad
        energy: 80, // Alta energía
        health: 95, // Alta salud
        minutesSinceLastInteraction: 5, // Reciente
      );

      // Assert
      expect(updated.emotionalState, isIn([
        EmotionalState.ecstatic,
        EmotionalState.happy,
        EmotionalState.content,
      ]));
    });

    test('updateEmotionalState calcula estado negativo con métricas malas', () {
      // Arrange
      final personality = PetPersonality();

      // Act
      final updated = personality.updateEmotionalState(
        hunger: 90, // Alta hambre = malo
        happiness: 20, // Baja felicidad
        energy: 15, // Baja energía
        health: 40, // Baja salud
        minutesSinceLastInteraction: 400, // Mucho tiempo sin interacción
      );

      // Assert
      expect(updated.emotionalState, isIn([
        EmotionalState.anxious,
        EmotionalState.lonely,
        EmotionalState.sad,
        EmotionalState.bored,
      ]));
    });

    test('toJson serializa correctamente', () {
      // Arrange
      final traits = {
        PersonalityTrait.playful: 80.0,
        PersonalityTrait.calm: 60.0,
      };
      final personality = PetPersonality(
        traits: traits,
        emotionalState: EmotionalState.happy,
        bondLevel: BondLevel.friend,
        bondPoints: 200,
      );

      // Act
      final json = personality.toJson();

      // Assert
      expect(json['emotionalState'], 'happy');
      expect(json['bondLevel'], 'friend');
      expect(json['bondPoints'], 200);
      expect(json.containsKey('traits'), true);
      expect(json.containsKey('userPreferences'), true);
    });

    test('fromJson deserializa correctamente', () {
      // Arrange
      final json = <String, dynamic>{
        'traits': {
          'playful': 75.0,
          'calm': 55.0,
        },
        'emotionalState': 'content',
        'bondLevel': 'acquaintance',
        'bondPoints': 80,
        'userPreferences': <String, dynamic>{},
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Act
      final personality = PetPersonality.fromJson(json);

      // Assert
      expect(personality.emotionalState, EmotionalState.content);
      expect(personality.bondLevel, BondLevel.acquaintance);
      expect(personality.bondPoints, 80);
      expect(personality.getTraitIntensity(PersonalityTrait.playful), 75.0);
      expect(personality.getTraitIntensity(PersonalityTrait.calm), 55.0);
    });

    test('copyWith actualiza correctamente los campos', () {
      // Arrange
      final original = PetPersonality(
        emotionalState: EmotionalState.neutral,
        bondPoints: 50,
      );

      // Act
      final updated = original.copyWith(
        emotionalState: EmotionalState.happy,
        bondPoints: 100,
      );

      // Assert
      expect(updated.emotionalState, EmotionalState.happy);
      expect(updated.bondPoints, 100);
      expect(updated.bondLevel, BondLevel.stranger); // No cambió
    });
  });

  group('BondLevel Enum', () {
    test('fromInteractions retorna nivel correcto basado en cantidad', () {
      expect(BondLevel.fromInteractions(0), BondLevel.stranger);
      expect(BondLevel.fromInteractions(49), BondLevel.stranger);
      expect(BondLevel.fromInteractions(50), BondLevel.acquaintance);
      expect(BondLevel.fromInteractions(100), BondLevel.acquaintance);
      expect(BondLevel.fromInteractions(150), BondLevel.friend);
      expect(BondLevel.fromInteractions(200), BondLevel.friend);
      expect(BondLevel.fromInteractions(300), BondLevel.bestFriend);
      expect(BondLevel.fromInteractions(400), BondLevel.bestFriend);
      expect(BondLevel.fromInteractions(500), BondLevel.soulmate);
      expect(BondLevel.fromInteractions(1000), BondLevel.soulmate);
    });
  });

  group('Interaction Model', () {
    test('Interaction se crea correctamente con timestamp actual', () {
      // Act
      final interaction = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 60,
        happinessBefore: 70,
        energyBefore: 50,
        healthBefore: 90,
      );

      // Assert
      expect(interaction.type, InteractionType.feed);
      expect(interaction.hungerBefore, 60);
      expect(interaction.happinessBefore, 70);
      expect(interaction.energyBefore, 50);
      expect(interaction.healthBefore, 90);
      expect(interaction.timestamp, isA<DateTime>());
      expect(interaction.timeOfDay, isA<TimeOfDay>());
      expect(interaction.dayOfWeek, greaterThanOrEqualTo(1));
      expect(interaction.dayOfWeek, lessThanOrEqualTo(7));
    });

    test('wasReactive retorna true para estado crítico', () {
      // Arrange
      final criticalHunger = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 85, // > 70
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      final criticalHealth = Interaction.now(
        type: InteractionType.clean,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 30, // < 40
      );

      // Act & Assert
      expect(criticalHunger.wasReactive, true);
      expect(criticalHealth.wasReactive, true);
    });

    test('wasReactive retorna false para estado normal', () {
      // Arrange
      final normal = Interaction.now(
        type: InteractionType.play,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      // Act & Assert
      expect(normal.wasReactive, false);
    });

    test('wasProactive retorna true para mascota en buen estado', () {
      // Arrange
      final proactive = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 30, // < 50
        happinessBefore: 80, // > 50
        energyBefore: 70, // > 50
        healthBefore: 90, // > 60
      );

      // Act & Assert
      expect(proactive.wasProactive, true);
    });

    test('wasProactive retorna false para mascota en mal estado', () {
      // Arrange
      final notProactive = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 60, // No cumple < 50
        happinessBefore: 80,
        energyBefore: 70,
        healthBefore: 90,
      );

      // Act & Assert
      expect(notProactive.wasProactive, false);
    });

    test('toJson serializa correctamente', () {
      // Arrange
      final interaction = Interaction.now(
        type: InteractionType.play,
        hungerBefore: 60,
        happinessBefore: 70,
        energyBefore: 50,
        healthBefore: 90,
        metadata: {'score': 100},
      );

      // Act
      final json = interaction.toJson();

      // Assert
      expect(json['type'], 'play');
      expect(json['hungerBefore'], 60);
      expect(json['happinessBefore'], 70);
      expect(json['energyBefore'], 50);
      expect(json['healthBefore'], 90);
      expect(json['metadata'], {'score': 100});
    });

    test('fromJson deserializa correctamente', () {
      // Arrange
      final json = {
        'type': 'feed',
        'timestamp': DateTime.now().toIso8601String(),
        'hungerBefore': 55.0,
        'happinessBefore': 75.0,
        'energyBefore': 65.0,
        'healthBefore': 85.0,
        'metadata': null,
      };

      // Act
      final interaction = Interaction.fromJson(json);

      // Assert
      expect(interaction.type, InteractionType.feed);
      expect(interaction.hungerBefore, 55.0);
      expect(interaction.happinessBefore, 75.0);
      expect(interaction.energyBefore, 65.0);
      expect(interaction.healthBefore, 85.0);
    });
  });

  group('TimeOfDay Enum', () {
    test('fromHour retorna período correcto', () {
      expect(TimeOfDay.fromHour(0), TimeOfDay.earlyMorning);
      expect(TimeOfDay.fromHour(3), TimeOfDay.earlyMorning);
      expect(TimeOfDay.fromHour(6), TimeOfDay.morning);
      expect(TimeOfDay.fromHour(9), TimeOfDay.morning);
      expect(TimeOfDay.fromHour(12), TimeOfDay.afternoon);
      expect(TimeOfDay.fromHour(15), TimeOfDay.afternoon);
      expect(TimeOfDay.fromHour(18), TimeOfDay.evening);
      expect(TimeOfDay.fromHour(20), TimeOfDay.evening);
      expect(TimeOfDay.fromHour(21), TimeOfDay.night);
      expect(TimeOfDay.fromHour(23), TimeOfDay.night);
    });

    test('current retorna un TimeOfDay válido', () {
      final current = TimeOfDay.current;
      expect(current, isA<TimeOfDay>());
    });
  });

  group('InteractionHistory Model', () {
    test('InteractionHistory se crea vacío por defecto', () {
      // Act
      final history = InteractionHistory();

      // Assert
      expect(history.interactions, isEmpty);
      expect(history.firstInteraction, isNull);
      expect(history.lastInteraction, isNull);
      expect(history.interactionCounts.length, InteractionType.values.length);
      expect(history.timeOfDayDistribution.length, TimeOfDay.values.length);
    });

    test('InteractionHistory con interacciones calcula timestamps correctamente', () {
      // Arrange
      final now = DateTime.now();
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: now.subtract(const Duration(hours: 2)),
          hungerBefore: 60,
          happinessBefore: 70,
          energyBefore: 50,
          healthBefore: 90,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: now,
          hungerBefore: 50,
          happinessBefore: 80,
          energyBefore: 60,
          healthBefore: 90,
        ),
      ];

      // Act
      final history = InteractionHistory(interactions: interactions);

      // Assert
      expect(history.interactions.length, 2);
      expect(history.firstInteraction, interactions[0].timestamp);
      expect(history.lastInteraction, interactions[1].timestamp);
    });

    test('interactionCounts cuenta correctamente por tipo', () {
      // Arrange
      final interactions = [
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 60,
          happinessBefore: 70,
          energyBefore: 50,
          healthBefore: 90,
        ),
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 65,
          happinessBefore: 75,
          energyBefore: 55,
          healthBefore: 85,
        ),
        Interaction.now(
          type: InteractionType.play,
          hungerBefore: 50,
          happinessBefore: 60,
          energyBefore: 70,
          healthBefore: 90,
        ),
      ];

      // Act
      final history = InteractionHistory(interactions: interactions);

      // Assert
      expect(history.interactionCounts[InteractionType.feed], 2);
      expect(history.interactionCounts[InteractionType.play], 1);
      expect(history.interactionCounts[InteractionType.clean], 0);
    });

    test('timeOfDayDistribution cuenta correctamente por período', () {
      // Arrange
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 8, 0), // Morning
          hungerBefore: 60,
          happinessBefore: 70,
          energyBefore: 50,
          healthBefore: 90,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: DateTime(2024, 1, 1, 9, 0), // Morning
          hungerBefore: 50,
          happinessBefore: 60,
          energyBefore: 70,
          healthBefore: 90,
        ),
        Interaction(
          type: InteractionType.clean,
          timestamp: DateTime(2024, 1, 1, 15, 0), // Afternoon
          hungerBefore: 55,
          happinessBefore: 65,
          energyBefore: 60,
          healthBefore: 85,
        ),
      ];

      // Act
      final history = InteractionHistory(interactions: interactions);

      // Assert
      expect(history.timeOfDayDistribution[TimeOfDay.morning], 2);
      expect(history.timeOfDayDistribution[TimeOfDay.afternoon], 1);
      expect(history.timeOfDayDistribution[TimeOfDay.evening], 0);
    });
  });
}
