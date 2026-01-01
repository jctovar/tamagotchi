import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/minigame_stats.dart';
import '../models/interaction_history.dart';
import '../models/pet_personality.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// Servicio para manejar la persistencia del estado de la mascota
class StorageService {
  static const String _petStateKey = AppConstants.petStateKey;
  static const String _miniGameStatsKey = 'minigame_stats';
  static const String _interactionHistoryKey = 'interaction_history';
  static const String _petPersonalityKey = 'pet_personality';

  /// Guarda el estado de la mascota en el almacenamiento local
  Future<void> saveState(Pet pet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petJson = jsonEncode(pet.toJson());
      await prefs.setString(_petStateKey, petJson);
      appLogger.d('Estado guardado - Nombre: ${pet.name}, Salud: ${pet.health.toStringAsFixed(1)}');
    } catch (e, stackTrace) {
      appLogger.e('Error guardando estado', error: e, stackTrace: stackTrace);
    }
  }

  /// Carga el estado de la mascota del almacenamiento local
  Future<Pet?> loadPetState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petJson = prefs.getString(_petStateKey);

      if (petJson == null) {
        appLogger.d('No hay estado guardado previo');
        return null; // No hay estado guardado
      }

      final petMap = jsonDecode(petJson) as Map<String, dynamic>;
      final pet = Pet.fromJson(petMap);
      appLogger.d('Estado cargado - Nombre: ${pet.name}, Salud: ${pet.health.toStringAsFixed(1)}');
      return pet;
    } catch (e, stackTrace) {
      appLogger.e('Error cargando estado', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Actualiza las métricas de la mascota basándose en el tiempo transcurrido
  Pet updatePetMetrics(Pet pet) {
    final now = DateTime.now();

    // Calcular tiempo transcurrido desde la última actualización
    final secondsSinceLastFed = now.difference(pet.lastFed).inSeconds;
    final secondsSinceLastPlayed = now.difference(pet.lastPlayed).inSeconds;
    final secondsSinceLastRested = now.difference(pet.lastRested).inSeconds;

    // Actualizar métricas con decaimiento
    double newHunger = pet.hunger +
        (secondsSinceLastFed * AppConstants.hungerDecayRate);

    double newHappiness = pet.happiness -
        (secondsSinceLastPlayed * AppConstants.happinessDecayRate);

    double newEnergy = pet.energy -
        (secondsSinceLastRested * AppConstants.energyDecayRate);

    // Calcular salud basada en el estado general
    double newHealth = pet.health;

    // Si el hambre es muy alta, la salud se reduce
    if (newHunger > 80) {
      newHealth -= (secondsSinceLastFed * 0.01);
    }

    // Si la felicidad es muy baja, la salud se reduce
    if (newHappiness < 20) {
      newHealth -= (secondsSinceLastPlayed * 0.01);
    }

    // Si la energía es muy baja, la salud se reduce
    if (newEnergy < 20) {
      newHealth -= (secondsSinceLastRested * 0.01);
    }

    // Limitar valores entre 0 y 100
    newHunger = newHunger.clamp(0, 100);
    newHappiness = newHappiness.clamp(0, 100);
    newEnergy = newEnergy.clamp(0, 100);
    newHealth = newHealth.clamp(0, 100);

    return pet.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      energy: newEnergy,
      health: newHealth,
    );
  }

  /// Borra el estado guardado (útil para resetear)
  Future<void> clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_petStateKey);
    } catch (e) {
      // Silent fail
    }
  }

  /// Guarda las estadísticas de mini-juegos en el almacenamiento local
  ///
  /// [stats] Estadísticas completas de todos los mini-juegos a guardar
  Future<void> saveMiniGameStats(MiniGameStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats.toJson());
      await prefs.setString(_miniGameStatsKey, statsJson);
      appLogger.d('Estadísticas de mini-juegos guardadas');
    } catch (e, stackTrace) {
      appLogger.e('Error guardando estadísticas de mini-juegos', error: e, stackTrace: stackTrace);
    }
  }

  /// Carga las estadísticas de mini-juegos del almacenamiento local
  ///
  /// Retorna las estadísticas guardadas o un objeto nuevo con estadísticas
  /// vacías si no hay datos previos o hay un error.
  Future<MiniGameStats> loadMiniGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_miniGameStatsKey);

      if (statsJson == null) {
        appLogger.d('No hay estadísticas de mini-juegos guardadas');
        return MiniGameStats(); // Retorna estadísticas vacías
      }

      appLogger.d('Estadísticas de mini-juegos cargadas');
      final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
      return MiniGameStats.fromJson(statsMap);
    } catch (e, stackTrace) {
      appLogger.e('Error cargando estadísticas de mini-juegos', error: e, stackTrace: stackTrace);
      return MiniGameStats(); // Retorna estadísticas vacías en caso de error
    }
  }

  /// Actualiza estadísticas después de completar un mini-juego
  ///
  /// [result] Resultado del juego completado con puntuación y recompensas
  /// Incrementa contadores, actualiza récords y acumula recompensas totales.
  Future<void> updateGameStats(GameResult result) async {
    final stats = await loadMiniGameStats();
    final gameStats = stats.getStats(result.gameType);

    // Actualizar estadísticas incrementando contadores y actualizando récord
    final updatedGameStats = gameStats.copyWith(
      timesPlayed: gameStats.timesPlayed + 1,
      timesWon: result.won ? gameStats.timesWon + 1 : gameStats.timesWon,
      bestScore: result.score > gameStats.bestScore
          ? result.score
          : gameStats.bestScore,
      totalXpEarned: gameStats.totalXpEarned + result.xpEarned,
      totalCoinsEarned: gameStats.totalCoinsEarned + result.coinsEarned,
    );

    final updatedStats = stats.updateGameStats(result.gameType, updatedGameStats);
    await saveMiniGameStats(updatedStats);
  }

  // ==================== SISTEMA DE IA ====================

  /// Guarda el historial de interacciones
  Future<void> saveInteractionHistory(InteractionHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(history.toJson());
      await prefs.setString(_interactionHistoryKey, historyJson);
      appLogger.d('Historial de interacciones guardado (${history.totalInteractions} interacciones)');
    } catch (e, stackTrace) {
      appLogger.e('Error guardando historial de interacciones', error: e, stackTrace: stackTrace);
    }
  }

  /// Carga el historial de interacciones
  Future<InteractionHistory> loadInteractionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_interactionHistoryKey);

      if (historyJson == null) {
        appLogger.d('No hay historial de interacciones guardado');
        return InteractionHistory();
      }

      appLogger.d('Historial de interacciones cargado');
      final historyMap = jsonDecode(historyJson) as Map<String, dynamic>;
      return InteractionHistory.fromJson(historyMap);
    } catch (e, stackTrace) {
      appLogger.e('Error cargando historial de interacciones', error: e, stackTrace: stackTrace);
      return InteractionHistory();
    }
  }

  /// Agrega una nueva interacción al historial
  Future<InteractionHistory> addInteraction(Interaction interaction) async {
    final history = await loadInteractionHistory();
    final updatedHistory = history.addInteraction(interaction);
    await saveInteractionHistory(updatedHistory);
    return updatedHistory;
  }

  /// Guarda la personalidad de la mascota
  Future<void> savePetPersonality(PetPersonality personality) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personalityJson = jsonEncode(personality.toJson());
      await prefs.setString(_petPersonalityKey, personalityJson);
      appLogger.d('Personalidad guardada (Vínculo: ${personality.bondLevel.displayName})');
    } catch (e, stackTrace) {
      appLogger.e('Error guardando personalidad', error: e, stackTrace: stackTrace);
    }
  }

  /// Carga la personalidad de la mascota
  Future<PetPersonality> loadPetPersonality() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personalityJson = prefs.getString(_petPersonalityKey);

      if (personalityJson == null) {
        appLogger.d('No hay personalidad guardada');
        return PetPersonality();
      }

      appLogger.d('Personalidad cargada');
      final personalityMap = jsonDecode(personalityJson) as Map<String, dynamic>;
      return PetPersonality.fromJson(personalityMap);
    } catch (e, stackTrace) {
      appLogger.e('Error cargando personalidad', error: e, stackTrace: stackTrace);
      return PetPersonality();
    }
  }

  /// Registra una interacción y actualiza la personalidad
  ///
  /// Método conveniente que combina el guardado de interacción
  /// con la actualización de personalidad en una sola llamada.
  Future<({InteractionHistory history, PetPersonality personality})> recordInteraction({
    required InteractionType type,
    required double hungerBefore,
    required double happinessBefore,
    required double energyBefore,
    required double healthBefore,
    Map<String, dynamic>? metadata,
  }) async {
    // Crear interacción
    final interaction = Interaction.now(
      type: type,
      hungerBefore: hungerBefore,
      happinessBefore: happinessBefore,
      energyBefore: energyBefore,
      healthBefore: healthBefore,
      metadata: metadata,
    );

    // Cargar y actualizar historial
    final history = await loadInteractionHistory();
    final updatedHistory = history.addInteraction(interaction);
    await saveInteractionHistory(updatedHistory);

    // Cargar y actualizar personalidad
    final personality = await loadPetPersonality();
    final updatedPersonality = personality.updateFromInteraction(interaction);
    await savePetPersonality(updatedPersonality);

    return (history: updatedHistory, personality: updatedPersonality);
  }

  /// Limpia todos los datos de IA
  Future<void> clearAIData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_interactionHistoryKey);
      await prefs.remove(_petPersonalityKey);
      appLogger.i('Datos de IA eliminados');
    } catch (e, stackTrace) {
      appLogger.e('Error eliminando datos de IA', error: e, stackTrace: stackTrace);
    }
  }

  /// Limpia las estadísticas de mini-juegos
  Future<void> clearMiniGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_miniGameStatsKey);
      appLogger.i('Estadísticas de mini-juegos eliminadas');
    } catch (e, stackTrace) {
      appLogger.e('Error eliminando estadísticas de mini-juegos', error: e, stackTrace: stackTrace);
    }
  }

  /// Limpia TODOS los datos del juego (reset completo)
  ///
  /// Elimina: estado de mascota, estadísticas de minijuegos,
  /// historial de interacciones y personalidad.
  Future<void> clearAllData() async {
    await clearState();
    await clearMiniGameStats();
    await clearAIData();
    appLogger.i('Todos los datos del juego han sido eliminados');
  }
}
