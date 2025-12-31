import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/pet_personality.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/models/ml_prediction.dart';
import 'package:tamagotchi/utils/ml_constants.dart';
import 'package:tamagotchi/services/ai_service.dart';

void main() {
  group('ActionPrediction.toSuggestion', () {
    test('genera MLSuggestion con tipo confident para alta confianza', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.85, 0.05, 0.03, 0.03, 0.02, 0.02],
      );

      final suggestion = prediction.toSuggestion(petName: 'TestPet');

      expect(suggestion.type, MLSuggestionType.confident);
      expect(suggestion.confidence, 0.85);
      expect(suggestion.action, InteractionType.feed);
      expect(suggestion.message.contains('TestPet'), true);
    });

    test('genera MLSuggestion con tipo suggestion para confianza media', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.1, 0.55, 0.15, 0.1, 0.05, 0.05],
      );

      final suggestion = prediction.toSuggestion(petName: 'Buddy');

      expect(suggestion.type, MLSuggestionType.suggestion);
      expect(suggestion.predictedAction, PredictedAction.play);
      expect(suggestion.message.contains('Buddy'), true);
    });

    test('genera MLSuggestion con tipo hint para baja confianza', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.2, 0.2, 0.25, 0.15, 0.1, 0.1],
      );

      final suggestion = prediction.toSuggestion(petName: 'Max');

      expect(suggestion.type, MLSuggestionType.hint);
      expect(suggestion.predictedAction, PredictedAction.clean);
    });

    test('prioridad se calcula correctamente', () {
      final highConfidence = ActionPrediction.fromProbabilities(
        [0.9, 0.02, 0.02, 0.02, 0.02, 0.02],
      );
      final lowConfidence = ActionPrediction.fromProbabilities(
        [0.2, 0.2, 0.2, 0.2, 0.1, 0.1],
      );

      expect(
        highConfidence.toSuggestion(petName: 'Pet').priority,
        greaterThan(lowConfidence.toSuggestion(petName: 'Pet').priority),
      );
    });
  });

  group('ActionPrediction.interactionType', () {
    test('feed retorna InteractionType.feed', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.9, 0.02, 0.02, 0.02, 0.02, 0.02],
      );
      expect(prediction.interactionType, InteractionType.feed);
    });

    test('play retorna InteractionType.play', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.02, 0.9, 0.02, 0.02, 0.02, 0.02],
      );
      expect(prediction.interactionType, InteractionType.play);
    });

    test('clean retorna InteractionType.clean', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.02, 0.02, 0.9, 0.02, 0.02, 0.02],
      );
      expect(prediction.interactionType, InteractionType.clean);
    });

    test('rest retorna InteractionType.rest', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.02, 0.02, 0.02, 0.9, 0.02, 0.02],
      );
      expect(prediction.interactionType, InteractionType.rest);
    });

    test('minigame retorna InteractionType.minigame', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.02, 0.02, 0.02, 0.02, 0.9, 0.02],
      );
      expect(prediction.interactionType, InteractionType.minigame);
    });

    test('other retorna null', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.02, 0.02, 0.02, 0.02, 0.02, 0.9],
      );
      expect(prediction.interactionType, isNull);
    });
  });

  group('MLSuggestionType', () {
    test('tiene 3 tipos definidos', () {
      expect(MLSuggestionType.values.length, 3);
    });

    test('cada tipo tiene displayName y emoji', () {
      for (final type in MLSuggestionType.values) {
        expect(type.displayName.isNotEmpty, true);
        expect(type.emoji.isNotEmpty, true);
      }
    });

    test('confident tiene valores correctos', () {
      expect(MLSuggestionType.confident.displayName, 'Predicción');
      expect(MLSuggestionType.confident.emoji, '🎯');
    });

    test('suggestion tiene valores correctos', () {
      expect(MLSuggestionType.suggestion.displayName, 'Sugerencia');
      expect(MLSuggestionType.suggestion.emoji, '💡');
    });

    test('hint tiene valores correctos', () {
      expect(MLSuggestionType.hint.displayName, 'Idea');
      expect(MLSuggestionType.hint.emoji, '💭');
    });
  });

  group('MLSuggestion', () {
    test('se crea correctamente', () {
      final suggestion = MLSuggestion(
        type: MLSuggestionType.confident,
        message: 'Test message',
        action: InteractionType.feed,
        confidence: 0.85,
        predictedAction: PredictedAction.feed,
      );

      expect(suggestion.type, MLSuggestionType.confident);
      expect(suggestion.message, 'Test message');
      expect(suggestion.action, InteractionType.feed);
      expect(suggestion.confidence, 0.85);
      expect(suggestion.predictedAction, PredictedAction.feed);
    });

    test('priority se calcula desde confidence', () {
      final suggestion = MLSuggestion(
        type: MLSuggestionType.confident,
        message: 'Test',
        action: InteractionType.play,
        confidence: 0.75,
        predictedAction: PredictedAction.play,
      );

      expect(suggestion.priority, 8); // 0.75 * 10 = 7.5 rounded to 8
    });

    test('toString incluye información relevante', () {
      final suggestion = MLSuggestion(
        type: MLSuggestionType.suggestion,
        message: 'Considera jugar',
        action: InteractionType.play,
        confidence: 0.55,
        predictedAction: PredictedAction.play,
      );

      final str = suggestion.toString();
      expect(str.contains('Sugerencia'), true);
      expect(str.contains('55%'), true);
    });
  });

  group('AIService con ML', () {
    late AIService aiService;
    late Pet testPet;
    late PetPersonality testPersonality;
    late InteractionHistory testHistory;

    setUp(() {
      aiService = AIService();
      testPet = Pet(
        name: 'TestPet',
        hunger: 50,
        happiness: 75,
        energy: 60,
        health: 80,
      );
      testPersonality = PetPersonality();
      testHistory = InteractionHistory();
    });

    test('generateSuggestion funciona sin ML', () {
      // Con hunger alto, debería sugerir alimentar
      final hungryPet = Pet(
        name: 'HungryPet',
        hunger: 80,
        happiness: 70,
        energy: 60,
        health: 80,
      );

      final suggestion = aiService.generateSuggestion(
        pet: hungryPet,
        personality: testPersonality,
        history: testHistory,
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.action, InteractionType.feed);
      expect(suggestion.type, SuggestionType.urgent);
    });

    test('generateSmartSuggestion cae a fallback sin ML inicializado', () async {
      // MLService no está inicializado, debería usar fallback
      final hungryPet = Pet(
        name: 'HungryPet',
        hunger: 80,
        happiness: 70,
        energy: 60,
        health: 80,
      );

      final suggestion = await aiService.generateSmartSuggestion(
        pet: hungryPet,
        personality: testPersonality,
        history: testHistory,
      );

      // Debería retornar la misma sugerencia que el método base
      expect(suggestion, isNotNull);
      expect(suggestion!.action, InteractionType.feed);
    });

    test('getMLPrediction retorna null sin ML inicializado', () async {
      final prediction = await aiService.getMLPrediction(
        pet: testPet,
        personality: testPersonality,
        history: testHistory,
      );

      expect(prediction, isNull);
    });
  });

  group('Mensajes de sugerencia', () {
    test('mensajes de alta confianza son directos', () {
      final feedPrediction = ActionPrediction.fromProbabilities(
        [0.9, 0.02, 0.02, 0.02, 0.02, 0.02],
      );

      final suggestion = feedPrediction.toSuggestion(petName: 'Luna');
      expect(suggestion.message.contains('hambre'), true);
    });

    test('mensajes de confianza media son sugerentes', () {
      final playPrediction = ActionPrediction.fromProbabilities(
        [0.1, 0.55, 0.15, 0.1, 0.05, 0.05],
      );

      final suggestion = playPrediction.toSuggestion(petName: 'Max');
      expect(
        suggestion.message.contains('podría') ||
            suggestion.message.contains('Quizás'),
        true,
      );
    });

    test('mensajes de baja confianza son suaves', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.25, 0.2, 0.2, 0.15, 0.1, 0.1],
      );

      final suggestion = prediction.toSuggestion(petName: 'Buddy');
      expect(suggestion.message.contains('Considera'), true);
    });
  });
}
