import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/ml_prediction.dart';
import 'package:tamagotchi/utils/ml_constants.dart';

void main() {
  group('MLConstants', () {
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
        expect(PredictedAction.fromIndex(-1), PredictedAction.other);
      });

      test('cada acción tiene displayName y emoji', () {
        for (final action in PredictedAction.values) {
          expect(action.displayName.isNotEmpty, true);
          expect(action.emoji.isNotEmpty, true);
        }
      });
    });

    group('CriticalMetric', () {
      test('tiene 4 métricas definidas', () {
        expect(CriticalMetric.values.length, 4);
      });

      test('fromIndex retorna métrica correcta', () {
        expect(CriticalMetric.fromIndex(0), CriticalMetric.hunger);
        expect(CriticalMetric.fromIndex(1), CriticalMetric.happiness);
        expect(CriticalMetric.fromIndex(2), CriticalMetric.energy);
        expect(CriticalMetric.fromIndex(3), CriticalMetric.health);
      });

      test('cada métrica tiene umbral crítico definido', () {
        expect(CriticalMetric.hunger.criticalThreshold, 70.0);
        expect(CriticalMetric.happiness.criticalThreshold, 30.0);
        expect(CriticalMetric.energy.criticalThreshold, 20.0);
        expect(CriticalMetric.health.criticalThreshold, 30.0);
      });
    });

    group('MLFeatureConfig', () {
      test('ActionPredictor tiene configuración correcta', () {
        expect(MLFeatureConfig.actionPredictorInputSize, 15);
        expect(MLFeatureConfig.actionPredictorOutputSize, 6);
      });

      test('CriticalTimePredictor tiene configuración correcta', () {
        expect(MLFeatureConfig.criticalTimePredictorInputSize, 20);
        expect(MLFeatureConfig.criticalTimePredictorOutputSize, 4);
      });

      test('ActionRecommender tiene configuración correcta', () {
        expect(MLFeatureConfig.actionRecommenderInputSize, 25);
        expect(MLFeatureConfig.actionRecommenderOutputSize, 7);
      });

      test('EmotionClassifier tiene configuración correcta', () {
        expect(MLFeatureConfig.emotionClassifierInputSize, 16);
        expect(MLFeatureConfig.emotionClassifierOutputSize, 8);
      });
    });
  });

  group('ActionPrediction', () {
    test('se crea correctamente desde probabilidades', () {
      final probs = [0.1, 0.5, 0.15, 0.1, 0.1, 0.05];
      final prediction = ActionPrediction.fromProbabilities(probs);

      expect(prediction.predictedAction, PredictedAction.play);
      expect(prediction.confidence, 0.5);
      expect(prediction.probabilities.length, 6);
    });

    test('lanza error si probabilidades no tienen tamaño correcto', () {
      expect(
        () => ActionPrediction.fromProbabilities([0.5, 0.5]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getTopActions retorna acciones ordenadas', () {
      final probs = [0.1, 0.4, 0.2, 0.15, 0.1, 0.05];
      final prediction = ActionPrediction.fromProbabilities(probs);
      final topActions = prediction.getTopActions(3);

      expect(topActions.length, 3);
      expect(topActions[0].key, PredictedAction.play);
      expect(topActions[1].key, PredictedAction.clean);
      expect(topActions[2].key, PredictedAction.rest);
    });

    test('isHighConfidence es true para confianza > 0.7', () {
      final highConfidence = ActionPrediction.fromProbabilities(
        [0.05, 0.05, 0.05, 0.05, 0.05, 0.75],
      );
      expect(highConfidence.isHighConfidence, true);
      expect(highConfidence.isMediumConfidence, false);
      expect(highConfidence.isLowConfidence, false);
    });

    test('isMediumConfidence es true para confianza entre 0.4 y 0.7', () {
      final mediumConfidence = ActionPrediction.fromProbabilities(
        [0.1, 0.1, 0.5, 0.1, 0.1, 0.1],
      );
      expect(mediumConfidence.isHighConfidence, false);
      expect(mediumConfidence.isMediumConfidence, true);
      expect(mediumConfidence.isLowConfidence, false);
    });

    test('isLowConfidence es true para confianza <= 0.4', () {
      final lowConfidence = ActionPrediction.fromProbabilities(
        [0.2, 0.2, 0.2, 0.2, 0.1, 0.1],
      );
      expect(lowConfidence.isHighConfidence, false);
      expect(lowConfidence.isMediumConfidence, false);
      expect(lowConfidence.isLowConfidence, true);
    });

    test('toString incluye información relevante', () {
      final prediction = ActionPrediction.fromProbabilities(
        [0.8, 0.05, 0.05, 0.05, 0.025, 0.025],
      );
      final str = prediction.toString();

      expect(str.contains('Alimentar'), true);
      expect(str.contains('80.0%'), true);
    });
  });

  group('CriticalTimePrediction', () {
    test('se crea correctamente desde output del modelo', () {
      final output = [60.0, 120.0, 45.0, 180.0]; // hunger, happiness, energy, health
      final prediction = CriticalTimePrediction.fromModelOutput(output);

      expect(prediction.mostUrgent, CriticalMetric.energy);
      expect(prediction.getMinutesFor(CriticalMetric.energy), 45.0);
    });

    test('lanza error si output no tiene tamaño correcto', () {
      expect(
        () => CriticalTimePrediction.fromModelOutput([60.0, 120.0]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isUrgent es true si alguna métrica < 30 min', () {
      final urgent = CriticalTimePrediction.fromModelOutput(
        [25.0, 60.0, 90.0, 120.0],
      );
      expect(urgent.isUrgent, true);
    });

    test('isCritical es true si alguna métrica < 10 min', () {
      final critical = CriticalTimePrediction.fromModelOutput(
        [5.0, 60.0, 90.0, 120.0],
      );
      expect(critical.isCritical, true);
    });

    test('urgencyScore es alto para tiempo cercano', () {
      final veryUrgent = CriticalTimePrediction.fromModelOutput(
        [10.0, 60.0, 90.0, 120.0],
      );
      expect(veryUrgent.urgencyScore, greaterThan(0.9));
    });

    test('urgencyScore es bajo para tiempo lejano', () {
      final notUrgent = CriticalTimePrediction.fromModelOutput(
        [150.0, 160.0, 170.0, 180.0],
      );
      expect(notUrgent.urgencyScore, lessThan(0.2));
    });
  });

  group('ActionRecommendation', () {
    test('se crea correctamente desde output del modelo', () {
      // 6 scores + 1 urgencia
      final output = [0.3, 0.6, 0.1, 0.1, 0.05, 0.05, 0.7];
      final recommendation = ActionRecommendation.fromModelOutput(output);

      expect(recommendation.recommendedAction, PredictedAction.play);
      expect(recommendation.urgency, 0.7);
      expect(recommendation.isUrgent, false); // 0.7 <= 0.7
    });

    test('lanza error si output no tiene tamaño correcto', () {
      expect(
        () => ActionRecommendation.fromModelOutput([0.5, 0.5]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isUrgent es true para urgencia > 0.7', () {
      final urgent = ActionRecommendation.fromModelOutput(
        [0.5, 0.2, 0.1, 0.1, 0.05, 0.05, 0.85],
      );
      expect(urgent.isUrgent, true);
    });

    test('reason varía según urgencia', () {
      final veryUrgent = ActionRecommendation.fromModelOutput(
        [0.5, 0.2, 0.1, 0.1, 0.05, 0.05, 0.9],
      );
      expect(veryUrgent.reason.contains('urgentemente'), true);

      final notUrgent = ActionRecommendation.fromModelOutput(
        [0.5, 0.2, 0.1, 0.1, 0.05, 0.05, 0.3],
      );
      expect(notUrgent.reason.contains('considerar'), true);
    });
  });

  group('EmotionPrediction', () {
    test('se crea correctamente desde probabilidades', () {
      final probs = [0.05, 0.6, 0.15, 0.1, 0.05, 0.02, 0.02, 0.01];
      final prediction = EmotionPrediction.fromProbabilities(probs);

      expect(prediction.predictedEmotion, 'Feliz');
      expect(prediction.emotionIndex, 1);
      expect(prediction.confidence, 0.6);
    });

    test('lanza error si probabilidades no tienen tamaño correcto', () {
      expect(
        () => EmotionPrediction.fromProbabilities([0.5, 0.5]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('emoji corresponde al estado emocional', () {
      final happy = EmotionPrediction.fromProbabilities(
        [0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      );
      expect(happy.emoji, '😊');

      final anxious = EmotionPrediction.fromProbabilities(
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0],
      );
      expect(anxious.emoji, '😰');
    });

    test('isPositive es true para índices 0-2', () {
      final ecstatic = EmotionPrediction.fromProbabilities(
        [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      );
      expect(ecstatic.isPositive, true);
      expect(ecstatic.isNegative, false);
      expect(ecstatic.isNeutral, false);
    });

    test('isNegative es true para índices 5-7', () {
      final sad = EmotionPrediction.fromProbabilities(
        [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0],
      );
      expect(sad.isPositive, false);
      expect(sad.isNegative, true);
      expect(sad.isNeutral, false);
    });

    test('isNeutral es true para índices 3-4', () {
      final neutral = EmotionPrediction.fromProbabilities(
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
      );
      expect(neutral.isPositive, false);
      expect(neutral.isNegative, false);
      expect(neutral.isNeutral, true);
    });

    test('emotionNames tiene 8 estados', () {
      expect(EmotionPrediction.emotionNames.length, 8);
    });

    test('emotionEmojis tiene 8 emojis', () {
      expect(EmotionPrediction.emotionEmojis.length, 8);
    });
  });

  group('MLStatus', () {
    test('se crea correctamente con estado inicializado', () {
      final status = MLStatus(
        isInitialized: true,
        availableModels: ['ActionPredictor', 'EmotionClassifier'],
        lastInferenceTime: DateTime.now(),
      );

      expect(status.isInitialized, true);
      expect(status.availableModels.length, 2);
      expect(status.error, isNull);
    });

    test('factory error crea estado con error', () {
      final status = MLStatus.error('Modelo no encontrado');

      expect(status.isInitialized, false);
      expect(status.availableModels.isEmpty, true);
      expect(status.error, 'Modelo no encontrado');
    });

    test('factory notInitialized crea estado vacío', () {
      final status = MLStatus.notInitialized();

      expect(status.isInitialized, false);
      expect(status.availableModels.isEmpty, true);
      expect(status.error, isNull);
    });

    test('toString incluye información del estado', () {
      final initialized = MLStatus(
        isInitialized: true,
        availableModels: ['Model1', 'Model2'],
        lastInferenceTime: DateTime.now(),
      );
      expect(initialized.toString().contains('initialized'), true);
      expect(initialized.toString().contains('2'), true);

      final notInit = MLStatus.notInitialized();
      expect(notInit.toString().contains('not initialized'), true);
    });
  });

  group('MLModelPaths', () {
    test('todas las rutas apuntan a assets/models/', () {
      expect(
        MLModelPaths.actionPredictor.startsWith('assets/models/'),
        true,
      );
      expect(
        MLModelPaths.criticalTimePredictor.startsWith('assets/models/'),
        true,
      );
      expect(
        MLModelPaths.actionRecommender.startsWith('assets/models/'),
        true,
      );
      expect(
        MLModelPaths.emotionClassifier.startsWith('assets/models/'),
        true,
      );
    });

    test('todas las rutas terminan en .tflite', () {
      expect(MLModelPaths.actionPredictor.endsWith('.tflite'), true);
      expect(MLModelPaths.criticalTimePredictor.endsWith('.tflite'), true);
      expect(MLModelPaths.actionRecommender.endsWith('.tflite'), true);
      expect(MLModelPaths.emotionClassifier.endsWith('.tflite'), true);
    });
  });

  group('MLPerformanceConfig', () {
    test('tiene valores de configuración razonables', () {
      expect(MLPerformanceConfig.inferenceTimeoutMs, greaterThan(0));
      expect(MLPerformanceConfig.slowInferenceThresholdMs, greaterThan(0));
      expect(MLPerformanceConfig.numThreads, greaterThanOrEqualTo(0));
    });
  });
}
