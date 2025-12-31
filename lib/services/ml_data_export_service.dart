import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/pet.dart';
import '../models/pet_personality.dart';
import '../models/interaction_history.dart';
import '../utils/ml_feature_extractor.dart';

/// Servicio para exportar datos de entrenamiento ML
///
/// Permite exportar historial de interacciones en formato JSON
/// para entrenar modelos TensorFlow Lite externamente.
class MLDataExportService {
  static final MLDataExportService _instance = MLDataExportService._internal();
  factory MLDataExportService() => _instance;
  MLDataExportService._internal();

  static const String _exportVersion = '1.0';

  /// Exporta datos reales del historial de interacciones
  Future<ExportResult> exportTrainingData({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    if (history.interactions.isEmpty) {
      return ExportResult(
        success: false,
        recordCount: 0,
        error: 'No hay interacciones para exportar',
      );
    }

    try {
      final records = <Map<String, dynamic>>[];

      // Procesar cada interacción para generar registros de entrenamiento
      for (int i = 0; i < history.interactions.length; i++) {
        final interaction = history.interactions[i];

        // Saltar interacciones de apertura/cierre de app
        if (interaction.type == InteractionType.appOpen ||
            interaction.type == InteractionType.appClose) {
          continue;
        }

        // Crear un Pet simulado con las métricas antes de la interacción
        final petSnapshot = Pet(
          name: pet.name,
          hunger: interaction.hungerBefore,
          happiness: interaction.happinessBefore,
          energy: interaction.energyBefore,
          health: interaction.healthBefore,
        );

        // Crear historial hasta este punto
        final historySnapshot = InteractionHistory(
          interactions: history.interactions.sublist(0, i),
        );

        // Extraer features
        final features = MLFeatureExtractor.extractActionPredictorFeatures(
          pet: petSnapshot,
          personality: personality,
          history: historySnapshot,
        );

        // Calcular tiempo hasta estado crítico (aproximado)
        final timeToCritical = _estimateTimeToCritical(petSnapshot);

        records.add(MLTrainingRecord(
          features: features,
          actionTaken: interaction.type,
          timeToCritical: timeToCritical,
          resultingEmotion: personality.emotionalState,
          timestamp: interaction.timestamp,
          metricsBefore: {
            'hunger': interaction.hungerBefore,
            'happiness': interaction.happinessBefore,
            'energy': interaction.energyBefore,
            'health': interaction.healthBefore,
          },
        ).toJson());
      }

      if (records.isEmpty) {
        return ExportResult(
          success: false,
          recordCount: 0,
          error: 'No se pudieron generar registros de entrenamiento',
        );
      }

      // Crear JSON de exportación
      final exportData = {
        'version': _exportVersion,
        'export_date': DateTime.now().toIso8601String(),
        'pet_name': pet.name,
        'total_interactions': history.totalInteractions,
        'days_active': history.daysActive,
        'record_count': records.length,
        'records': records,
      };

      // Guardar archivo
      final filePath = await _saveToFile(exportData);

      return ExportResult(
        success: true,
        recordCount: records.length,
        filePath: filePath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        recordCount: 0,
        error: 'Error al exportar: $e',
      );
    }
  }

  /// Genera datos sintéticos para entrenamiento inicial
  Future<ExportResult> generateSyntheticData({
    int recordCount = 500,
  }) async {
    try {
      final random = Random();
      final records = <Map<String, dynamic>>[];

      for (int i = 0; i < recordCount; i++) {
        // Generar métricas aleatorias
        final hunger = random.nextDouble() * 100;
        final happiness = random.nextDouble() * 100;
        final energy = random.nextDouble() * 100;
        final health = random.nextDouble() * 100;

        // Determinar acción "correcta" basada en reglas heurísticas
        final action = _determineOptimalAction(
          hunger: hunger,
          happiness: happiness,
          energy: energy,
          health: health,
        );

        // Generar features
        final features = _generateSyntheticFeatures(
          hunger: hunger,
          happiness: happiness,
          energy: energy,
          health: health,
          random: random,
        );

        // Calcular tiempo hasta estado crítico
        final timeToCritical = [
          (70 - hunger) / 0.12, // ~8.3 minutos por punto
          (happiness - 30) / 0.06, // ~16.6 minutos por punto
          (energy - 20) / 0.06, // ~16.6 minutos por punto
          (health - 30) / 0.04, // ~25 minutos por punto
        ].map((t) => t.clamp(0.0, 180.0)).toList();

        records.add({
          'features': features,
          'action_taken': action.id,
          'time_to_critical': timeToCritical,
          'resulting_emotion': random.nextInt(8),
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: random.nextInt(10000)))
              .toIso8601String(),
          'metrics_before': {
            'hunger': hunger,
            'happiness': happiness,
            'energy': energy,
            'health': health,
          },
          'is_synthetic': true,
        });
      }

      // Crear JSON de exportación
      final exportData = {
        'version': _exportVersion,
        'export_date': DateTime.now().toIso8601String(),
        'data_type': 'synthetic',
        'record_count': records.length,
        'records': records,
      };

      // Guardar archivo
      final filePath = await _saveToFile(
        exportData,
        filename: 'ml_synthetic_data',
      );

      return ExportResult(
        success: true,
        recordCount: records.length,
        filePath: filePath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        recordCount: 0,
        error: 'Error al generar datos sintéticos: $e',
      );
    }
  }

  /// Comparte el archivo de datos exportados
  Future<void> shareExportedData(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: 'Datos de entrenamiento ML - Tamagotchi',
      text: 'Datos exportados para entrenamiento de modelos ML',
    );
  }

  /// Guarda datos en archivo JSON
  Future<String> _saveToFile(
    Map<String, dynamic> data, {
    String filename = 'ml_training_data',
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/${filename}_$timestamp.json');

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Estima tiempo hasta estado crítico basado en métricas actuales
  List<double> _estimateTimeToCritical(Pet pet) {
    // Tasas de decaimiento aproximadas (por minuto)
    const hungerRate = 0.12; // Hambre aumenta
    const happinessRate = 0.06; // Felicidad disminuye
    const energyRate = 0.06; // Energía disminuye
    const healthRate = 0.04; // Salud disminuye (más lento)

    return [
      ((70 - pet.hunger) / hungerRate).clamp(0.0, 180.0),
      ((pet.happiness - 30) / happinessRate).clamp(0.0, 180.0),
      ((pet.energy - 20) / energyRate).clamp(0.0, 180.0),
      ((pet.health - 30) / healthRate).clamp(0.0, 180.0),
    ];
  }

  /// Determina la acción óptima basada en métricas
  InteractionType _determineOptimalAction({
    required double hunger,
    required double happiness,
    required double energy,
    required double health,
  }) {
    // Priorizar por urgencia
    if (hunger > 70) return InteractionType.feed;
    if (health < 40) return InteractionType.clean;
    if (happiness < 40) return InteractionType.play;
    if (energy < 30) return InteractionType.rest;

    // Si todo está bien, elegir basado en qué está más bajo
    final metrics = {
      InteractionType.feed: 100 - hunger, // Invertir para que menor = más urgente
      InteractionType.play: happiness,
      InteractionType.rest: energy,
      InteractionType.clean: health,
    };

    return metrics.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// Genera features sintéticos
  List<double> _generateSyntheticFeatures({
    required double hunger,
    required double happiness,
    required double energy,
    required double health,
    required Random random,
  }) {
    return [
      hunger / 100,
      happiness / 100,
      energy / 100,
      health / 100,
      random.nextDouble(), // emotional_state
      random.nextDouble(), // bond_level
      random.nextDouble(), // proactive_ratio
      random.nextDouble(), // time_of_day
      random.nextDouble(), // day_of_week
      random.nextDouble(), // minutes_since_last
      random.nextDouble() > 0.8 ? 1.0 : 0.0, // last_action_feed
      random.nextDouble() > 0.8 ? 1.0 : 0.0, // last_action_play
      random.nextDouble() > 0.8 ? 1.0 : 0.0, // last_action_clean
      random.nextDouble() > 0.8 ? 1.0 : 0.0, // last_action_rest
      random.nextDouble() > 0.8 ? 1.0 : 0.0, // last_action_minigame
    ];
  }
}

/// Resultado de una exportación de datos
class ExportResult {
  final bool success;
  final int recordCount;
  final String? filePath;
  final String? error;

  ExportResult({
    required this.success,
    required this.recordCount,
    this.filePath,
    this.error,
  });
}
