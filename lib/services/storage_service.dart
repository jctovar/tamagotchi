import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/minigame_stats.dart';
import '../models/interaction_history.dart';
import '../models/pet_personality.dart';
import '../utils/constants.dart';

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
      debugPrint('✅ Estado guardado: ${petJson.substring(0, 100)}...');
    } catch (e) {
      debugPrint('❌ Error guardando estado: $e');
    }
  }

  /// Carga el estado de la mascota del almacenamiento local
  Future<Pet?> loadPetState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petJson = prefs.getString(_petStateKey);

      if (petJson == null) {
        debugPrint('ℹ️ No hay estado guardado previo');
        return null; // No hay estado guardado
      }

      debugPrint('✅ Estado cargado: ${petJson.substring(0, 100)}...');
      final petMap = jsonDecode(petJson) as Map<String, dynamic>;
      return Pet.fromJson(petMap);
    } catch (e) {
      debugPrint('❌ Error cargando estado: $e');
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
      debugPrint('✅ Estadísticas de mini-juegos guardadas');
    } catch (e) {
      debugPrint('❌ Error guardando estadísticas de mini-juegos: $e');
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
        debugPrint('ℹ️ No hay estadísticas de mini-juegos guardadas');
        return MiniGameStats(); // Retorna estadísticas vacías
      }

      debugPrint('✅ Estadísticas de mini-juegos cargadas');
      final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
      return MiniGameStats.fromJson(statsMap);
    } catch (e) {
      debugPrint('❌ Error cargando estadísticas de mini-juegos: $e');
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
      debugPrint('✅ Historial de interacciones guardado (${history.totalInteractions} interacciones)');
    } catch (e) {
      debugPrint('❌ Error guardando historial de interacciones: $e');
    }
  }

  /// Carga el historial de interacciones
  Future<InteractionHistory> loadInteractionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_interactionHistoryKey);

      if (historyJson == null) {
        debugPrint('ℹ️ No hay historial de interacciones guardado');
        return InteractionHistory();
      }

      debugPrint('✅ Historial de interacciones cargado');
      final historyMap = jsonDecode(historyJson) as Map<String, dynamic>;
      return InteractionHistory.fromJson(historyMap);
    } catch (e) {
      debugPrint('❌ Error cargando historial de interacciones: $e');
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
      debugPrint('✅ Personalidad guardada (Vínculo: ${personality.bondLevel.displayName})');
    } catch (e) {
      debugPrint('❌ Error guardando personalidad: $e');
    }
  }

  /// Carga la personalidad de la mascota
  Future<PetPersonality> loadPetPersonality() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personalityJson = prefs.getString(_petPersonalityKey);

      if (personalityJson == null) {
        debugPrint('ℹ️ No hay personalidad guardada');
        return PetPersonality();
      }

      debugPrint('✅ Personalidad cargada');
      final personalityMap = jsonDecode(personalityJson) as Map<String, dynamic>;
      return PetPersonality.fromJson(personalityMap);
    } catch (e) {
      debugPrint('❌ Error cargando personalidad: $e');
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
      debugPrint('✅ Datos de IA eliminados');
    } catch (e) {
      debugPrint('❌ Error eliminando datos de IA: $e');
    }
  }
}
