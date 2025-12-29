/// Servicio para manejar la persistencia de preferencias de personalización
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_preferences.dart';

class PreferencesService {
  static const String _preferencesKey = 'pet_preferences';

  /// Guarda las preferencias
  static Future<void> savePreferences(PetPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, preferencesJson);
    print('✅ Preferencias guardadas: $preferencesJson');
  }

  /// Carga las preferencias guardadas
  static Future<PetPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);

    if (preferencesJson == null) {
      print('📋 No hay preferencias guardadas, usando valores por defecto');
      return const PetPreferences();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(preferencesJson);
      final preferences = PetPreferences.fromJson(json);
      print('✅ Preferencias cargadas: $preferencesJson');
      return preferences;
    } catch (e) {
      print('⚠️ Error al cargar preferencias: $e');
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
}
