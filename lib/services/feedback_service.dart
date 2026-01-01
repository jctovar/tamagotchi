/// Servicio para manejar efectos de sonido y haptic feedback
library;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../services/preferences_service.dart';

/// Tipo de feedback
enum FeedbackType {
  feed,
  play,
  clean,
  rest,
  tap,
  success,
  error,
}

class FeedbackService {

  /// Reproduce haptic feedback según el tipo
  static Future<void> playHaptic(FeedbackType type) async {
    // Cargar preferencias para verificar si el sonido está habilitado
    final preferences = await PreferencesService.loadPreferences();
    if (!preferences.soundEnabled) return;

    // Verificar si el dispositivo soporta vibración
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    switch (type) {
      case FeedbackType.feed:
      case FeedbackType.play:
      case FeedbackType.clean:
      case FeedbackType.rest:
        // Feedback medio para acciones principales
        HapticFeedback.mediumImpact();
        break;

      case FeedbackType.success:
        // Patrón de vibración para éxito
        if (await Vibration.hasCustomVibrationsSupport() == true) {
          Vibration.vibrate(pattern: [0, 100, 50, 100]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;

      case FeedbackType.error:
        // Patrón de vibración para error
        if (await Vibration.hasCustomVibrationsSupport() == true) {
          Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;

      case FeedbackType.tap:
        // Feedback ligero para taps
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Feedback de selección (para sliders, switches, etc.)
  static Future<void> playSelection() async {
    final preferences = await PreferencesService.loadPreferences();
    if (!preferences.soundEnabled) return;

    HapticFeedback.selectionClick();
  }

  /// Feedback ligero para interacciones menores
  static Future<void> playLight() async {
    final preferences = await PreferencesService.loadPreferences();
    if (!preferences.soundEnabled) return;

    HapticFeedback.lightImpact();
  }

  /// Feedback medio para interacciones normales
  static Future<void> playMedium() async {
    final preferences = await PreferencesService.loadPreferences();
    if (!preferences.soundEnabled) return;

    HapticFeedback.mediumImpact();
  }

  /// Feedback fuerte para interacciones importantes
  static Future<void> playHeavy() async {
    final preferences = await PreferencesService.loadPreferences();
    if (!preferences.soundEnabled) return;

    HapticFeedback.heavyImpact();
  }

  /// Vibración personalizada
  static Future<void> playCustomVibration({
    required int duration,
    List<int>? pattern,
  }) async {
    final preferences = await PreferencesService.loadPreferences();
    if (!preferences.soundEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    if (pattern != null) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(pattern: pattern);
      }
    } else {
      Vibration.vibrate(duration: duration);
    }
  }

  /// Feedback cuando la mascota está feliz
  static Future<void> playHappyFeedback() async {
    await playHaptic(FeedbackType.success);
  }

  /// Feedback cuando la mascota está en estado crítico
  static Future<void> playCriticalFeedback() async {
    await playHaptic(FeedbackType.error);
  }
}
