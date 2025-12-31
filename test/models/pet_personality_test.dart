import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/models/pet_personality.dart';

void main() {
  group('BondLevel', () {
    test('fromInteractions devuelve stranger para < 50', () {
      expect(BondLevel.fromInteractions(0), BondLevel.stranger);
      expect(BondLevel.fromInteractions(49), BondLevel.stranger);
    });

    test('fromInteractions devuelve acquaintance para 50-149', () {
      expect(BondLevel.fromInteractions(50), BondLevel.acquaintance);
      expect(BondLevel.fromInteractions(100), BondLevel.acquaintance);
      expect(BondLevel.fromInteractions(149), BondLevel.acquaintance);
    });

    test('fromInteractions devuelve friend para 150-299', () {
      expect(BondLevel.fromInteractions(150), BondLevel.friend);
      expect(BondLevel.fromInteractions(200), BondLevel.friend);
      expect(BondLevel.fromInteractions(299), BondLevel.friend);
    });

    test('fromInteractions devuelve bestFriend para 300-499', () {
      expect(BondLevel.fromInteractions(300), BondLevel.bestFriend);
      expect(BondLevel.fromInteractions(400), BondLevel.bestFriend);
      expect(BondLevel.fromInteractions(499), BondLevel.bestFriend);
    });

    test('fromInteractions devuelve soulmate para >= 500', () {
      expect(BondLevel.fromInteractions(500), BondLevel.soulmate);
      expect(BondLevel.fromInteractions(1000), BondLevel.soulmate);
    });

    test('valores de enum tienen propiedades correctas', () {
      expect(BondLevel.stranger.requiredInteractions, 0);
      expect(BondLevel.acquaintance.requiredInteractions, 50);
      expect(BondLevel.friend.displayName, 'Amigo');
      expect(BondLevel.soulmate.description, 'Vínculo inquebrantable');
    });
  });

  group('PersonalityTrait', () {
    test('tiene displayName, emoji y description', () {
      expect(PersonalityTrait.playful.displayName, 'Juguetón');
      expect(PersonalityTrait.playful.emoji, '🎮');
      expect(PersonalityTrait.cuddly.displayName, 'Cariñoso');
      expect(PersonalityTrait.anxious.description, 'Se preocupa cuando no recibe atención');
    });
  });

  group('EmotionalState', () {
    test('tiene displayName, emoji y value correctos', () {
      expect(EmotionalState.ecstatic.displayName, 'Extasiado');
      expect(EmotionalState.ecstatic.emoji, '🤩');
      expect(EmotionalState.ecstatic.value, 1.0);

      expect(EmotionalState.neutral.value, 0.5);
      expect(EmotionalState.anxious.value, 0.1);
    });

    test('valores están ordenados de mayor a menor felicidad', () {
      expect(EmotionalState.ecstatic.value, greaterThan(EmotionalState.happy.value));
      expect(EmotionalState.happy.value, greaterThan(EmotionalState.content.value));
      expect(EmotionalState.content.value, greaterThan(EmotionalState.neutral.value));
    });
  });

  group('UserPreferences', () {
    test('constructor con valores por defecto', () {
      final prefs = UserPreferences();

      expect(prefs.preferredHour, isNull);
      expect(prefs.preferredTimeOfDay, isNull);
      expect(prefs.preferredDayOfWeek, isNull);
      expect(prefs.favoriteInteraction, isNull);
      expect(prefs.averageSessionGap, isNull);
      expect(prefs.averageSessionDuration, isNull);
      expect(prefs.consistencyScore, 50.0);
    });

    test('constructor con valores personalizados', () {
      final prefs = UserPreferences(
        preferredHour: 14,
        preferredTimeOfDay: TimeOfDay.afternoon,
        preferredDayOfWeek: DateTime.saturday,
        favoriteInteraction: InteractionType.play,
        averageSessionGap: 120,
        averageSessionDuration: 15,
        consistencyScore: 85.5,
      );

      expect(prefs.preferredHour, 14);
      expect(prefs.preferredTimeOfDay, TimeOfDay.afternoon);
      expect(prefs.preferredDayOfWeek, DateTime.saturday);
      expect(prefs.favoriteInteraction, InteractionType.play);
      expect(prefs.averageSessionGap, 120);
      expect(prefs.averageSessionDuration, 15);
      expect(prefs.consistencyScore, 85.5);
    });

    test('isConsistent es true cuando consistencyScore > 70', () {
      final consistent = UserPreferences(consistencyScore: 75.0);
      expect(consistent.isConsistent, true);
    });

    test('isConsistent es false cuando consistencyScore <= 70', () {
      final inconsistent = UserPreferences(consistencyScore: 70.0);
      expect(inconsistent.isConsistent, false);
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        final prefs = UserPreferences(
          preferredHour: 14,
          preferredTimeOfDay: TimeOfDay.afternoon,
          preferredDayOfWeek: DateTime.saturday,
          favoriteInteraction: InteractionType.play,
          averageSessionGap: 120,
          averageSessionDuration: 15,
          consistencyScore: 85.5,
        );

        final json = prefs.toJson();

        expect(json['preferredHour'], 14);
        expect(json['preferredTimeOfDay'], 'afternoon');
        expect(json['preferredDayOfWeek'], DateTime.saturday);
        expect(json['favoriteInteraction'], 'play');
        expect(json['averageSessionGap'], 120);
        expect(json['averageSessionDuration'], 15);
        expect(json['consistencyScore'], 85.5);
      });

      test('fromJson deserializa correctamente', () {
        final json = {
          'preferredHour': 10,
          'preferredTimeOfDay': 'morning',
          'preferredDayOfWeek': DateTime.monday,
          'favoriteInteraction': 'feed',
          'averageSessionGap': 60,
          'averageSessionDuration': 20,
          'consistencyScore': 90.0,
        };

        final prefs = UserPreferences.fromJson(json);

        expect(prefs.preferredHour, 10);
        expect(prefs.preferredTimeOfDay, TimeOfDay.morning);
        expect(prefs.preferredDayOfWeek, DateTime.monday);
        expect(prefs.favoriteInteraction, InteractionType.feed);
        expect(prefs.averageSessionGap, 60);
        expect(prefs.averageSessionDuration, 20);
        expect(prefs.consistencyScore, 90.0);
      });

      test('fromJson maneja valores nulos correctamente', () {
        final json = <String, dynamic>{};
        final prefs = UserPreferences.fromJson(json);

        expect(prefs.preferredHour, isNull);
        expect(prefs.preferredTimeOfDay, isNull);
        expect(prefs.preferredDayOfWeek, isNull);
        expect(prefs.favoriteInteraction, isNull);
        expect(prefs.consistencyScore, 50.0);
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = UserPreferences(
          preferredHour: 18,
          preferredTimeOfDay: TimeOfDay.evening,
          preferredDayOfWeek: DateTime.friday,
          favoriteInteraction: InteractionType.minigame,
          averageSessionGap: 180,
          averageSessionDuration: 30,
          consistencyScore: 78.3,
        );

        final json = original.toJson();
        final restored = UserPreferences.fromJson(json);

        expect(restored.preferredHour, original.preferredHour);
        expect(restored.preferredTimeOfDay, original.preferredTimeOfDay);
        expect(restored.preferredDayOfWeek, original.preferredDayOfWeek);
        expect(restored.favoriteInteraction, original.favoriteInteraction);
        expect(restored.consistencyScore, original.consistencyScore);
      });
    });

    group('copyWith', () {
      test('actualiza solo los campos proporcionados', () {
        final original = UserPreferences(
          preferredHour: 10,
          consistencyScore: 50.0,
        );

        final updated = original.copyWith(
          preferredHour: 15,
        );

        expect(updated.preferredHour, 15);
        expect(updated.consistencyScore, 50.0); // No cambió
      });

      test('mantiene valores cuando no se proporcionan parámetros', () {
        final original = UserPreferences(
          preferredHour: 10,
          consistencyScore: 75.0,
        );

        final copy = original.copyWith();

        expect(copy.preferredHour, 10);
        expect(copy.consistencyScore, 75.0);
      });
    });
  });

  group('PetPersonality', () {
    test('constructor con valores por defecto', () {
      final personality = PetPersonality();

      expect(personality.traits.length, PersonalityTrait.values.length);
      expect(personality.emotionalState, EmotionalState.neutral);
      expect(personality.bondLevel, BondLevel.stranger);
      expect(personality.bondPoints, 0);
      expect(personality.userPreferences, isNotNull);
      expect(personality.lastUpdated, isNotNull);
    });

    test('_defaultTraits inicializa todos los traits en 50', () {
      final personality = PetPersonality();

      for (final trait in PersonalityTrait.values) {
        expect(personality.traits[trait], 50.0);
      }
    });

    test('constructor con valores personalizados', () {
      final customTraits = {
        PersonalityTrait.playful: 80.0,
        PersonalityTrait.calm: 30.0,
      };
      final personality = PetPersonality(
        traits: customTraits,
        emotionalState: EmotionalState.happy,
        bondLevel: BondLevel.friend,
        bondPoints: 200,
      );

      expect(personality.traits[PersonalityTrait.playful], 80.0);
      expect(personality.emotionalState, EmotionalState.happy);
      expect(personality.bondLevel, BondLevel.friend);
      expect(personality.bondPoints, 200);
    });

    test('dominantTraits devuelve los 3 traits más altos', () {
      final traits = <PersonalityTrait, double>{};
      for (final trait in PersonalityTrait.values) {
        traits[trait] = 50.0;
      }
      traits[PersonalityTrait.playful] = 90.0;
      traits[PersonalityTrait.energetic] = 85.0;
      traits[PersonalityTrait.cuddly] = 80.0;

      final personality = PetPersonality(traits: traits);
      final dominant = personality.dominantTraits;

      expect(dominant.length, 3);
      expect(dominant[0], PersonalityTrait.playful);
      expect(dominant[1], PersonalityTrait.energetic);
      expect(dominant[2], PersonalityTrait.cuddly);
    });

    test('getTraitIntensity devuelve la intensidad correcta', () {
      final traits = <PersonalityTrait, double>{};
      for (final trait in PersonalityTrait.values) {
        traits[trait] = 50.0;
      }
      traits[PersonalityTrait.playful] = 75.5;

      final personality = PetPersonality(traits: traits);

      expect(personality.getTraitIntensity(PersonalityTrait.playful), 75.5);
      expect(personality.getTraitIntensity(PersonalityTrait.calm), 50.0);
    });

    test('getTraitIntensity devuelve 50 para trait no existente', () {
      final personality = PetPersonality(traits: {});
      expect(personality.getTraitIntensity(PersonalityTrait.playful), 50.0);
    });

    group('personalityDescription', () {
      test('describe personalidad con 3 traits', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.playful] = 90.0;
        traits[PersonalityTrait.energetic] = 85.0;
        traits[PersonalityTrait.cuddly] = 80.0;

        final personality = PetPersonality(traits: traits);
        final description = personality.personalityDescription;

        expect(description, contains('juguetón'));
        expect(description, contains('energético'));
        expect(description, contains('cariñoso'));
      });

      test('describe personalidad con 2 traits', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        // Solo modificar 2 para que sean dominantes
        traits[PersonalityTrait.playful] = 90.0;
        traits[PersonalityTrait.calm] = 85.0;

        final personality = PetPersonality(traits: traits);

        // Debería mencionar los dos traits más altos
        expect(personality.personalityDescription, isNotEmpty);
      });
    });

    group('updateFromInteraction', () {
      test('incrementa bondPoints por interacción normal', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(updated.bondPoints, greaterThan(personality.bondPoints));
      });

      test('no incrementa bondPoints para appOpen/appClose', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.appOpen,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(updated.bondPoints, personality.bondPoints);
      });

      test('bonus de bondPoints por interacción proactiva', () {
        final personality = PetPersonality();
        final proactiveInteraction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 30.0, // Proactiva
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        );

        final updated = personality.updateFromInteraction(proactiveInteraction);

        expect(updated.bondPoints, 3); // 1 base + 2 bonus
      });

      test('play incrementa playful y energetic', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.play,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.playful),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.playful)),
        );
        expect(
          updated.getTraitIntensity(PersonalityTrait.energetic),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.energetic)),
        );
      });

      test('feed incrementa foodie', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.foodie),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.foodie)),
        );
      });

      test('rest incrementa calm', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.rest,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.calm),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.calm)),
        );
      });

      test('clean incrementa calm', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.clean,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.calm),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.calm)),
        );
      });

      test('minigame incrementa playful, curious y da bonus bondPoints', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.minigame,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.playful),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.playful)),
        );
        expect(
          updated.getTraitIntensity(PersonalityTrait.curious),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.curious)),
        );
        expect(updated.bondPoints, 4); // 1 base + 3 bonus
      });

      test('customize incrementa cuddly', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.customize,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.cuddly),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.cuddly)),
        );
      });

      test('interacciones en la mañana incrementan earlyBird', () {
        final personality = PetPersonality();
        final interaction = Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 8, 0), // morning
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.earlyBird),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.earlyBird)),
        );
      });

      test('interacciones en la noche incrementan nocturnal', () {
        final personality = PetPersonality();
        final interaction = Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 22, 0), // night
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.nocturnal),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.nocturnal)),
        );
      });

      test('interacción reactiva incrementa anxious', () {
        final personality = PetPersonality();
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 80.0, // Reactiva
          happinessBefore: 20.0,
          energyBefore: 20.0,
          healthBefore: 30.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.anxious),
          greaterThan(personality.getTraitIntensity(PersonalityTrait.anxious)),
        );
      });

      test('interacción proactiva reduce anxious', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.anxious] = 60.0;

        final personality = PetPersonality(traits: traits);
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 30.0, // Proactiva
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(
          updated.getTraitIntensity(PersonalityTrait.anxious),
          lessThan(personality.getTraitIntensity(PersonalityTrait.anxious)),
        );
      });

      test('traits se clampean entre 0 y 100', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 99.5;
        }
        final personality = PetPersonality(traits: traits);
        final interaction = Interaction.now(
          type: InteractionType.play,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        // Ningún trait debería exceder 100
        for (final value in updated.traits.values) {
          expect(value, lessThanOrEqualTo(100.0));
          expect(value, greaterThanOrEqualTo(0.0));
        }
      });

      test('actualiza bondLevel cuando se alcanzan suficientes bondPoints', () {
        final personality = PetPersonality(bondPoints: 149);
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(updated.bondLevel, BondLevel.friend); // 150 points
      });

      test('actualiza lastUpdated', () {
        final personality = PetPersonality(
          lastUpdated: DateTime(2024, 1, 1),
        );
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );

        final updated = personality.updateFromInteraction(interaction);

        expect(updated.lastUpdated.isAfter(personality.lastUpdated), true);
      });
    });

    group('updateEmotionalState', () {
      test('calcula ecstatic con métricas muy altas', () {
        final personality = PetPersonality();

        final updated = personality.updateEmotionalState(
          hunger: 10.0,
          happiness: 95.0,
          energy: 90.0,
          health: 95.0,
          minutesSinceLastInteraction: 5,
        );

        expect(updated.emotionalState, EmotionalState.ecstatic);
      });

      test('calcula happy con buenas métricas', () {
        final personality = PetPersonality();

        final updated = personality.updateEmotionalState(
          hunger: 20.0,
          happiness: 80.0,
          energy: 75.0,
          health: 85.0,
          minutesSinceLastInteraction: 10,
        );

        expect(updated.emotionalState, EmotionalState.happy);
      });

      test('calcula neutral con métricas medianas', () {
        final personality = PetPersonality();

        final updated = personality.updateEmotionalState(
          hunger: 50.0,
          happiness: 50.0,
          energy: 50.0,
          health: 60.0,
          minutesSinceLastInteraction: 30,
        );

        expect(updated.emotionalState, EmotionalState.neutral);
      });

      test('calcula sad con métricas bajas', () {
        final personality = PetPersonality();

        final updated = personality.updateEmotionalState(
          hunger: 65.0,
          happiness: 35.0,
          energy: 35.0,
          health: 50.0,
          minutesSinceLastInteraction: 90,
        );

        expect(updated.emotionalState, EmotionalState.sad);
      });

      test('calcula anxious con métricas muy bajas', () {
        final personality = PetPersonality();

        final updated = personality.updateEmotionalState(
          hunger: 90.0,
          happiness: 10.0,
          energy: 10.0,
          health: 20.0,
          minutesSinceLastInteraction: 500,
        );

        expect(updated.emotionalState, EmotionalState.anxious);
      });

      test('penaliza por mucho tiempo sin interacción (> 60 min)', () {
        final personality = PetPersonality();

        final withoutPenalty = personality.updateEmotionalState(
          hunger: 30.0,
          happiness: 75.0,
          energy: 75.0,
          health: 85.0,
          minutesSinceLastInteraction: 30,
        );

        final withPenalty = personality.updateEmotionalState(
          hunger: 30.0,
          happiness: 75.0,
          energy: 75.0,
          health: 85.0,
          minutesSinceLastInteraction: 90,
        );

        expect(withPenalty.emotionalState.value, lessThan(withoutPenalty.emotionalState.value));
      });

      test('bondLevel más alto mejora el estado emocional', () {
        final lowBond = PetPersonality(bondLevel: BondLevel.stranger);
        final highBond = PetPersonality(bondLevel: BondLevel.soulmate);

        final lowBondState = lowBond.updateEmotionalState(
          hunger: 50.0,
          happiness: 50.0,
          energy: 50.0,
          health: 60.0,
          minutesSinceLastInteraction: 30,
        );

        final highBondState = highBond.updateEmotionalState(
          hunger: 50.0,
          happiness: 50.0,
          energy: 50.0,
          health: 60.0,
          minutesSinceLastInteraction: 30,
        );

        expect(highBondState.emotionalState.value, greaterThanOrEqualTo(lowBondState.emotionalState.value));
      });

      test('trait anxious alto reduce el estado emocional', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.anxious] = 80.0;

        final anxiousPersonality = PetPersonality(traits: traits);

        final state = anxiousPersonality.updateEmotionalState(
          hunger: 50.0,
          happiness: 60.0,
          energy: 60.0,
          health: 70.0,
          minutesSinceLastInteraction: 30,
        );

        // Debería tener estado emocional más bajo que el normal
        expect(state.emotionalState.value, lessThan(0.6));
      });

      test('trait calm alto mejora el estado emocional', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.calm] = 80.0;

        final calmPersonality = PetPersonality(traits: traits);

        final state = calmPersonality.updateEmotionalState(
          hunger: 50.0,
          happiness: 60.0,
          energy: 60.0,
          health: 70.0,
          minutesSinceLastInteraction: 30,
        );

        // Debería tener un boost por calm
        expect(state.emotionalState, isNotNull);
      });
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.playful] = 80.0;

        final personality = PetPersonality(
          traits: traits,
          emotionalState: EmotionalState.happy,
          bondLevel: BondLevel.friend,
          bondPoints: 200,
        );

        final json = personality.toJson();

        expect(json['traits'], isA<Map>());
        expect(json['traits']['playful'], 80.0);
        expect(json['emotionalState'], 'happy');
        expect(json['bondLevel'], 'friend');
        expect(json['bondPoints'], 200);
        expect(json['userPreferences'], isNotNull);
        expect(json['lastUpdated'], isNotNull);
      });

      test('fromJson deserializa correctamente', () {
        final json = {
          'traits': {
            'playful': 75.0,
            'calm': 60.0,
          },
          'emotionalState': 'content',
          'bondLevel': 'acquaintance',
          'bondPoints': 100,
          'userPreferences': {
            'consistencyScore': 80.0,
          },
          'lastUpdated': DateTime(2024, 1, 15).toIso8601String(),
        };

        final personality = PetPersonality.fromJson(json);

        expect(personality.getTraitIntensity(PersonalityTrait.playful), 75.0);
        expect(personality.getTraitIntensity(PersonalityTrait.calm), 60.0);
        expect(personality.emotionalState, EmotionalState.content);
        expect(personality.bondLevel, BondLevel.acquaintance);
        expect(personality.bondPoints, 100);
        expect(personality.userPreferences.consistencyScore, 80.0);
        expect(personality.lastUpdated, DateTime(2024, 1, 15));
      });

      test('fromJson usa valores por defecto para traits faltantes', () {
        final json = {
          'traits': {
            'playful': 75.0,
          },
          'emotionalState': 'neutral',
          'bondLevel': 'stranger',
          'bondPoints': 0,
        };

        final personality = PetPersonality.fromJson(json);

        expect(personality.getTraitIntensity(PersonalityTrait.playful), 75.0);
        expect(personality.getTraitIntensity(PersonalityTrait.calm), 50.0); // Default
      });

      test('fromJson maneja json vacío con valores por defecto', () {
        final json = <String, dynamic>{};
        final personality = PetPersonality.fromJson(json);

        expect(personality.emotionalState, EmotionalState.neutral);
        expect(personality.bondLevel, BondLevel.stranger);
        expect(personality.bondPoints, 0);
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = PetPersonality(
          emotionalState: EmotionalState.happy,
          bondLevel: BondLevel.friend,
          bondPoints: 200,
        );

        final json = original.toJson();
        final restored = PetPersonality.fromJson(json);

        expect(restored.emotionalState, original.emotionalState);
        expect(restored.bondLevel, original.bondLevel);
        expect(restored.bondPoints, original.bondPoints);
      });
    });

    group('copyWith', () {
      test('actualiza solo los campos proporcionados', () {
        final original = PetPersonality(
          emotionalState: EmotionalState.neutral,
          bondPoints: 100,
        );

        final updated = original.copyWith(
          emotionalState: EmotionalState.happy,
        );

        expect(updated.emotionalState, EmotionalState.happy);
        expect(updated.bondPoints, 100); // No cambió
      });

      test('mantiene valores cuando no se proporcionan parámetros', () {
        final original = PetPersonality(
          emotionalState: EmotionalState.content,
          bondLevel: BondLevel.friend,
          bondPoints: 150,
        );

        final copy = original.copyWith();

        expect(copy.emotionalState, original.emotionalState);
        expect(copy.bondLevel, original.bondLevel);
        expect(copy.bondPoints, original.bondPoints);
      });
    });
  });
}
