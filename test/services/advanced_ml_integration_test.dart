import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/pet_personality.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/models/ml_prediction.dart';
import 'package:tamagotchi/utils/ml_constants.dart';
import 'package:tamagotchi/services/ai_service.dart';

void main() {
  group('ActionRecommendation', () {
    test('se crea correctamente desde output del modelo', () {
      // 6 scores + 1 urgency
      final output = [0.8, 0.3, 0.5, 0.2, 0.6, 0.1, 0.7];
      final recommendation = ActionRecommendation.fromModelOutput(output);

      expect(recommendation.scores.length, 6);
      expect(recommendation.recommendedAction, PredictedAction.feed); // 0.8 is max
      expect(recommendation.urgency, 0.7);
    });

    test('identifica la acción recomendada correctamente', () {
      // play tiene el mayor score (0.9)
      final output = [0.3, 0.9, 0.5, 0.2, 0.6, 0.1, 0.5];
      final recommendation = ActionRecommendation.fromModelOutput(output);

      expect(recommendation.recommendedAction, PredictedAction.play);
    });

    test('isUrgent es true cuando urgency > 0.7', () {
      final urgentOutput = [0.5, 0.3, 0.5, 0.2, 0.6, 0.1, 0.85];
      final recommendation = ActionRecommendation.fromModelOutput(urgentOutput);

      expect(recommendation.isUrgent, true);
    });

    test('isUrgent es false cuando urgency <= 0.7', () {
      final normalOutput = [0.5, 0.3, 0.5, 0.2, 0.6, 0.1, 0.5];
      final recommendation = ActionRecommendation.fromModelOutput(normalOutput);

      expect(recommendation.isUrgent, false);
    });

    test('genera razón apropiada para urgencia alta', () {
      final urgentOutput = [0.8, 0.3, 0.5, 0.2, 0.6, 0.1, 0.85];
      final recommendation = ActionRecommendation.fromModelOutput(urgentOutput);

      expect(recommendation.reason.contains('urgentemente'), true);
    });

    test('genera razón apropiada para urgencia media', () {
      final mediumOutput = [0.8, 0.3, 0.5, 0.2, 0.6, 0.1, 0.6];
      final recommendation = ActionRecommendation.fromModelOutput(mediumOutput);

      expect(recommendation.reason.contains('pronto'), true);
    });

    test('clamp urgency a 0-1', () {
      final output = [0.5, 0.3, 0.5, 0.2, 0.6, 0.1, 1.5]; // urgency > 1
      final recommendation = ActionRecommendation.fromModelOutput(output);

      expect(recommendation.urgency, 1.0);
    });

    test('lanza error si output no tiene 7 elementos', () {
      expect(
        () => ActionRecommendation.fromModelOutput([0.5, 0.3, 0.5]),
        throwsArgumentError,
      );
    });

    test('toString incluye información relevante', () {
      final output = [0.8, 0.3, 0.5, 0.2, 0.6, 0.1, 0.7];
      final recommendation = ActionRecommendation.fromModelOutput(output);

      final str = recommendation.toString();
      expect(str.contains('Alimentar'), true);
      expect(str.contains('70%'), true);
    });
  });

  group('EmotionPrediction', () {
    test('se crea correctamente desde probabilidades', () {
      // 8 probabilidades para 8 emociones
      final probs = [0.05, 0.7, 0.1, 0.05, 0.03, 0.03, 0.02, 0.02];
      final prediction = EmotionPrediction.fromProbabilities(probs);

      expect(prediction.probabilities.length, 8);
      expect(prediction.emotionIndex, 1); // happy tiene la mayor prob
      expect(prediction.predictedEmotion, 'Feliz');
      expect(prediction.confidence, 0.7);
    });

    test('identifica emoción correctamente para cada índice', () {
      for (int i = 0; i < 8; i++) {
        final probs = List.generate(8, (j) => j == i ? 0.9 : 0.01);
        // Normalizar para que sume ~1
        final sum = probs.reduce((a, b) => a + b);
        final normalized = probs.map((p) => p / sum).toList();

        final prediction = EmotionPrediction.fromProbabilities(normalized);
        expect(prediction.emotionIndex, i);
      }
    });

    test('emoji retorna valor correcto', () {
      final happyProbs = [0.05, 0.8, 0.05, 0.03, 0.03, 0.02, 0.01, 0.01];
      final prediction = EmotionPrediction.fromProbabilities(happyProbs);

      expect(prediction.emoji, EmotionPrediction.emotionEmojis[1]);
    });

    test('isPositive es true para índices 0-2', () {
      // Extasiado
      var probs = List.generate(8, (j) => j == 0 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isPositive, true);

      // Feliz
      probs = List.generate(8, (j) => j == 1 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isPositive, true);

      // Contento
      probs = List.generate(8, (j) => j == 2 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isPositive, true);
    });

    test('isNegative es true para índices 5-7', () {
      // Triste
      var probs = List.generate(8, (j) => j == 5 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isNegative, true);

      // Solo
      probs = List.generate(8, (j) => j == 6 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isNegative, true);

      // Ansioso
      probs = List.generate(8, (j) => j == 7 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isNegative, true);
    });

    test('isNeutral es true para índices 3-4', () {
      // Neutral
      var probs = List.generate(8, (j) => j == 3 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isNeutral, true);

      // Aburrido
      probs = List.generate(8, (j) => j == 4 ? 0.9 : 0.01);
      expect(EmotionPrediction.fromProbabilities(probs).isNeutral, true);
    });

    test('lanza error si probabilidades no tienen 8 elementos', () {
      expect(
        () => EmotionPrediction.fromProbabilities([0.5, 0.3, 0.2]),
        throwsArgumentError,
      );
    });

    test('emotionNames tiene 8 nombres', () {
      expect(EmotionPrediction.emotionNames.length, 8);
    });

    test('emotionEmojis tiene 8 emojis', () {
      expect(EmotionPrediction.emotionEmojis.length, 8);
    });

    test('toString incluye información relevante', () {
      final probs = [0.05, 0.7, 0.1, 0.05, 0.03, 0.03, 0.02, 0.02];
      final prediction = EmotionPrediction.fromProbabilities(probs);

      final str = prediction.toString();
      expect(str.contains('Feliz'), true);
      expect(str.contains('70'), true);
    });
  });

  group('MLFeatureConfig modelos avanzados', () {
    test('ActionRecommender tiene tamaños correctos', () {
      expect(MLFeatureConfig.actionRecommenderInputSize, 25);
      expect(MLFeatureConfig.actionRecommenderOutputSize, 7);
    });

    test('EmotionClassifier tiene tamaños correctos', () {
      expect(MLFeatureConfig.emotionClassifierInputSize, 16);
      expect(MLFeatureConfig.emotionClassifierOutputSize, 8);
    });
  });

  group('AIService modelos avanzados', () {
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

    test('getMLRecommendation retorna null sin ML inicializado', () async {
      final recommendation = await aiService.getMLRecommendation(
        pet: testPet,
        personality: testPersonality,
        history: testHistory,
      );

      expect(recommendation, isNull);
    });

    test('getMLEmotionPrediction retorna null sin ML inicializado', () async {
      final prediction = await aiService.getMLEmotionPrediction(
        pet: testPet,
        personality: testPersonality,
        history: testHistory,
      );

      expect(prediction, isNull);
    });
  });

  group('Estados emocionales', () {
    test('nombres de emociones están en español', () {
      expect(EmotionPrediction.emotionNames[0], 'Extasiado');
      expect(EmotionPrediction.emotionNames[1], 'Feliz');
      expect(EmotionPrediction.emotionNames[2], 'Contento');
      expect(EmotionPrediction.emotionNames[3], 'Neutral');
      expect(EmotionPrediction.emotionNames[4], 'Aburrido');
      expect(EmotionPrediction.emotionNames[5], 'Triste');
      expect(EmotionPrediction.emotionNames[6], 'Solo');
      expect(EmotionPrediction.emotionNames[7], 'Ansioso');
    });

    test('emojis corresponden a emociones', () {
      expect(EmotionPrediction.emotionEmojis[0], contains('🤩'));
      expect(EmotionPrediction.emotionEmojis[1], contains('😊'));
      expect(EmotionPrediction.emotionEmojis[5], contains('😢'));
      expect(EmotionPrediction.emotionEmojis[7], contains('😰'));
    });
  });

  group('PredictedAction', () {
    test('tiene 6 acciones definidas', () {
      expect(PredictedAction.values.length, 6);
    });

    test('fromIndex retorna acción correcta', () {
      expect(PredictedAction.fromIndex(0), PredictedAction.feed);
      expect(PredictedAction.fromIndex(1), PredictedAction.play);
      expect(PredictedAction.fromIndex(2), PredictedAction.clean);
      expect(PredictedAction.fromIndex(3), PredictedAction.rest);
      expect(PredictedAction.fromIndex(4), PredictedAction.minigame);
      expect(PredictedAction.fromIndex(5), PredictedAction.other);
    });

    test('fromIndex retorna other para índice inválido', () {
      expect(PredictedAction.fromIndex(99), PredictedAction.other);
    });

    test('cada acción tiene displayName y emoji', () {
      for (final action in PredictedAction.values) {
        expect(action.displayName.isNotEmpty, true);
        expect(action.emoji.isNotEmpty, true);
      }
    });
  });
}
