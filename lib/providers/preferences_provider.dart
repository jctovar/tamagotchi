import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/pet_preferences.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';

part 'preferences_provider.g.dart';

/// Provider para el estado de preferencias de personalización
///
/// Gestiona las preferencias del usuario:
/// - Color de la mascota
/// - Accesorio equipado
/// - Sonidos habilitados/deshabilitados
/// - Notificaciones habilitadas/deshabilitadas
@riverpod
class PreferencesState extends _$PreferencesState {
  @override
  Future<PetPreferences> build() async {
    return await PreferencesService.loadPreferences();
  }

  /// Actualiza el color de la mascota
  Future<void> updatePetColor(Color color) async {
    await PreferencesService.updatePetColor(color.value);

    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(petColor: color));

    // Analytics
    await AnalyticsService.logPetColorChanged(
      newColor: color.toString(),
      coinsSpent: 0, // El cambio de color es gratuito
    );
  }

  /// Actualiza el accesorio equipado
  Future<void> updateAccessory(String accessory) async {
    final current = state.value;
    if (current == null) return;

    final oldAccessory = current.accessory;

    await PreferencesService.updateAccessory(accessory);

    state = AsyncValue.data(current.copyWith(accessory: accessory));

    // Analytics
    await AnalyticsService.logAccessoryChanged(
      oldAccessory: oldAccessory.isEmpty ? null : oldAccessory,
      newAccessory: accessory.isEmpty ? null : accessory,
    );
  }

  /// Actualiza si los sonidos están habilitados
  Future<void> updateSoundEnabled(bool enabled) async {
    await PreferencesService.updateSoundEnabled(enabled);

    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(soundEnabled: enabled));
  }

  /// Actualiza si las notificaciones están habilitadas
  Future<void> updateNotificationsEnabled(bool enabled) async {
    await PreferencesService.updateNotificationsEnabled(enabled);

    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(notificationsEnabled: enabled));
  }

  /// Reset a preferencias por defecto
  Future<void> reset() async {
    const defaultPrefs = PetPreferences();

    await PreferencesService.updatePetColor(defaultPrefs.petColor.value);
    await PreferencesService.updateAccessory(defaultPrefs.accessory);
    await PreferencesService.updateSoundEnabled(defaultPrefs.soundEnabled);
    await PreferencesService.updateNotificationsEnabled(
        defaultPrefs.notificationsEnabled);

    state = const AsyncValue.data(PetPreferences());
  }
}
