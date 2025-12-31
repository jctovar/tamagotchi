import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/pet.dart';
import '../models/life_stage.dart';

/// Servicio centralizado para Firebase Analytics
///
/// Gestiona el registro de eventos y propiedades de usuario para análisis
/// de comportamiento y engagement en la aplicación Tamagotchi.
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ==================== Eventos de Ciclo de Vida ====================

  /// Registra cuando un usuario crea su primera mascota
  static Future<void> logPetCreated({
    required String petName,
    required String initialColor,
  }) async {
    await _analytics.logEvent(
      name: 'pet_created',
      parameters: {
        'pet_name': petName,
        'initial_color': initialColor,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Registra cuando el usuario completa el onboarding
  static Future<void> logOnboardingCompleted() async {
    await _analytics.logEvent(
      name: 'onboarding_completed',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== Eventos de Interacción ====================

  /// Registra cuando el usuario alimenta a su mascota
  static Future<void> logFeedPet({
    required double hungerBefore,
    required double hungerAfter,
    required int petLevel,
  }) async {
    await _analytics.logEvent(
      name: 'pet_fed',
      parameters: {
        'hunger_before': hungerBefore.toInt(),
        'hunger_after': hungerAfter.toInt(),
        'hunger_reduced': (hungerBefore - hungerAfter).toInt(),
        'pet_level': petLevel,
      },
    );
  }

  /// Registra cuando el usuario juega con su mascota
  static Future<void> logPlayWithPet({
    required double happinessBefore,
    required double happinessAfter,
    required int petLevel,
  }) async {
    await _analytics.logEvent(
      name: 'pet_played',
      parameters: {
        'happiness_before': happinessBefore.toInt(),
        'happiness_after': happinessAfter.toInt(),
        'happiness_gained': (happinessAfter - happinessBefore).toInt(),
        'pet_level': petLevel,
      },
    );
  }

  /// Registra cuando el usuario limpia a su mascota
  static Future<void> logCleanPet({
    required double healthBefore,
    required double healthAfter,
    required int petLevel,
  }) async {
    await _analytics.logEvent(
      name: 'pet_cleaned',
      parameters: {
        'health_before': healthBefore.toInt(),
        'health_after': healthAfter.toInt(),
        'health_gained': (healthAfter - healthBefore).toInt(),
        'pet_level': petLevel,
      },
    );
  }

  /// Registra cuando el usuario hace descansar a su mascota
  static Future<void> logRestPet({
    required double energyBefore,
    required double energyAfter,
    required int petLevel,
  }) async {
    await _analytics.logEvent(
      name: 'pet_rested',
      parameters: {
        'energy_before': energyBefore.toInt(),
        'energy_after': energyAfter.toInt(),
        'energy_gained': (energyAfter - energyBefore).toInt(),
        'pet_level': petLevel,
      },
    );
  }

  // ==================== Eventos de Personalización ====================

  /// Registra cuando el usuario cambia el nombre de su mascota
  static Future<void> logPetRenamed({
    required String oldName,
    required String newName,
  }) async {
    await _analytics.logEvent(
      name: 'pet_renamed',
      parameters: {
        'old_name': oldName,
        'new_name': newName,
      },
    );
  }

  /// Registra cuando el usuario cambia el color de su mascota
  static Future<void> logPetColorChanged({
    required String newColor,
    required int coinsSpent,
  }) async {
    await _analytics.logEvent(
      name: 'pet_color_changed',
      parameters: {
        'new_color': newColor,
        'coins_spent': coinsSpent,
      },
    );
  }

  /// Registra cuando el usuario compra un accesorio
  static Future<void> logAccessoryPurchased({
    required String accessoryType,
    required int coinsSpent,
  }) async {
    await _analytics.logEvent(
      name: 'accessory_purchased',
      parameters: {
        'accessory_type': accessoryType,
        'coins_spent': coinsSpent,
      },
    );
  }

  /// Registra cuando el usuario cambia el accesorio equipado
  static Future<void> logAccessoryChanged({
    required String? oldAccessory,
    required String? newAccessory,
  }) async {
    await _analytics.logEvent(
      name: 'accessory_changed',
      parameters: {
        'old_accessory': oldAccessory ?? 'none',
        'new_accessory': newAccessory ?? 'none',
      },
    );
  }

  // ==================== Eventos de Evolución ====================

  /// Registra cuando la mascota evoluciona a una nueva etapa
  static Future<void> logPetEvolved({
    required LifeStage fromStage,
    required LifeStage toStage,
    required PetVariant variant,
    required int level,
    required int experience,
  }) async {
    await _analytics.logEvent(
      name: 'pet_evolved',
      parameters: {
        'from_stage': fromStage.name,
        'to_stage': toStage.name,
        'variant': variant.name,
        'level': level,
        'experience': experience,
      },
    );
  }

  /// Registra cuando la mascota sube de nivel
  static Future<void> logLevelUp({
    required int fromLevel,
    required int toLevel,
    required int experience,
    required LifeStage currentStage,
  }) async {
    await _analytics.logEvent(
      name: 'level_up',
      parameters: {
        'from_level': fromLevel,
        'to_level': toLevel,
        'experience': experience,
        'current_stage': currentStage.name,
      },
    );
  }

  /// Registra cuando la mascota gana experiencia
  static Future<void> logExperienceGained({
    required int experienceAmount,
    required int totalExperience,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'experience_gained',
      parameters: {
        'amount': experienceAmount,
        'total_experience': totalExperience,
        'source': source, // 'interaction', 'minigame', etc.
      },
    );
  }

  // ==================== Eventos de Mini-Juegos ====================

  /// Registra cuando el usuario inicia un mini-juego
  static Future<void> logMinigameStarted({
    required String gameType,
  }) async {
    await _analytics.logEvent(
      name: 'minigame_started',
      parameters: {
        'game_type': gameType,
      },
    );
  }

  /// Registra cuando el usuario completa un mini-juego
  static Future<void> logMinigameCompleted({
    required String gameType,
    required int score,
    required bool won,
    required int coinsEarned,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'minigame_completed',
      parameters: {
        'game_type': gameType,
        'score': score,
        'won': won,
        'coins_earned': coinsEarned,
        'duration_seconds': durationSeconds,
      },
    );
  }

  // ==================== Eventos de Estado Crítico ====================

  /// Registra cuando la mascota alcanza un estado crítico
  static Future<void> logCriticalState({
    required String stateType, // 'hunger', 'happiness', 'energy', 'health'
    required double currentValue,
  }) async {
    await _analytics.logEvent(
      name: 'critical_state',
      parameters: {
        'state_type': stateType,
        'current_value': currentValue.toInt(),
      },
    );
  }

  /// Registra cuando la mascota muere (todas las métricas en 0)
  static Future<void> logPetDied({
    required int finalLevel,
    required LifeStage finalStage,
    required int daysSurvived,
  }) async {
    await _analytics.logEvent(
      name: 'pet_died',
      parameters: {
        'final_level': finalLevel,
        'final_stage': finalStage.name,
        'days_survived': daysSurvived,
      },
    );
  }

  // ==================== Eventos de Notificaciones ====================

  /// Registra cuando se muestra una notificación
  static Future<void> logNotificationShown({
    required String notificationType,
  }) async {
    await _analytics.logEvent(
      name: 'notification_shown',
      parameters: {
        'notification_type': notificationType,
      },
    );
  }

  /// Registra cuando el usuario abre la app desde una notificación
  static Future<void> logNotificationOpened({
    required String notificationType,
  }) async {
    await _analytics.logEvent(
      name: 'notification_opened',
      parameters: {
        'notification_type': notificationType,
      },
    );
  }

  // ==================== Propiedades de Usuario ====================

  /// Actualiza las propiedades de usuario con el estado actual de la mascota
  static Future<void> updateUserProperties(Pet pet) async {
    await _analytics.setUserProperty(
      name: 'pet_stage',
      value: pet.lifeStage.name,
    );
    await _analytics.setUserProperty(
      name: 'pet_level',
      value: pet.level.toString(),
    );
    await _analytics.setUserProperty(
      name: 'pet_variant',
      value: pet.variant.name,
    );
    await _analytics.setUserProperty(
      name: 'total_coins',
      value: pet.coins.toString(),
    );
  }

  /// Establece el ID del usuario (opcional, para análisis cross-device)
  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  // ==================== Eventos de Sesión ====================

  /// Registra cuando el usuario abre la aplicación
  static Future<void> logAppOpened() async {
    await _analytics.logAppOpen();
  }

  /// Registra cuando el usuario navega a una pantalla
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ==================== Eventos de Economía ====================

  /// Registra cuando el usuario gana monedas
  static Future<void> logCoinsEarned({
    required int amount,
    required String source, // 'minigame', 'daily_reward', 'interaction'
  }) async {
    await _analytics.logEvent(
      name: 'coins_earned',
      parameters: {
        'amount': amount,
        'source': source,
      },
    );
  }

  /// Registra cuando el usuario gasta monedas
  static Future<void> logCoinsSpent({
    required int amount,
    required String itemType, // 'color', 'accessory', etc.
    required String itemName,
  }) async {
    await _analytics.logEvent(
      name: 'coins_spent',
      parameters: {
        'amount': amount,
        'item_type': itemType,
        'item_name': itemName,
      },
    );
  }

  // ==================== Eventos de Machine Learning ====================

  /// Registra cuando se inicializa el servicio ML
  static Future<void> logMLServiceInitialized({
    required List<String> modelsLoaded,
    required int initializationTimeMs,
    required bool success,
  }) async {
    await _analytics.logEvent(
      name: 'ml_service_initialized',
      parameters: {
        'models_loaded': modelsLoaded.join(','),
        'models_count': modelsLoaded.length,
        'initialization_time_ms': initializationTimeMs,
        'success': success,
      },
    );
  }

  /// Registra métricas de inferencia ML
  static Future<void> logMLInference({
    required String modelName,
    required int inferenceTimeMs,
    required bool success,
    String? errorType,
  }) async {
    await _analytics.logEvent(
      name: 'ml_inference',
      parameters: {
        'model_name': modelName,
        'inference_time_ms': inferenceTimeMs,
        'success': success,
        if (errorType != null) 'error_type': errorType,
      },
    );
  }

  /// Registra cuando se usa ML fallback a reglas
  static Future<void> logMLFallback({
    required String modelName,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'ml_fallback',
      parameters: {
        'model_name': modelName,
        'reason': reason,
      },
    );
  }

  /// Registra estadísticas de rendimiento ML acumuladas
  static Future<void> logMLPerformanceStats({
    required String modelName,
    required int totalInferences,
    required int successfulInferences,
    required double averageTimeMs,
    required double minTimeMs,
    required double maxTimeMs,
  }) async {
    await _analytics.logEvent(
      name: 'ml_performance_stats',
      parameters: {
        'model_name': modelName,
        'total_inferences': totalInferences,
        'successful_inferences': successfulInferences,
        'success_rate': (successfulInferences / totalInferences * 100).round(),
        'avg_time_ms': averageTimeMs.round(),
        'min_time_ms': minTimeMs.round(),
        'max_time_ms': maxTimeMs.round(),
      },
    );
  }

  /// Registra cuando una predicción ML se sigue o ignora
  static Future<void> logMLPredictionFeedback({
    required String modelName,
    required String predictedAction,
    required String actualAction,
    required bool followed,
    required double confidence,
  }) async {
    await _analytics.logEvent(
      name: 'ml_prediction_feedback',
      parameters: {
        'model_name': modelName,
        'predicted_action': predictedAction,
        'actual_action': actualAction,
        'followed': followed,
        'confidence': (confidence * 100).round(),
      },
    );
  }

  /// Registra cuando una sugerencia ML se muestra al usuario
  static Future<void> logMLSuggestionShown({
    required String suggestionType,
    required String action,
    required double urgency,
    required bool isUrgent,
  }) async {
    await _analytics.logEvent(
      name: 'ml_suggestion_shown',
      parameters: {
        'suggestion_type': suggestionType,
        'action': action,
        'urgency': (urgency * 100).round(),
        'is_urgent': isUrgent,
      },
    );
  }
}
