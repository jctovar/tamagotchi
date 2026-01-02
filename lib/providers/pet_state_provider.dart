import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../models/life_stage.dart';
import '../models/interaction_history.dart';
import '../models/pet_personality.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'services_provider.dart';

part 'pet_state_provider.g.dart';

/// Provider para el estado principal del Pet
///
/// Gestiona todo el estado de la mascota incluyendo:
/// - Métricas (hambre, felicidad, energía, salud)
/// - Acciones del usuario (feed, play, clean, rest)
/// - Sistema de experiencia y niveles
/// - Evolución y variantes
/// - Integración con Analytics
/// - Registro de interacciones para IA
@riverpod
class PetState extends _$PetState {
  @override
  Future<Pet> build() async {
    appLogger.d('Inicializando PetState...');

    final storage = ref.read(storageServiceProvider);

    final savedPet = await storage.loadPetState();

    if (savedPet != null) {
      appLogger.d(
          'Estado cargado - Hambre: ${savedPet.hunger.toStringAsFixed(1)}, Felicidad: ${savedPet.happiness.toStringAsFixed(1)}');

      // Actualizar métricas basado en tiempo transcurrido
      final updatedPet = storage.updatePetMetrics(savedPet);
      appLogger.d(
          'Estado actualizado - Hambre: ${updatedPet.hunger.toStringAsFixed(1)}, Felicidad: ${updatedPet.happiness.toStringAsFixed(1)}');

      // Actualizar propiedades de usuario en Analytics
      await AnalyticsService.updateUserProperties(updatedPet);

      return updatedPet;
    }

    // Crear una mascota nueva
    appLogger.i('Creando mascota nueva');
    final newPet = Pet(name: 'Mi Tamagotchi');

    // Guardar el estado inicial
    await storage.saveState(newPet);

    // Registrar creación en Analytics
    await AnalyticsService.logPetCreated(
      petName: newPet.name,
      initialColor: 'default',
    );

    return newPet;
  }

  /// Actualiza el nombre de la mascota
  Future<void> updateName(String name) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(name: name);

    final storage = ref.read(storageServiceProvider);
    await storage.saveState(updated);

    state = AsyncValue.data(updated);
  }

  /// Acción: Alimentar a la mascota
  ///
  /// Reduce hambre en 30 puntos y otorga experiencia.
  /// Registra eventos en Analytics e interacciones para IA.
  Future<void> feed() async {
    final current = state.value;
    if (current == null) return;

    final oldStage = current.lifeStage;
    final hungerBefore = current.hunger;
    final levelBefore = current.level;
    final experienceBefore = current.experience;

    // Calcular nuevo estado
    var updated = current.copyWith(
      hunger: (current.hunger - 30).clamp(0, 100),
      lastFed: DateTime.now(),
    );
    updated = updated.gainExperience('feed');
    updated = updated.updateLifeStage();
    updated = updated.updateVariant();

    // Guardar
    final storage = ref.read(storageServiceProvider);
    await storage.saveState(updated);

    // Actualizar estado
    state = AsyncValue.data(updated);

    // Analytics
    await AnalyticsService.logFeedPet(
      hungerBefore: hungerBefore,
      hungerAfter: updated.hunger,
      petLevel: updated.level,
    );

    final xpGained = updated.experience - experienceBefore;
    await AnalyticsService.logExperienceGained(
      experienceAmount: xpGained,
      totalExperience: updated.experience,
      source: 'interaction',
    );

    if (updated.level > levelBefore) {
      await AnalyticsService.logLevelUp(
        fromLevel: levelBefore,
        toLevel: updated.level,
        experience: updated.experience,
        currentStage: updated.lifeStage,
      );
    }

    // Registrar interacción para IA
    await _recordInteraction(InteractionType.feed);

    // Verificar evolución
    if (updated.lifeStage != oldStage) {
      await _checkEvolution(oldStage, updated);
    }
  }

  /// Acción: Jugar con la mascota
  ///
  /// Aumenta felicidad en 25 puntos, reduce energía en 15 puntos.
  /// Otorga experiencia y registra eventos.
  Future<void> play() async {
    final current = state.value;
    if (current == null) return;

    final oldStage = current.lifeStage;
    final happinessBefore = current.happiness;
    final levelBefore = current.level;
    final experienceBefore = current.experience;

    // Calcular nuevo estado
    var updated = current.copyWith(
      happiness: (current.happiness + 25).clamp(0, 100),
      energy: (current.energy - 15).clamp(0, 100),
      lastPlayed: DateTime.now(),
    );
    updated = updated.gainExperience('play');
    updated = updated.updateLifeStage();
    updated = updated.updateVariant();

    // Guardar
    final storage = ref.read(storageServiceProvider);
    await storage.saveState(updated);

    // Actualizar estado
    state = AsyncValue.data(updated);

    // Analytics
    await AnalyticsService.logPlayWithPet(
      happinessBefore: happinessBefore,
      happinessAfter: updated.happiness,
      petLevel: updated.level,
    );

    final xpGained = updated.experience - experienceBefore;
    await AnalyticsService.logExperienceGained(
      experienceAmount: xpGained,
      totalExperience: updated.experience,
      source: 'interaction',
    );

    if (updated.level > levelBefore) {
      await AnalyticsService.logLevelUp(
        fromLevel: levelBefore,
        toLevel: updated.level,
        experience: updated.experience,
        currentStage: updated.lifeStage,
      );
    }

    // Registrar interacción para IA
    await _recordInteraction(InteractionType.play);

    // Verificar evolución
    if (updated.lifeStage != oldStage) {
      await _checkEvolution(oldStage, updated);
    }
  }

  /// Acción: Limpiar a la mascota
  ///
  /// Aumenta salud en 20 puntos y otorga experiencia.
  Future<void> clean() async {
    final current = state.value;
    if (current == null) return;

    final oldStage = current.lifeStage;
    final healthBefore = current.health;
    final levelBefore = current.level;
    final experienceBefore = current.experience;

    // Calcular nuevo estado
    var updated = current.copyWith(
      health: (current.health + 20).clamp(0, 100),
      lastCleaned: DateTime.now(),
    );
    updated = updated.gainExperience('clean');
    updated = updated.updateLifeStage();
    updated = updated.updateVariant();

    // Guardar
    final storage = ref.read(storageServiceProvider);
    await storage.saveState(updated);

    // Actualizar estado
    state = AsyncValue.data(updated);

    // Analytics
    await AnalyticsService.logCleanPet(
      healthBefore: healthBefore,
      healthAfter: updated.health,
      petLevel: updated.level,
    );

    final xpGained = updated.experience - experienceBefore;
    await AnalyticsService.logExperienceGained(
      experienceAmount: xpGained,
      totalExperience: updated.experience,
      source: 'interaction',
    );

    if (updated.level > levelBefore) {
      await AnalyticsService.logLevelUp(
        fromLevel: levelBefore,
        toLevel: updated.level,
        experience: updated.experience,
        currentStage: updated.lifeStage,
      );
    }

    // Registrar interacción para IA
    await _recordInteraction(InteractionType.clean);

    // Verificar evolución
    if (updated.lifeStage != oldStage) {
      await _checkEvolution(oldStage, updated);
    }
  }

  /// Acción: Descansar
  ///
  /// Aumenta energía en 40 puntos y otorga experiencia.
  Future<void> rest() async {
    final current = state.value;
    if (current == null) return;

    final oldStage = current.lifeStage;
    final energyBefore = current.energy;
    final levelBefore = current.level;
    final experienceBefore = current.experience;

    // Calcular nuevo estado
    var updated = current.copyWith(
      energy: (current.energy + 40).clamp(0, 100),
      lastRested: DateTime.now(),
    );
    updated = updated.gainExperience('rest');
    updated = updated.updateLifeStage();
    updated = updated.updateVariant();

    // Guardar
    final storage = ref.read(storageServiceProvider);
    await storage.saveState(updated);

    // Actualizar estado
    state = AsyncValue.data(updated);

    // Analytics
    await AnalyticsService.logRestPet(
      energyBefore: energyBefore,
      energyAfter: updated.energy,
      petLevel: updated.level,
    );

    final xpGained = updated.experience - experienceBefore;
    await AnalyticsService.logExperienceGained(
      experienceAmount: xpGained,
      totalExperience: updated.experience,
      source: 'interaction',
    );

    if (updated.level > levelBefore) {
      await AnalyticsService.logLevelUp(
        fromLevel: levelBefore,
        toLevel: updated.level,
        experience: updated.experience,
        currentStage: updated.lifeStage,
      );
    }

    // Registrar interacción para IA
    await _recordInteraction(InteractionType.rest);

    // Verificar evolución
    if (updated.lifeStage != oldStage) {
      await _checkEvolution(oldStage, updated);
    }
  }

  /// Actualiza las métricas de la mascota basado en tiempo transcurrido
  ///
  /// Llamado periódicamente por el timer (cada 20 segundos).
  /// Calcula decaimiento de métricas y verifica estados críticos.
  void updateMetrics(DateTime lastUpdate) {
    final current = state.value;
    if (current == null) return;

    final now = DateTime.now();
    final secondsElapsed = now.difference(lastUpdate).inSeconds;

    if (secondsElapsed < 1) return; // Evitar actualizaciones muy frecuentes

    // Calcular nuevos valores
    double newHunger =
        current.hunger + (secondsElapsed * AppConstants.hungerDecayRate);
    double newHappiness =
        current.happiness - (secondsElapsed * AppConstants.happinessDecayRate);
    double newEnergy =
        current.energy - (secondsElapsed * AppConstants.energyDecayRate);
    double newHealth = current.health;

    // Reducir salud si las métricas están críticas
    if (newHunger > 80) {
      newHealth -= (secondsElapsed * 0.01);
    }
    if (newHappiness < 20) {
      newHealth -= (secondsElapsed * 0.01);
    }
    if (newEnergy < 20) {
      newHealth -= (secondsElapsed * 0.01);
    }

    // Aplicar límites
    newHunger = newHunger.clamp(0, 100);
    newHappiness = newHappiness.clamp(0, 100);
    newEnergy = newEnergy.clamp(0, 100);
    newHealth = newHealth.clamp(0, 100);

    var updated = current.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      energy: newEnergy,
      health: newHealth,
    );

    // Actualizar tiempo vivo y etapa de vida
    final oldStage = updated.lifeStage;
    updated = updated.updateLifeStage();
    updated = updated.updateVariant();

    // Guardar (sin await para no bloquear)
    final storage = ref.read(storageServiceProvider);
    storage.saveState(updated);

    // Actualizar estado
    state = AsyncValue.data(updated);

    // Verificar evolución
    if (updated.lifeStage != oldStage) {
      _checkEvolution(oldStage, updated);
    }

    // Notificación si crítico
    if (updated.isCritical) {
      NotificationService.showCriticalNotification(updated);
    }
  }

  /// Agrega recompensas de mini-juegos
  ///
  /// Actualiza experiencia y monedas después de completar un mini-juego.
  Future<void> addRewards({required int xp, required int coins}) async {
    final current = state.value;
    if (current == null) return;

    final levelBefore = current.level;

    var updated = current.copyWith(
      experience: current.experience + xp,
      coins: current.coins + coins,
    );

    updated = updated.updateLifeStage();

    final storage = ref.read(storageServiceProvider);
    await storage.saveState(updated);

    state = AsyncValue.data(updated);

    // Analytics si subió de nivel
    if (updated.level > levelBefore) {
      await AnalyticsService.logLevelUp(
        fromLevel: levelBefore,
        toLevel: updated.level,
        experience: updated.experience,
        currentStage: updated.lifeStage,
      );
    }
  }

  /// Registra una interacción en el historial para el sistema de IA
  Future<void> _recordInteraction(InteractionType type) async {
    final current = state.value;
    if (current == null) return;

    final storage = ref.read(storageServiceProvider);
    await storage.recordInteraction(
      type: type,
      hungerBefore: current.hunger,
      happinessBefore: current.happiness,
      energyBefore: current.energy,
      healthBefore: current.health,
    );
  }

  /// Verifica si hubo evolución y registra evento en Analytics
  Future<void> _checkEvolution(LifeStage oldStage, Pet pet) async {
    await AnalyticsService.logPetEvolved(
      fromStage: oldStage,
      toStage: pet.lifeStage,
      variant: pet.variant,
      level: pet.level,
      experience: pet.experience,
    );

    await AnalyticsService.updateUserProperties(pet);

    // Marcar que hubo evolución para mostrar diálogo
    ref.read(showEvolutionDialogProvider.notifier).show();
  }

  /// Reset completo del Tamagotchi
  Future<void> reset() async {
    appLogger.w('Reseteando Tamagotchi...');

    final storage = ref.read(storageServiceProvider);

    // Crear nueva mascota
    final newPet = Pet(name: 'Mi Tamagotchi');
    await storage.saveState(newPet);

    // Limpiar historial y personalidad
    await storage.saveInteractionHistory(InteractionHistory());
    await storage.savePetPersonality(PetPersonality());

    state = AsyncValue.data(newPet);

    appLogger.i('Tamagotchi reseteado exitosamente');
  }
}

// ============================================================================
// PROVIDERS DERIVADOS - Para optimización de rebuilds
// ============================================================================

/// Provider que solo emite cuando el hambre cambia
@riverpod
double petHunger(Ref ref) {
  return ref.watch(petStateProvider.select((s) => s.value?.hunger ?? 0));
}

/// Provider que solo emite cuando la felicidad cambia
@riverpod
double petHappiness(Ref ref) {
  return ref.watch(petStateProvider.select((s) => s.value?.happiness ?? 0));
}

/// Provider que solo emite cuando la energía cambia
@riverpod
double petEnergy(Ref ref) {
  return ref.watch(petStateProvider.select((s) => s.value?.energy ?? 0));
}

/// Provider que solo emite cuando la salud cambia
@riverpod
double petHealth(Ref ref) {
  return ref.watch(petStateProvider.select((s) => s.value?.health ?? 0));
}

/// Provider que solo emite cuando las monedas cambian
@riverpod
int petCoins(Ref ref) {
  return ref.watch(petStateProvider.select((s) => s.value?.coins ?? 0));
}

/// Provider que solo emite cuando el nivel cambia
@riverpod
int petLevel(Ref ref) {
  return ref.watch(petStateProvider.select((s) => s.value?.level ?? 1));
}

/// Provider que solo emite cuando el estado crítico cambia
@riverpod
bool petIsCritical(Ref ref) {
  return ref
      .watch(petStateProvider.select((s) => s.value?.isCritical ?? false));
}

/// Provider que solo emite cuando el nombre cambia
@riverpod
String petName(Ref ref) {
  return ref
      .watch(petStateProvider.select((s) => s.value?.name ?? 'Tamagotchi'));
}

/// Provider para controlar si se debe mostrar el diálogo de evolución
@riverpod
class ShowEvolutionDialog extends _$ShowEvolutionDialog {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}
