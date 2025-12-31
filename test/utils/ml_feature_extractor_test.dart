import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/pet_personality.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/utils/ml_feature_extractor.dart';
import 'package:tamagotchi/utils/ml_constants.dart';

void main() {
  group('MLFeatureExtractor', () {
    late Pet testPet;
    late PetPersonality testPersonality;
    late InteractionHistory testHistory;

    setUp(() {
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

    group('extractActionPredictorFeatures', () {
      test('retorna lista de 15 features', () {
        final features = MLFeatureExtractor.extractActionPredictorFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        expect(features.length, MLFeatureConfig.actionPredictorInputSize);
        expect(features.length, 15);
      });

      test('features están normalizadas entre 0 y 1', () {
        final features = MLFeatureExtractor.extractActionPredictorFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        for (final feature in features) {
          expect(feature, greaterThanOrEqualTo(0.0));
          expect(feature, lessThanOrEqualTo(1.0));
        }
      });

      test('métricas de pet se normalizan correctamente', () {
        final features = MLFeatureExtractor.extractActionPredictorFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        expect(features[0], 0.5); // hunger 50/100
        expect(features[1], 0.75); // happiness 75/100
        expect(features[2], 0.6); // energy 60/100
        expect(features[3], 0.8); // health 80/100
      });

      test('one-hot encoding de última acción funciona', () {
        final interactions = [
          Interaction.now(
            type: InteractionType.feed,
            hungerBefore: 60,
            happinessBefore: 70,
            energyBefore: 50,
            healthBefore: 80,
          ),
        ];
        final history = InteractionHistory(interactions: interactions);

        final features = MLFeatureExtractor.extractActionPredictorFeatures(
          pet: testPet,
          personality: testPersonality,
          history: history,
        );

        // Última acción fue feed (índice 10)
        expect(features[10], 1.0); // feed
        expect(features[11], 0.0); // play
        expect(features[12], 0.0); // clean
        expect(features[13], 0.0); // rest
        expect(features[14], 0.0); // minigame
      });
    });

    group('extractCriticalTimeFeatures', () {
      test('retorna lista de 20 features', () {
        final features = MLFeatureExtractor.extractCriticalTimeFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        expect(features.length, MLFeatureConfig.criticalTimePredictorInputSize);
        expect(features.length, 20);
      });

      test('features están normalizadas entre 0 y 1', () {
        final features = MLFeatureExtractor.extractCriticalTimeFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        for (final feature in features) {
          expect(feature, greaterThanOrEqualTo(0.0));
          expect(feature, lessThanOrEqualTo(1.0));
        }
      });

      test('incluye traits de personalidad normalizados', () {
        final features = MLFeatureExtractor.extractCriticalTimeFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        // Traits por defecto son 50, normalizados a 0.5
        expect(features[8], 0.5); // foodie
        expect(features[9], 0.5); // playful
        expect(features[10], 0.5); // energetic
        expect(features[11], 0.5); // calm
        expect(features[12], 0.5); // anxious
      });
    });

    group('extractRecommenderFeatures', () {
      test('retorna lista de 25 features', () {
        final features = MLFeatureExtractor.extractRecommenderFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        expect(features.length, MLFeatureConfig.actionRecommenderInputSize);
        expect(features.length, 25);
      });

      test('features están normalizadas entre 0 y 1', () {
        final features = MLFeatureExtractor.extractRecommenderFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        for (final feature in features) {
          expect(feature, greaterThanOrEqualTo(0.0));
          expect(feature, lessThanOrEqualTo(1.0));
        }
      });

      test('distribución de acciones del día se calcula', () {
        final interactions = [
          Interaction.now(
            type: InteractionType.feed,
            hungerBefore: 60,
            happinessBefore: 70,
            energyBefore: 50,
            healthBefore: 80,
          ),
          Interaction.now(
            type: InteractionType.play,
            hungerBefore: 40,
            happinessBefore: 60,
            energyBefore: 50,
            healthBefore: 80,
          ),
          Interaction.now(
            type: InteractionType.feed,
            hungerBefore: 50,
            happinessBefore: 70,
            energyBefore: 50,
            healthBefore: 80,
          ),
        ];
        final history = InteractionHistory(interactions: interactions);

        final features = MLFeatureExtractor.extractRecommenderFeatures(
          pet: testPet,
          personality: testPersonality,
          history: history,
        );

        // 2/3 feed, 1/3 play
        expect(features[20], closeTo(2 / 3, 0.01)); // feed ratio
        expect(features[21], closeTo(1 / 3, 0.01)); // play ratio
        expect(features[22], 0.0); // clean ratio
        expect(features[23], 0.0); // rest ratio
        expect(features[24], 0.0); // minigame ratio
      });
    });

    group('extractEmotionFeatures', () {
      test('retorna lista de 16 features', () {
        final features = MLFeatureExtractor.extractEmotionFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        expect(features.length, MLFeatureConfig.emotionClassifierInputSize);
        expect(features.length, 16);
      });

      test('features están normalizadas entre 0 y 1', () {
        final features = MLFeatureExtractor.extractEmotionFeatures(
          pet: testPet,
          personality: testPersonality,
          history: testHistory,
        );

        for (final feature in features) {
          expect(feature, greaterThanOrEqualTo(0.0));
          expect(feature, lessThanOrEqualTo(1.0));
        }
      });

      test('incluye estado emocional actual', () {
        final personality = PetPersonality(
          emotionalState: EmotionalState.happy,
        );

        final features = MLFeatureExtractor.extractEmotionFeatures(
          pet: testPet,
          personality: personality,
          history: testHistory,
        );

        // EmotionalState.happy tiene value 0.8
        expect(features[4], 0.8);
        // EmotionalState.happy tiene index 1
        expect(features[5], closeTo(1 / 7, 0.01));
      });
    });
  });

  group('MLTrainingRecord', () {
    test('se crea correctamente', () {
      final record = MLTrainingRecord(
        features: [0.5, 0.6, 0.7, 0.8],
        actionTaken: InteractionType.feed,
        timestamp: DateTime.now(),
        metricsBefore: {
          'hunger': 50.0,
          'happiness': 60.0,
          'energy': 70.0,
          'health': 80.0,
        },
      );

      expect(record.features.length, 4);
      expect(record.actionTaken, InteractionType.feed);
      expect(record.metricsBefore['hunger'], 50.0);
    });

    test('toJson genera formato correcto', () {
      final timestamp = DateTime(2025, 1, 1, 12, 0);
      final record = MLTrainingRecord(
        features: [0.5, 0.6],
        actionTaken: InteractionType.play,
        timeToCritical: [60.0, 120.0, 90.0, 150.0],
        resultingEmotion: EmotionalState.happy,
        timestamp: timestamp,
        metricsBefore: {'hunger': 50.0},
        metricsAfter: {'hunger': 30.0},
      );

      final json = record.toJson();

      expect(json['features'], [0.5, 0.6]);
      expect(json['action_taken'], 'play');
      expect(json['time_to_critical'], [60.0, 120.0, 90.0, 150.0]);
      expect(json['resulting_emotion'], EmotionalState.happy.index);
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['metrics_before'], {'hunger': 50.0});
      expect(json['metrics_after'], {'hunger': 30.0});
    });

    test('fromJson parsea correctamente', () {
      final json = {
        'features': [0.5, 0.6],
        'action_taken': 'feed',
        'time_to_critical': [60.0, 120.0, 90.0, 150.0],
        'resulting_emotion': 1,
        'timestamp': '2025-01-01T12:00:00.000',
        'metrics_before': {'hunger': 50.0},
        'metrics_after': {'hunger': 30.0},
      };

      final record = MLTrainingRecord.fromJson(json);

      expect(record.features, [0.5, 0.6]);
      expect(record.actionTaken, InteractionType.feed);
      expect(record.timeToCritical, [60.0, 120.0, 90.0, 150.0]);
      expect(record.resultingEmotion, EmotionalState.happy);
      expect(record.timestamp.year, 2025);
      expect(record.metricsBefore['hunger'], 50.0);
      expect(record.metricsAfter?['hunger'], 30.0);
    });

    test('campos opcionales pueden ser null', () {
      final record = MLTrainingRecord(
        features: [0.5],
        actionTaken: InteractionType.clean,
        timestamp: DateTime.now(),
        metricsBefore: {'hunger': 50.0},
      );

      expect(record.timeToCritical, isNull);
      expect(record.resultingEmotion, isNull);
      expect(record.metricsAfter, isNull);
    });
  });
}
