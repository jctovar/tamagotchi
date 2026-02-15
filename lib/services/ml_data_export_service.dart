import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../models/pet_personality.dart';
import '../models/interaction_history.dart';
import '../utils/logger.dart';

/// Resultado de una operación de exportación de datos ML
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

  @override
  String toString() {
    if (success) {
      return 'ExportResult: success=true, recordCount=$recordCount, filePath=$filePath';
    }
    return 'ExportResult: success=false, error=$error';
  }
}

/// Servicio para exportar datos de entrenamiento de Machine Learning
///
/// Este servicio permite exportar los datos reales de la mascota
/// (historial de interacciones, personalidad, métricas) para entrenar
/// modelos ML, así como generar datos sintéticos para pruebas.
class MLDataExportService {
  static MLDataExportService? _instance;

  factory MLDataExportService() {
    _instance ??= MLDataExportService._internal();
    return _instance!;
  }

  MLDataExportService._internal();

  /// Exporta los datos reales de entrenamiento de la mascota
  ///
  /// Exporta información estructurada incluyendo:
  /// - Datos demográficos de la mascota
  /// - Métricas de personalidad
  /// - Historial completo de interacciones con features
  ///
  /// Retorna un [ExportResult] con la ruta del archivo exportado
  Future<ExportResult> exportTrainingData({
    required Pet pet,
    required PetPersonality personality,
    required InteractionHistory history,
  }) async {
    try {
      appLogger.i('Iniciando exportación de datos ML');

      final trainingData = <String, dynamic>{
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'format': 'training_data',
        },
        'pet': {
          'name': pet.name,
          'lifeStage': pet.lifeStage.name,
          'variant': pet.variant.name,
          'level': pet.level,
          'experience': pet.experience,
          'birthDate': pet.birthDate.toIso8601String(),
          'currentMetrics': {
            'hunger': pet.hunger,
            'happiness': pet.happiness,
            'energy': pet.energy,
            'health': pet.health,
          },
        },
        'personality': {
          'bondPoints': personality.bondPoints,
          'bondLevel': personality.bondLevel.name,
          'emotionalState': personality.emotionalState.name,
          'traits': {
            for (var trait in PersonalityTrait.values)
              trait.name: personality.getTraitIntensity(trait),
          },
          'dominantTraits': personality.dominantTraits
              .map((t) => t.name)
              .toList(),
        },
        'interactions': history.interactions.asMap().entries.map((entry) {
          final interaction = entry.value;
          return {
            'index': entry.key,
            'type': interaction.type.id,
            'timestamp': interaction.timestamp.toIso8601String(),
            'timeOfDay': interaction.timeOfDay.name,
            'dayOfWeek': interaction.dayOfWeek,
            'metricsBefore': {
              'hunger': interaction.hungerBefore,
              'happiness': interaction.happinessBefore,
              'energy': interaction.energyBefore,
              'health': interaction.healthBefore,
            },
            'metadata': interaction.metadata,
          };
        }).toList(),
        'statistics': {
          'totalInteractions': history.totalInteractions,
          'interactionCounts': {
            for (var entry in history.interactionCounts.entries)
              entry.key.id: entry.value,
          },
          'timeOfDayDistribution': {
            for (var entry in history.timeOfDayDistribution.entries)
              entry.key.name: entry.value,
          },
          'dayOfWeekDistribution': {
            for (var entry in history.dayOfWeekDistribution.entries)
              _getDayName(entry.key): entry.value,
          },
          'averageInteractionsPerDay': history.averageInteractionsPerDay
              .toStringAsFixed(2),
          'mostActiveTimeOfDay': history.mostActiveTimeOfDay?.name,
        },
      };

      final fileName = 'tamagotchi_ml_data_${_getTimestamp()}.json';
      final filePath = await _saveJsonFile(fileName, trainingData);

      appLogger.i(
        'Datos exportados exitosamente: ${history.interactions.length} registros',
      );

      return ExportResult(
        success: true,
        recordCount: history.interactions.length,
        filePath: filePath,
      );
    } catch (e, stackTrace) {
      appLogger.e(
        'Error exportando datos ML',
        error: e,
        stackTrace: stackTrace,
      );
      return ExportResult(
        success: false,
        recordCount: 0,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Genera datos sintéticos para entrenamiento de modelos ML
  ///
  /// Crea un conjunto de datos sintéticos realistas que simulan
  /// interacciones con mascotas virtuales. Útil para:
  /// - Entrenar modelos iniciales
  /// - Aumentar el dataset de entrenamiento
  /// - Probar pipelines de ML
  ///
  /// [recordCount] Cantidad de registros sintéticos a generar (default: 500)
  ///
  /// Retorna un [ExportResult] con la ruta del archivo generado
  Future<ExportResult> generateSyntheticData({int recordCount = 500}) async {
    try {
      appLogger.i('Generando $recordCount registros sintéticos');

      final syntheticData = <String, dynamic>{
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'format': 'synthetic_training_data',
          'recordCount': recordCount,
        },
        'synthetic_interactions': List.generate(recordCount, (index) {
          final randomDayOffset = (index * 3) % 30;
          final timestamp = DateTime.now().subtract(
            Duration(days: randomDayOffset, hours: (index % 24)),
          );

          final type = _getRandomInteractionType(index);
          final timeOfDay = TimeOfDay.fromHour(timestamp.hour);
          final dayOfWeek = timestamp.weekday;

          final hunger = _generateRandomMetric(10, 90, index);
          final happiness = _generateRandomMetric(10, 90, index + 1);
          final energy = _generateRandomMetric(10, 90, index + 2);
          final health = _generateRandomMetric(50, 100, index + 3);

          return {
            'id': 'synthetic_${index.toString().padLeft(5, '0')}',
            'type': type.id,
            'timestamp': timestamp.toIso8601String(),
            'timeOfDay': timeOfDay.name,
            'dayOfWeek': dayOfWeek,
            'metricsBefore': {
              'hunger': hunger,
              'happiness': happiness,
              'energy': energy,
              'health': health,
            },
            'synthetic': true,
            'metadata': {
              'petLifeStage': _getRandomLifeStage(index),
              'petLevel': _generateRandomInt(1, 20, index),
              'bondLevel': _getRandomBondLevel(index).name,
            },
          };
        }),
        'statistics': {
          'totalRecords': recordCount,
          'types': InteractionType.values.map((t) => t.id).toList(),
          'timePeriods': TimeOfDay.values.map((t) => t.name).toList(),
          'generatedBy': 'MLDataExportService',
          'purpose': 'training_augmentation',
        },
      };

      final fileName = 'tamagotchi_synthetic_data_${_getTimestamp()}.json';
      final filePath = await _saveJsonFile(fileName, syntheticData);

      appLogger.i(
        'Datos sintéticos generados exitosamente: $recordCount registros',
      );

      return ExportResult(
        success: true,
        recordCount: recordCount,
        filePath: filePath,
      );
    } catch (e, stackTrace) {
      appLogger.e(
        'Error generando datos sintéticos',
        error: e,
        stackTrace: stackTrace,
      );
      return ExportResult(
        success: false,
        recordCount: 0,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Comparte un archivo exportado mediante el sistema nativo
  ///
  /// Abre la hoja de compartir del sistema para enviar el archivo
  /// a través de diferentes medios (email, drive, mensajes, etc.)
  ///
  /// [filePath] Ruta del archivo a compartir
  Future<void> shareExportedData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $filePath');
      }

      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: 'Datos de entrenamiento Tamagotchi',
        text: 'Archivo exportado desde Iztatamagotchi',
      );

      appLogger.i('Archivo compartido exitosamente: $filePath');
    } catch (e, stackTrace) {
      appLogger.e(
        'Error compartiendo archivo',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<String> _saveJsonFile(
    String fileName,
    Map<String, dynamic> data,
  ) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonEncode(data));
    return file.path;
  }

  String _getTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    return formatter.format(now);
  }

  InteractionType _getRandomInteractionType(int seed) {
    final types = InteractionType.values;
    return types[seed % types.length];
  }

  double _generateRandomMetric(double min, double max, int seed) {
    final value = ((min + (max - min) * (seed % 100) / 100) * 10).round() / 10;
    return value.clamp(min, max);
  }

  int _generateRandomInt(int min, int max, int seed) {
    return min + (seed % (max - min + 1));
  }

  String _getRandomLifeStage(int seed) {
    final stages = ['egg', 'baby', 'child', 'teen', 'adult'];
    return stages[seed % stages.length];
  }

  BondLevel _getRandomBondLevel(int seed) {
    final levels = BondLevel.values;
    return levels[seed % levels.length];
  }

  String _getDayName(int dayOfWeek) {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return days[dayOfWeek] ?? 'Unknown';
  }
}
