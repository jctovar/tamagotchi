import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../models/minigame_stats.dart';
import '../utils/constants.dart';

/// Servicio para manejar la persistencia del estado de la mascota
class StorageService {
  static const String _petStateKey = AppConstants.petStateKey;
  static const String _miniGameStatsKey = 'minigame_stats';

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
}
