import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';
import '../utils/constants.dart';

/// Servicio para manejar la persistencia del estado de la mascota
class StorageService {
  static const String _petStateKey = AppConstants.petStateKey;

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
}
