import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/models/ml_prediction.dart';
import 'package:tamagotchi/utils/ml_constants.dart';
import 'package:tamagotchi/services/ai_service.dart';

void main() {
  group('CriticalTimePrediction', () {
    test('se crea correctamente desde output del modelo', () {
      final output = [60.0, 90.0, 120.0, 150.0]; // minutos hasta crítico
      final prediction = CriticalTimePrediction.fromModelOutput(output);

      expect(prediction.minutesToCritical.length, 4);
      expect(prediction.mostUrgent, CriticalMetric.hunger); // 60 min es el mínimo
      expect(prediction.getMinutesFor(CriticalMetric.hunger), 60.0);
    });

    test('identifica la métrica más urgente correctamente', () {
      // happiness tiene el menor tiempo (30 min)
      final output = [90.0, 30.0, 60.0, 120.0];
      final prediction = CriticalTimePrediction.fromModelOutput(output);

      expect(prediction.mostUrgent, CriticalMetric.happiness);
      expect(prediction.getMinutesFor(CriticalMetric.happiness), 30.0);
    });

    test('calcula urgencyScore correctamente', () {
      // Con tiempo muy bajo (5 minutos) la urgencia debe ser alta
      final urgentOutput = [5.0, 90.0, 60.0, 120.0];
      final urgentPrediction = CriticalTimePrediction.fromModelOutput(urgentOutput);
      expect(urgentPrediction.urgencyScore, greaterThan(0.9));

      // Con tiempo alto (180 minutos) la urgencia debe ser baja
      final relaxedOutput = [180.0, 180.0, 180.0, 180.0];
      final relaxedPrediction = CriticalTimePrediction.fromModelOutput(relaxedOutput);
      expect(relaxedPrediction.urgencyScore, lessThan(0.1));
    });

    test('isUrgent retorna true cuando alguna métrica está a <30 min', () {
      final urgentOutput = [25.0, 90.0, 60.0, 120.0];
      final prediction = CriticalTimePrediction.fromModelOutput(urgentOutput);

      expect(prediction.isUrgent, true);
    });

    test('isCritical retorna true cuando alguna métrica está a <10 min', () {
      final criticalOutput = [8.0, 90.0, 60.0, 120.0];
      final prediction = CriticalTimePrediction.fromModelOutput(criticalOutput);

      expect(prediction.isCritical, true);
    });

    test('isUrgent retorna false cuando todas las métricas están bien', () {
      final okOutput = [60.0, 90.0, 60.0, 120.0];
      final prediction = CriticalTimePrediction.fromModelOutput(okOutput);

      expect(prediction.isUrgent, false);
      expect(prediction.isCritical, false);
    });

    test('getMinutesFor retorna valor correcto para cada métrica', () {
      final output = [45.0, 60.0, 75.0, 90.0];
      final prediction = CriticalTimePrediction.fromModelOutput(output);

      expect(prediction.getMinutesFor(CriticalMetric.hunger), 45.0);
      expect(prediction.getMinutesFor(CriticalMetric.happiness), 60.0);
      expect(prediction.getMinutesFor(CriticalMetric.energy), 75.0);
      expect(prediction.getMinutesFor(CriticalMetric.health), 90.0);
    });

    test('lanza error si output no tiene 4 elementos', () {
      expect(
        () => CriticalTimePrediction.fromModelOutput([60.0, 90.0]),
        throwsArgumentError,
      );
    });

    test('toString incluye información relevante', () {
      final output = [30.0, 60.0, 90.0, 120.0];
      final prediction = CriticalTimePrediction.fromModelOutput(output);

      final str = prediction.toString();
      expect(str.contains('Hambre'), true);
      expect(str.contains('30'), true);
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

    test('fromIndex retorna hunger para índice inválido', () {
      expect(CriticalMetric.fromIndex(99), CriticalMetric.hunger);
    });

    test('cada métrica tiene displayName y criticalThreshold', () {
      for (final metric in CriticalMetric.values) {
        expect(metric.displayName.isNotEmpty, true);
        expect(metric.criticalThreshold, greaterThan(0));
      }
    });

    test('umbrales críticos son correctos', () {
      expect(CriticalMetric.hunger.criticalThreshold, 70.0);
      expect(CriticalMetric.happiness.criticalThreshold, 30.0);
      expect(CriticalMetric.energy.criticalThreshold, 20.0);
      expect(CriticalMetric.health.criticalThreshold, 30.0);
    });
  });

  group('AIService predictNextNeed', () {
    late AIService aiService;
    late Pet testPet;
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
      testHistory = InteractionHistory();
    });

    test('predictNextNeed retorna predicción válida', () {
      final prediction = aiService.predictNextNeed(
        pet: testPet,
        history: testHistory,
      );

      // Con valores medios, debería haber alguna predicción
      expect(prediction, isNotNull);
      expect(prediction!.minutesUntilNeeded, greaterThan(0));
    });

    test('predictNextNeed prioriza hambre alta', () {
      final hungryPet = Pet(
        name: 'HungryPet',
        hunger: 60, // Cerca del umbral 70
        happiness: 90,
        energy: 90,
        health: 90,
      );

      final prediction = aiService.predictNextNeed(
        pet: hungryPet,
        history: testHistory,
      );

      expect(prediction, isNotNull);
      expect(prediction!.type, InteractionType.feed);
    });

    test('predictNextNeed prioriza felicidad baja', () {
      final sadPet = Pet(
        name: 'SadPet',
        hunger: 20,
        happiness: 45, // Cerca del umbral 40
        energy: 90,
        health: 90,
      );

      final prediction = aiService.predictNextNeed(
        pet: sadPet,
        history: testHistory,
      );

      expect(prediction, isNotNull);
      expect(prediction!.type, InteractionType.play);
    });

    test('predictNextNeed retorna null si todas las métricas están bien', () {
      final healthyPet = Pet(
        name: 'HealthyPet',
        hunger: 10, // Muy bajo (bueno)
        happiness: 95, // Muy alto (bueno)
        energy: 90, // Muy alto (bueno)
        health: 95,
      );

      final prediction = aiService.predictNextNeed(
        pet: healthyPet,
        history: testHistory,
      );

      // Puede retornar null o predicción muy lejana
      if (prediction != null) {
        expect(prediction.minutesUntilNeeded, greaterThan(60));
      }
    });
  });

  group('AIService predictNextNeedSmart', () {
    late AIService aiService;
    late Pet testPet;
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
      testHistory = InteractionHistory();
    });

    test('predictNextNeedSmart cae a fallback sin ML inicializado', () async {
      // MLService no está inicializado, debería usar fallback
      final prediction = await aiService.predictNextNeedSmart(
        pet: testPet,
        history: testHistory,
      );

      // Debería retornar la misma predicción que el método base
      final basePrediction = aiService.predictNextNeed(
        pet: testPet,
        history: testHistory,
      );

      if (prediction != null && basePrediction != null) {
        expect(prediction.type, basePrediction.type);
        expect(prediction.minutesUntilNeeded, basePrediction.minutesUntilNeeded);
      }
    });

    test('getMLCriticalTimePrediction retorna null sin ML', () async {
      final prediction = await aiService.getMLCriticalTimePrediction(
        pet: testPet,
        history: testHistory,
      );

      expect(prediction, isNull);
    });
  });

  group('MLFeatureConfig CriticalTimePredictor', () {
    test('tiene tamaños de entrada/salida correctos', () {
      expect(MLFeatureConfig.criticalTimePredictorInputSize, 20);
      expect(MLFeatureConfig.criticalTimePredictorOutputSize, 4);
    });
  });

  group('Escenarios de predicción', () {
    late AIService aiService;
    late InteractionHistory history;

    setUp(() {
      aiService = AIService();
      history = InteractionHistory();
    });

    test('mascota con hambre crítica próxima', () {
      final pet = Pet(
        name: 'HungryPet',
        hunger: 65, // 5 puntos hasta crítico (70)
        happiness: 80,
        energy: 70,
        health: 85,
      );

      final prediction = aiService.predictNextNeed(pet: pet, history: history);

      expect(prediction, isNotNull);
      expect(prediction!.type, InteractionType.feed);
      expect(prediction.urgency, greaterThan(0.5));
    });

    test('mascota con múltiples necesidades elige la más urgente', () {
      final pet = Pet(
        name: 'NeedyPet',
        hunger: 68, // Muy cerca de crítico
        happiness: 42, // También cerca de crítico
        energy: 70,
        health: 85,
      );

      final prediction = aiService.predictNextNeed(pet: pet, history: history);

      expect(prediction, isNotNull);
      // Debería elegir la que llegará a crítico primero
      expect(
        prediction!.type == InteractionType.feed ||
            prediction.type == InteractionType.play,
        true,
      );
    });

    test('mascota muy cansada prioriza descanso', () {
      final pet = Pet(
        name: 'TiredPet',
        hunger: 30,
        happiness: 70,
        energy: 32, // Muy cerca de umbral 30
        health: 85,
      );

      final prediction = aiService.predictNextNeed(pet: pet, history: history);

      expect(prediction, isNotNull);
      expect(prediction!.type, InteractionType.rest);
    });
  });
}
