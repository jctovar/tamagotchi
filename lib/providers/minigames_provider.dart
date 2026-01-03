import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/minigame_stats.dart';
import '../services/analytics_service.dart';
import 'services_provider.dart';
import 'pet_state_provider.dart';

part 'minigames_provider.g.dart';

/// Provider para el estado de estadísticas de mini-juegos
///
/// Gestiona las estadísticas de todos los mini-juegos y coordina
/// las recompensas (XP y monedas) con el PetStateProvider.
@riverpod
class MiniGameStatsState extends _$MiniGameStatsState {
  @override
  Future<MiniGameStats> build() async {
    final storage = ref.read(storageServiceProvider);
    return await storage.loadMiniGameStats();
  }

  /// Actualiza las estadísticas después de completar un mini-juego
  ///
  /// Este método:
  /// 1. Actualiza las estadísticas del juego
  /// 2. Otorga recompensas (XP y monedas) al pet
  /// 3. Registra eventos en Analytics
  Future<void> updateStats(GameResult result) async {
    final current = state.value;
    if (current == null) return;

    final storage = ref.read(storageServiceProvider);

    // 1. Actualizar estadísticas del juego
    await storage.updateGameStats(result);

    // 2. Recargar estadísticas
    final updatedStats = await storage.loadMiniGameStats();
    state = AsyncValue.data(updatedStats);

    // 3. Otorgar recompensas al pet (XP y monedas)
    await ref.read(petStateProvider.notifier).addRewards(
          xp: result.xpEarned,
          coins: result.coinsEarned,
        );

    // 4. Registrar eventos en Analytics
    await AnalyticsService.logMinigameCompleted(
      gameType: result.gameType.name,
      score: result.score,
      won: result.won,
      coinsEarned: result.coinsEarned,
      durationSeconds: result.duration.inSeconds,
    );

    await AnalyticsService.logExperienceGained(
      experienceAmount: result.xpEarned,
      totalExperience: ref.read(petStateProvider).value?.experience ?? 0,
      source: 'minigame',
    );

    await AnalyticsService.logCoinsEarned(
      amount: result.coinsEarned,
      source: 'minigame',
    );
  }
}

/// Provider derivado para obtener estadísticas de un juego específico
@riverpod
GameStats? gameStats(Ref ref, MiniGameType gameType) {
  final stats = ref.watch(miniGameStatsStateProvider).value;
  if (stats == null) return null;

  return stats.getStats(gameType);
}
