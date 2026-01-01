/// Servicio para manejar la persistencia de preferencias de personalización
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_preferences.dart';
import '../utils/logger.dart';

class PreferencesService {
  static const String _preferencesKey = 'pet_preferences';

  /// Guarda las preferencias
  static Future<void> savePreferences(PetPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, preferencesJson);
    appLogger.i('Preferencias guardadas: $preferencesJson');
  }

  /// Carga las preferencias guardadas
  static Future<PetPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);

    if (preferencesJson == null) {
      appLogger.d('No hay preferencias guardadas, usando valores por defecto');
      return const PetPreferences();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(preferencesJson);
      final preferences = PetPreferences.fromJson(json);
      appLogger.i('Preferencias cargadas: $preferencesJson');
      return preferences;
    } catch (e) {
      appLogger.e('Error al cargar preferencias', error: e);
      return const PetPreferences();
    }
  }

  /// Actualiza una preferencia específica
  static Future<void> updatePetColor(int colorValue) async {
    final preferences = await loadPreferences();
    final updatedPreferences = preferences.copyWith(
      petColor: Color(colorValue),
    );
    await savePreferences(updatedPreferences);
  }

  /// Actualiza el accesorio
  static Future<void> updateAccessory(String accessory) async {
    final preferences = await loadPreferences();
    final updatedPreferences = preferences.copyWith(accessory: accessory);
    await savePreferences(updatedPreferences);
  }

  /// Actualiza estado de sonido
  static Future<void> updateSoundEnabled(bool enabled) async {
    final preferences = await loadPreferences();
    final updatedPreferences = preferences.copyWith(soundEnabled: enabled);
    await savePreferences(updatedPreferences);
  }

  /// Actualiza estado de notificaciones
  static Future<void> updateNotificationsEnabled(bool enabled) async {
    final preferences = await loadPreferences();
    final updatedPreferences =
        preferences.copyWith(notificationsEnabled: enabled);
    await savePreferences(updatedPreferences);
  }

  /// Elimina todas las preferencias guardadas
  static Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferencesKey);
      appLogger.i('Preferencias eliminadas');
    } catch (e) {
      appLogger.e('Error al eliminar preferencias', error: e);
    }
  }
}
