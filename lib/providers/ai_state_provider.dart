import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/interaction_history.dart';
import '../models/pet_personality.dart';
import '../services/ai_service.dart';
import 'services_provider.dart';
import 'pet_state_provider.dart';

part 'ai_state_provider.g.dart';

/// Provider para el estado de la personalidad de la mascota
///
/// Gestiona la personalidad adaptativa que evoluciona basada en interacciones.
@riverpod
class PersonalityState extends _$PersonalityState {
  @override
  Future<PetPersonality> build() async {
    final storage = ref.read(storageServiceProvider);
    return await storage.loadPetPersonality();
  }

  /// Actualiza la personalidad desde una interacción
  Future<void> updateFromInteraction(Interaction interaction) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.updateFromInteraction(interaction);
    final storage = ref.read(storageServiceProvider);
    await storage.savePetPersonality(updated);

    state = AsyncValue.data(updated);
  }

  /// Actualiza el estado emocional basado en métricas
  void updateEmotionalState({
    required double hunger,
    required double happiness,
    required double energy,
    required double health,
    required int minutesSinceLastInteraction,
  }) {
    final current = state.value;
    if (current == null) return;

    final updated = current.updateEmotionalState(
      hunger: hunger,
      happiness: happiness,
      energy: energy,
      health: health,
      minutesSinceLastInteraction: minutesSinceLastInteraction,
    );

    state = AsyncValue.data(updated);
  }
}

/// Provider para el historial de interacciones
@riverpod
class InteractionHistoryState extends _$InteractionHistoryState {
  @override
  Future<InteractionHistory> build() async {
    final storage = ref.read(storageServiceProvider);
    return await storage.loadInteractionHistory();
  }

  /// Agrega una interacción al historial
  Future<void> addInteraction(Interaction interaction) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.addInteraction(interaction);
    final storage = ref.read(storageServiceProvider);
    await storage.saveInteractionHistory(updated);

    state = AsyncValue.data(updated);
  }
}

// ============================================================================
// PROVIDERS DERIVADOS - Para cálculo reactivo
// ============================================================================

/// Provider que genera el mensaje de la mascota reactivamente
///
/// Observa cambios en Pet, Personality e History y regenera el mensaje.
@riverpod
String petMessage(Ref ref) {
  final petAsync = ref.watch(petStateProvider);
  final personalityAsync = ref.watch(personalityStateProvider);
  final historyAsync = ref.watch(interactionHistoryStateProvider);

  final pet = petAsync.value;
  final personality = personalityAsync.value;
  final history = historyAsync.value;

  if (pet == null || personality == null || history == null) {
    return 'Hola! Soy tu Tamagotchi 👋';
  }

  final aiService = ref.read(aiServiceProvider);
  return aiService.generatePetMessage(
    pet: pet,
    personality: personality,
    history: history,
  );
}

/// Provider que genera la sugerencia de acción reactivamente
@riverpod
AISuggestion? petSuggestion(Ref ref) {
  final petAsync = ref.watch(petStateProvider);
  final personalityAsync = ref.watch(personalityStateProvider);
  final historyAsync = ref.watch(interactionHistoryStateProvider);

  final pet = petAsync.value;
  final personality = personalityAsync.value;
  final history = historyAsync.value;

  if (pet == null || personality == null || history == null) {
    return null;
  }

  final aiService = ref.read(aiServiceProvider);
  return aiService.generateSuggestion(
    pet: pet,
    personality: personality,
    history: history,
  );
}
