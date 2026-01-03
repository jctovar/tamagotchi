import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/minigame_stats.dart';
import '../../services/analytics_service.dart';
import '../../providers/minigames_provider.dart';
import 'memory_game_screen.dart';
import 'sliding_puzzle_screen.dart';
import 'reaction_race_screen.dart';

/// Pantalla de selección de mini-juegos (Refactorizada con Riverpod)
///
/// Muestra todos los mini-juegos disponibles con sus estadísticas.
/// Sincronización automática con providers - sin callbacks manuales.
class MiniGamesMenuScreen extends ConsumerWidget {
  const MiniGamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(miniGameStatsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini-Juegos'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) => _buildContent(context, ref, stats),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, MiniGameStats stats) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen general
            _buildOverallStats(stats),
            const SizedBox(height: 24),

            // Título
            const Text(
              'Elige un juego',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de juegos
            ...MiniGameType.values.map((gameType) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGameCard(context, ref, gameType, stats),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(MiniGameStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Estadísticas Generales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Partidas',
                  stats.totalGamesPlayed.toString(),
                  Icons.gamepad,
                ),
                _buildStatColumn(
                  'Victorias',
                  stats.totalWins.toString(),
                  Icons.star,
                ),
                _buildStatColumn(
                  'XP Total',
                  stats.totalXpEarned.toString(),
                  Icons.trending_up,
                ),
                _buildStatColumn(
                  'Monedas',
                  '${stats.totalCoinsEarned} 🪙',
                  Icons.monetization_on,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, WidgetRef ref, MiniGameType gameType, MiniGameStats stats) {
    final gameStats = stats.getStats(gameType);
    final winRate = gameStats.winRate;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToGame(context, ref, gameType),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del juego
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(gameType.colorValue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    gameType.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Información del juego
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameType.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gameType.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Estadísticas del juego
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildGameStat(
                          '🎮 ${gameStats.timesPlayed}',
                          'jugadas',
                        ),
                        _buildGameStat(
                          '⭐ ${gameStats.timesWon}',
                          'victorias',
                        ),
                        _buildGameStat(
                          '📊 ${winRate.toStringAsFixed(0)}%',
                          'win rate',
                        ),
                        _buildGameStat(
                          '🏆 ${gameStats.bestScore}',
                          'récord',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Flecha
              Icon(
                Icons.chevron_right,
                color: Color(gameType.colorValue),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Navega a la pantalla del juego seleccionado
  void _navigateToGame(BuildContext context, WidgetRef ref, MiniGameType gameType) async {
    Widget gameScreen;

    switch (gameType) {
      case MiniGameType.memory:
        gameScreen = const MemoryGameScreen();
        break;
      case MiniGameType.slidingPuzzle:
        gameScreen = const SlidingPuzzleScreen();
        break;
      case MiniGameType.reactionRace:
        gameScreen = const ReactionRaceScreen();
        break;
    }

    // Registrar evento de inicio de juego en Analytics
    await AnalyticsService.logMinigameStarted(
      gameType: gameType.name,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => gameScreen),
      );
    }
  }
}
