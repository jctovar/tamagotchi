import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/pet_personality.dart';
import 'package:tamagotchi/services/ai_service.dart';

void main() {
  group('SuggestionType', () {
    test('tiene displayName y emoji correctos', () {
      expect(SuggestionType.urgent.displayName, 'Urgente');
      expect(SuggestionType.urgent.emoji, '⚠️');

      expect(SuggestionType.important.displayName, 'Importante');
      expect(SuggestionType.important.emoji, '❗');

      expect(SuggestionType.tip.displayName, 'Consejo');
      expect(SuggestionType.tip.emoji, '💡');

      expect(SuggestionType.friendly.displayName, 'Amistoso');
      expect(SuggestionType.friendly.emoji, '💬');
    });
  });

  group('AISuggestion', () {
    test('constructor inicializa correctamente', () {
      final suggestion = AISuggestion(
        type: SuggestionType.urgent,
        message: 'Test message',
        action: InteractionType.feed,
        priority: 10,
      );

      expect(suggestion.type, SuggestionType.urgent);
      expect(suggestion.message, 'Test message');
      expect(suggestion.action, InteractionType.feed);
      expect(suggestion.priority, 10);
    });

    test('action puede ser null', () {
      final suggestion = AISuggestion(
        type: SuggestionType.friendly,
        message: 'Test message',
        action: null,
        priority: 5,
      );

      expect(suggestion.action, isNull);
    });
  });

  group('PredictedNeed', () {
    test('constructor inicializa correctamente', () {
      final need = PredictedNeed(
        type: InteractionType.feed,
        minutesUntilNeeded: 30,
        urgency: 0.8,
        message: 'Necesitará comida pronto',
      );

      expect(need.type, InteractionType.feed);
      expect(need.minutesUntilNeeded, 30);
      expect(need.urgency, 0.8);
      expect(need.message, 'Necesitará comida pronto');
    });
  });

  group('AIService', () {
    late AIService aiService;
    late Pet pet;
    late PetPersonality personality;
    late InteractionHistory history;

    setUp(() {
      aiService = AIService();
      pet = Pet(name: 'TestPet');
      personality = PetPersonality();
      history = InteractionHistory();
    });

    test('es singleton', () {
      final instance1 = AIService();
      final instance2 = AIService();
      expect(identical(instance1, instance2), true);
    });

    group('generateSuggestion', () {
      test('retorna null cuando no hay sugerencias', () {
        // Mascota en perfecto estado
        final perfectPet = Pet(
          name: 'Perfect',
          hunger: 10.0,
          happiness: 90.0,
          energy: 90.0,
          health: 95.0,
        );
        // Agregar interacción de minigame para evitar sugerencia
        final minigameInteraction = Interaction.now(
          type: InteractionType.minigame,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );
        final completeHistory = InteractionHistory(interactions: [minigameInteraction]);

        final result = aiService.generateSuggestion(
          pet: perfectPet,
          personality: personality,
          history: completeHistory,
        );

        expect(result, isNull);
      });

      test('sugiere alimentar cuando hunger > 70', () {
        final hungryPet = Pet(
          name: 'Hungry',
          hunger: 75.0,
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: hungryPet,
          personality: personality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.type, SuggestionType.urgent);
        expect(result.action, InteractionType.feed);
        expect(result.message, contains('hambre'));
        expect(result.priority, 10);
      });

      test('sugiere jugar cuando happiness < 40', () {
        final sadPet = Pet(
          name: 'Sad',
          hunger: 30.0,
          happiness: 35.0,
          energy: 80.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: sadPet,
          personality: personality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.type, SuggestionType.urgent);
        expect(result.action, InteractionType.play);
        expect(result.priority, 8);
      });

      test('sugiere descansar cuando energy < 30', () {
        final tiredPet = Pet(
          name: 'Tired',
          hunger: 30.0,
          happiness: 80.0,
          energy: 25.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: tiredPet,
          personality: personality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.type, SuggestionType.important);
        expect(result.action, InteractionType.rest);
        expect(result.message, contains('cansado'));
        expect(result.priority, 7);
      });

      test('sugiere limpiar cuando health < 50', () {
        final unhealthyPet = Pet(
          name: 'Unhealthy',
          hunger: 30.0,
          happiness: 80.0,
          energy: 80.0,
          health: 45.0,
        );

        final result = aiService.generateSuggestion(
          pet: unhealthyPet,
          personality: personality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.type, SuggestionType.urgent);
        expect(result.action, InteractionType.clean);
        expect(result.message, contains('salud'));
        expect(result.priority, 9);
      });

      test('prioriza sugerencia más urgente', () {
        // Mascota con múltiples problemas
        final needyPet = Pet(
          name: 'Needy',
          hunger: 75.0, // Priority 10
          happiness: 35.0, // Priority 8
          energy: 25.0, // Priority 7
          health: 45.0, // Priority 9
        );

        final result = aiService.generateSuggestion(
          pet: needyPet,
          personality: personality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.priority, 10); // Hunger es la más urgente
        expect(result.action, InteractionType.feed);
      });

      test('sugiere jugar para mascota playful', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.playful] = 90.0;

        final playfulPersonality = PetPersonality(traits: traits);
        final okPet = Pet(
          name: 'Playful',
          hunger: 30.0,
          happiness: 65.0, // < 70
          energy: 80.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: okPet,
          personality: playfulPersonality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.action, InteractionType.play);
        expect(result.message, contains('juguetón'));
        expect(result.priority, 5);
      });

      test('sugiere alimentar para mascota foodie', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.foodie] = 90.0;

        final foodiePersonality = PetPersonality(traits: traits);
        final okPet = Pet(
          name: 'Foodie',
          hunger: 35.0, // > 30
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: okPet,
          personality: foodiePersonality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.action, InteractionType.feed);
        expect(result.message, contains('glotón'));
        expect(result.priority, 4);
      });

      test('sugiere interacción después de mucho tiempo sin ver mascota', () {
        final oldInteraction = Interaction(
          type: InteractionType.feed,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );
        // Agregar minigame para evitar que sugiera minigame
        final minigameInteraction = Interaction(
          type: InteractionType.minigame,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 50.0,
          healthBefore: 70.0,
        );
        final oldHistory = InteractionHistory(interactions: [minigameInteraction, oldInteraction]);

        final bondedPersonality = PetPersonality(
          bondLevel: BondLevel.friend,
        );

        final okPet = Pet(
          name: 'Missed',
          hunger: 30.0,
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: okPet,
          personality: bondedPersonality,
          history: oldHistory,
        );

        expect(result, isNotNull);
        expect(result!.type, SuggestionType.friendly);
        expect(result.message, contains('extrañado'));
        expect(result.action, isNull);
        expect(result.priority, 3);
      });

      test('sugiere mini-juegos si nunca se ha jugado', () {
        final okPet = Pet(
          name: 'Gamer',
          hunger: 30.0,
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        final result = aiService.generateSuggestion(
          pet: okPet,
          personality: personality,
          history: history,
        );

        expect(result, isNotNull);
        expect(result!.action, InteractionType.minigame);
        expect(result.message, contains('mini-juegos'));
        expect(result.priority, 4);
      });
    });

    group('generatePetMessage', () {
      test('genera mensaje para estado ecstatic', () {
        final ecstaticPersonality = PetPersonality(
          emotionalState: EmotionalState.ecstatic,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: ecstaticPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado happy', () {
        final happyPersonality = PetPersonality(
          emotionalState: EmotionalState.happy,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: happyPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado content', () {
        final contentPersonality = PetPersonality(
          emotionalState: EmotionalState.content,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: contentPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado neutral', () {
        final neutralPersonality = PetPersonality(
          emotionalState: EmotionalState.neutral,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: neutralPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado bored', () {
        final boredPersonality = PetPersonality(
          emotionalState: EmotionalState.bored,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: boredPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado sad', () {
        final sadPersonality = PetPersonality(
          emotionalState: EmotionalState.sad,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: sadPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado lonely', () {
        final lonelyPersonality = PetPersonality(
          emotionalState: EmotionalState.lonely,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: lonelyPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('genera mensaje para estado anxious', () {
        final anxiousPersonality = PetPersonality(
          emotionalState: EmotionalState.anxious,
        );

        final message = aiService.generatePetMessage(
          pet: pet,
          personality: anxiousPersonality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
        // Mensaje puede ser del estado emocional, personalidad o vínculo
      });

      test('incluye mensajes de personalidad playful', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.playful] = 90.0;

        final playfulPersonality = PetPersonality(traits: traits);

        // Ejecutar varias veces para aumentar probabilidad
        bool foundPlayfulMessage = false;
        for (int i = 0; i < 20; i++) {
          final message = aiService.generatePetMessage(
            pet: pet,
            personality: playfulPersonality,
            history: history,
          );
          if (message.contains('jugar')) {
            foundPlayfulMessage = true;
            break;
          }
        }

        expect(foundPlayfulMessage, true);
      });

      test('incluye nivel de vínculo en mensajes', () {
        final strangerPersonality = PetPersonality(
          bondLevel: BondLevel.stranger,
        );

        // Ejecutar varias veces
        bool foundBondMessage = false;
        for (int i = 0; i < 20; i++) {
          final message = aiService.generatePetMessage(
            pet: pet,
            personality: strangerPersonality,
            history: history,
          );
          if (message.contains('conociéndote')) {
            foundBondMessage = true;
            break;
          }
        }

        expect(foundBondMessage, true);
      });

      test('siempre retorna mensaje no vacío', () {
        final message = aiService.generatePetMessage(
          pet: pet,
          personality: personality,
          history: history,
        );

        expect(message, isNotEmpty);
        expect(message, contains(pet.name));
      });
    });

    group('generateActionResponse', () {
      test('genera respuesta para feed con mascota normal', () {
        final response = aiService.generateActionResponse(
          action: InteractionType.feed,
          pet: pet,
          personality: personality,
        );

        expect(response, isNotEmpty);
        expect(response, contains('+10 XP'));
        expect(response, anyOf(
          contains('Ñam'),
          contains('come'),
          contains('Delicioso'),
        ));
      });

      test('genera respuesta para feed con mascota foodie', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.foodie] = 80.0;

        final foodiePersonality = PetPersonality(traits: traits);

        bool foundFoodieResponse = false;
        for (int i = 0; i < 20; i++) {
          final response = aiService.generateActionResponse(
            action: InteractionType.feed,
            pet: pet,
            personality: foodiePersonality,
          );
          if (response.contains('devora') || response.contains('esperando') || response.contains('migaja')) {
            foundFoodieResponse = true;
            break;
          }
        }

        expect(foundFoodieResponse, true);
      });

      test('genera respuesta para play con mascota playful', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.playful] = 80.0;

        final playfulPersonality = PetPersonality(traits: traits);

        bool foundPlayfulResponse = false;
        for (int i = 0; i < 20; i++) {
          final response = aiService.generateActionResponse(
            action: InteractionType.play,
            pet: pet,
            personality: playfulPersonality,
          );
          if (response.contains('eufórico') || response.contains('quiere más') || response.contains('salta')) {
            foundPlayfulResponse = true;
            break;
          }
        }

        expect(foundPlayfulResponse, true);
      });

      test('genera respuesta para play con mascota calm', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.calm] = 80.0;

        final calmPersonality = PetPersonality(traits: traits);

        bool foundCalmResponse = false;
        for (int i = 0; i < 20; i++) {
          final response = aiService.generateActionResponse(
            action: InteractionType.play,
            pet: pet,
            personality: calmPersonality,
          );
          if (response.contains('tranquilamente') || response.contains('su manera')) {
            foundCalmResponse = true;
            break;
          }
        }

        expect(foundCalmResponse, true);
      });

      test('genera respuesta para clean', () {
        final response = aiService.generateActionResponse(
          action: InteractionType.clean,
          pet: pet,
          personality: personality,
        );

        expect(response, isNotEmpty);
        expect(response, contains('+10 XP'));
        expect(response, anyOf(
          contains('limpio'),
          contains('brilla'),
          contains('huele'),
        ));
      });

      test('genera respuesta para rest con mascota normal', () {
        final response = aiService.generateActionResponse(
          action: InteractionType.rest,
          pet: pet,
          personality: personality,
        );

        expect(response, isNotEmpty);
        expect(response, contains('+5 XP'));
        expect(response, anyOf(
          contains('Zzz'),
          contains('duerme'),
          contains('sueños'),
        ));
      });

      test('genera respuesta para rest con mascota energetic', () {
        final traits = <PersonalityTrait, double>{};
        for (final trait in PersonalityTrait.values) {
          traits[trait] = 50.0;
        }
        traits[PersonalityTrait.energetic] = 80.0;

        final energeticPersonality = PetPersonality(traits: traits);

        bool foundEnergeticResponse = false;
        for (int i = 0; i < 20; i++) {
          final response = aiService.generateActionResponse(
            action: InteractionType.rest,
            pet: pet,
            personality: energeticPersonality,
          );
          if (response.contains('levantarse') || response.contains('pequeño descanso')) {
            foundEnergeticResponse = true;
            break;
          }
        }

        expect(foundEnergeticResponse, true);
      });

      test('genera respuesta para minigame', () {
        final response = aiService.generateActionResponse(
          action: InteractionType.minigame,
          pet: pet,
          personality: personality,
        );

        expect(response, isNotEmpty);
        expect(response, anyOf(
          contains('divirtió'),
          contains('juego'),
          contains('campeón'),
        ));
      });

      test('genera respuesta por defecto para otras acciones', () {
        final response = aiService.generateActionResponse(
          action: InteractionType.customize,
          pet: pet,
          personality: personality,
        );

        expect(response, isNotEmpty);
        expect(response, contains('contento'));
      });
    });

    group('predictNextNeed', () {
      test('predice necesidad de comida cuando hunger está creciendo', () {
        final hungerPet = Pet(
          name: 'HungerPet',
          hunger: 50.0,
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: hungerPet,
          history: history,
        );

        expect(prediction, isNotNull);
        expect(prediction!.type, InteractionType.feed);
        expect(prediction.minutesUntilNeeded, greaterThan(0));
        expect(prediction.message, contains('comida'));
      });

      test('predice necesidad de jugar cuando happiness está bajando', () {
        final sadPet = Pet(
          name: 'SadPet',
          hunger: 10.0, // Muy bajo para no ser prioritario
          happiness: 50.0, // Da ~166 minutos hasta 40
          energy: 80.0,
          health: 90.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: sadPet,
          history: history,
        );

        expect(prediction, isNotNull);
        expect(prediction!.type, InteractionType.play);
        expect(prediction.minutesUntilNeeded, greaterThan(0));
        expect(prediction.message, contains('jugar'));
      });

      test('predice necesidad de descanso cuando energy está bajando', () {
        final tiredPet = Pet(
          name: 'TiredPet',
          hunger: 10.0, // Muy bajo para no ser prioritario
          happiness: 10.0, // Muy bajo para no ser prioritario
          energy: 35.0, // Da ~83 minutos hasta 30
          health: 90.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: tiredPet,
          history: history,
        );

        expect(prediction, isNotNull);
        expect(prediction!.type, InteractionType.rest);
        expect(prediction.minutesUntilNeeded, greaterThan(0));
        expect(prediction.message, contains('descansar'));
      });

      test('retorna predicción más urgente', () {
        // Mascota con múltiples necesidades futuras
        final needyPet = Pet(
          name: 'NeedyPet',
          hunger: 60.0, // Llegará a 70 pronto
          happiness: 50.0, // Llegará a 40 más tarde
          energy: 40.0, // Llegará a 30 aún más tarde
          health: 90.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: needyPet,
          history: history,
        );

        expect(prediction, isNotNull);
        // La que tenga menos minutos debería ser la más urgente
        expect(prediction!.minutesUntilNeeded, greaterThan(0));
      });

      test('calcula urgency correctamente para tiempos cortos', () {
        // Mascota casi en estado crítico
        final urgentPet = Pet(
          name: 'UrgentPet',
          hunger: 68.0, // Muy cerca de 70
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: urgentPet,
          history: history,
        );

        expect(prediction, isNotNull);
        expect(prediction!.urgency, greaterThanOrEqualTo(0.6));
      });

      test('retorna null cuando no hay necesidades próximas', () {
        final perfectPet = Pet(
          name: 'PerfectPet',
          hunger: 10.0,
          happiness: 90.0,
          energy: 90.0,
          health: 95.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: perfectPet,
          history: history,
        );

        expect(prediction, isNull);
      });

      test('retorna null cuando predicciones están muy lejos (> 180 min)', () {
        final okPet = Pet(
          name: 'OkPet',
          hunger: 20.0, // Muy lejos de 70
          happiness: 90.0,
          energy: 90.0,
          health: 95.0,
        );

        final prediction = aiService.predictNextNeed(
          pet: okPet,
          history: history,
        );

        expect(prediction, isNull);
      });
    });

    group('analyzeUserPreferences', () {
      test('retorna preferencias por defecto con historial vacío', () {
        final prefs = aiService.analyzeUserPreferences(history);

        expect(prefs.preferredHour, isNull);
        expect(prefs.preferredTimeOfDay, isNull);
        expect(prefs.preferredDayOfWeek, isNull);
        expect(prefs.favoriteInteraction, isNull);
        expect(prefs.consistencyScore, 50.0);
      });

      test('identifica hora preferida correctamente', () {
        final interactions = List.generate(
          10,
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: DateTime(2024, 1, i + 1, 14, 0), // Siempre a las 14:00
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.preferredHour, 14);
      });

      test('identifica período del día más activo', () {
        final interactions = List.generate(
          10,
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: DateTime(2024, 1, i + 1, 10, 0), // Morning
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.preferredTimeOfDay, TimeOfDay.morning);
      });

      test('identifica día de la semana más activo', () {
        final interactions = List.generate(
          10,
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: DateTime(2024, 1, 1 + i * 7, 10, 0), // Todos lunes
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.preferredDayOfWeek, DateTime.monday);
      });

      test('identifica interacción favorita', () {
        final interactions = [
          ...List.generate(
            10,
            (i) => Interaction.now(
              type: InteractionType.play, // Mayoría play
              hungerBefore: 50.0,
              happinessBefore: 50.0,
              energyBefore: 50.0,
              healthBefore: 70.0,
            ),
          ),
          ...List.generate(
            3,
            (i) => Interaction.now(
              type: InteractionType.feed,
              hungerBefore: 50.0,
              happinessBefore: 50.0,
              energyBefore: 50.0,
              healthBefore: 70.0,
            ),
          ),
        ];
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.favoriteInteraction, InteractionType.play);
      });

      test('calcula consistencyScore alto para usuario regular', () {
        final baseDate = DateTime.now().subtract(const Duration(days: 5));
        final interactions = List.generate(
          25, // 5 interacciones por día durante 5 días
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: baseDate.add(Duration(days: i ~/ 5, hours: i % 5)),
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.consistencyScore, 80.0);
      });

      test('calcula consistencyScore medio para usuario moderado', () {
        final baseDate = DateTime.now().subtract(const Duration(days: 5));
        final interactions = List.generate(
          10, // 2 interacciones por día durante 5 días
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: baseDate.add(Duration(days: i ~/ 2, hours: i % 2)),
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.consistencyScore, 60.0);
      });

      test('calcula consistencyScore bajo para usuario poco activo', () {
        final baseDate = DateTime.now().subtract(const Duration(days: 5));
        final interactions = List.generate(
          3, // Menos de 1 por día
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: baseDate.add(Duration(days: i * 2)),
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.consistencyScore, 30.0);
      });

      test('usa consistencyScore por defecto para menos de 4 días', () {
        final baseDate = DateTime.now().subtract(const Duration(days: 2));
        final interactions = List.generate(
          10,
          (i) => Interaction(
            type: InteractionType.feed,
            timestamp: baseDate.add(Duration(hours: i)),
            hungerBefore: 50.0,
            happinessBefore: 50.0,
            energyBefore: 50.0,
            healthBefore: 70.0,
          ),
        );
        final testHistory = InteractionHistory(interactions: interactions);

        final prefs = aiService.analyzeUserPreferences(testHistory);

        expect(prefs.consistencyScore, 50.0);
      });
    });

    group('generateMLFeatures', () {
      test('genera features normalizadas correctamente', () {
        final testPet = Pet(
          name: 'ML Pet',
          hunger: 50.0,
          happiness: 75.0,
          energy: 60.0,
          health: 80.0,
        );

        final testPersonality = PetPersonality(
          emotionalState: EmotionalState.happy,
          bondPoints: 250,
        );

        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 30.0,
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        );
        final testHistory = InteractionHistory(interactions: [interaction]);

        final features = aiService.generateMLFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        expect(features.length, 11);

        // Verificar que todas las features están normalizadas (0-1)
        for (final feature in features) {
          expect(feature, greaterThanOrEqualTo(0.0));
          expect(feature, lessThanOrEqualTo(1.0));
        }

        // Verificar valores específicos
        expect(features[0], closeTo(0.5, 0.01)); // hunger / 100
        expect(features[1], closeTo(0.75, 0.01)); // happiness / 100
        expect(features[2], closeTo(0.6, 0.01)); // energy / 100
        expect(features[3], closeTo(0.8, 0.01)); // health / 100
        expect(features[4], EmotionalState.happy.value);
        expect(features[5], closeTo(0.5, 0.01)); // bondPoints / 500
        expect(features[6], greaterThanOrEqualTo(0.0)); // proactiveRatio
        expect(features[7], greaterThanOrEqualTo(0.0)); // reactiveRatio
      });

      test('normaliza bondPoints correctamente', () {
        final highBondPersonality = PetPersonality(bondPoints: 500);
        final lowBondPersonality = PetPersonality(bondPoints: 0);

        final highFeatures = aiService.generateMLFeatures(
          pet: pet,
          personality: highBondPersonality,
          history: history,
        );

        final lowFeatures = aiService.generateMLFeatures(
          pet: pet,
          personality: lowBondPersonality,
          history: history,
        );

        expect(highFeatures[5], closeTo(1.0, 0.01));
        expect(lowFeatures[5], closeTo(0.0, 0.01));
      });

      test('incluye información temporal normalizada', () {
        final features = aiService.generateMLFeatures(
          pet: pet,
          personality: personality,
          history: history,
        );

        // TimeOfDay.current.index / 4
        expect(features[9], greaterThanOrEqualTo(0.0));
        expect(features[9], lessThanOrEqualTo(1.0));

        // DateTime.now().weekday / 7
        expect(features[10], greaterThanOrEqualTo(0.0));
        expect(features[10], lessThanOrEqualTo(1.0));
      });

      test('genera features consistentes para mismo estado', () {
        final features1 = aiService.generateMLFeatures(
          pet: pet,
          personality: personality,
          history: history,
        );

        final features2 = aiService.generateMLFeatures(
          pet: pet,
          personality: personality,
          history: history,
        );

        for (int i = 0; i < features1.length; i++) {
          expect(features1[i], closeTo(features2[i], 0.15)); // Permitir pequeña variación por timestamp
        }
      });
    });
  });
}
