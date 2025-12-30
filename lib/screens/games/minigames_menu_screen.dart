import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../models/minigame_stats.dart';
import '../../services/storage_service.dart';
import '../../services/analytics_service.dart';
import 'memory_game_screen.dart';
import 'sliding_puzzle_screen.dart';
import 'reaction_race_screen.dart';

/// Pantalla de selección de mini-juegos
///
/// Muestra todos los mini-juegos disponibles con sus estadísticas
/// y permite al jugador seleccionar uno para jugar.
class MiniGamesMenuScreen extends StatefulWidget {
  /// Mascota actual del jugador
  final Pet pet;

  /// Callback ejecutado cuando la mascota es actualizada tras completar un juego
  final Function(Pet updatedPet) onPetUpdated;

  const MiniGamesMenuScreen({
    super.key,
    required this.pet,
    required this.onPetUpdated,
  });

  @override
  State<MiniGamesMenuScreen> createState() => _MiniGamesMenuScreenState();
}

class _MiniGamesMenuScreenState extends State<MiniGamesMenuScreen> {
  final StorageService _storageService = StorageService();
  MiniGameStats _stats = MiniGameStats();
  bool _isLoading = true;
  late Pet _currentPet;

  @override
  void initState() {
    super.initState();
    _currentPet = widget.pet;
    _loadStats();
  }

  /// Carga las estadísticas de mini-juegos desde el almacenamiento
  Future<void> _loadStats() async {
    final stats = await _storageService.loadMiniGameStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  /// Callback ejecutado cuando se completa un mini-juego
  ///
  /// [updatedPet] Mascota con XP y monedas actualizadas
  /// [result] Resultados del juego completado
  /// Actualiza estadísticas, guarda el estado y notifica cambios.
  void _onGameComplete(Pet updatedPet, GameResult result) async {
    // Actualizar estadísticas del juego en el almacenamiento
    await _storageService.updateGameStats(result);

    // Recargar estadísticas para reflejar los cambios
    await _loadStats();

    // Guardar estado actualizado de la mascota
    await _storageService.saveState(updatedPet);

    // Registrar evento en Analytics
    await AnalyticsService.logMinigameCompleted(
      gameType: result.gameType.name,
      score: result.score,
      won: result.won,
      coinsEarned: result.coinsEarned,
      durationSeconds: result.duration.inSeconds,
    );

    // Registrar ganancia de experiencia
    await AnalyticsService.logExperienceGained(
      experienceAmount: result.xpEarned,
      totalExperience: updatedPet.experience,
      source: 'minigame',
    );

    // Registrar monedas ganadas
    await AnalyticsService.logCoinsEarned(
      amount: result.coinsEarned,
      source: 'minigame',
    );

    // Notificar al padre sobre la actualización
    widget.onPetUpdated(updatedPet);

    setState(() {
      _currentPet = updatedPet;
    });

    // Mostrar snackbar con resumen
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Juego completado! +${result.xpEarned} XP, +${result.coinsEarned} monedas',
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Navega a la pantalla del juego seleccionado
  ///
  /// [gameType] Tipo de mini-juego a iniciar
  void _navigateToGame(MiniGameType gameType) async {
    Widget gameScreen;

    switch (gameType) {
      case MiniGameType.memory:
        gameScreen = MemoryGameScreen(
          pet: _currentPet,
          onGameComplete: _onGameComplete,
        );
        break;
      case MiniGameType.slidingPuzzle:
        gameScreen = SlidingPuzzleScreen(
          pet: _currentPet,
          onGameComplete: _onGameComplete,
        );
        break;
      case MiniGameType.reactionRace:
        gameScreen = ReactionRaceScreen(
          pet: _currentPet,
          onGameComplete: _onGameComplete,
        );
        break;
    }

    // Registrar evento de inicio de juego en Analytics
    await AnalyticsService.logMinigameStarted(
      gameType: gameType.name,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => gameScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini-Juegos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen general
                    _buildOverallStats(),
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
                        child: _buildGameCard(gameType),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallStats() {
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
                  _stats.totalGamesPlayed.toString(),
                  Icons.gamepad,
                ),
                _buildStatColumn(
                  'Victorias',
                  _stats.totalWins.toString(),
                  Icons.star,
                ),
                _buildStatColumn(
                  'XP Total',
                  _stats.totalXpEarned.toString(),
                  Icons.trending_up,
                ),
                _buildStatColumn(
                  'Monedas',
                  '${_stats.totalCoinsEarned} 🪙',
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

  Widget _buildGameCard(MiniGameType gameType) {
    final gameStats = _stats.getStats(gameType);
    final winRate = gameStats.winRate;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToGame(gameType),
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
                  color: Color(gameType.colorValue).withAlpha(30),
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
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Estadísticas del juego
                    if (gameStats.timesPlayed > 0) ...[
                      Wrap(
                        spacing: 12,
                        children: [
                          _buildMiniStat(
                            '${gameStats.timesPlayed} jugadas',
                            Icons.play_circle_outline,
                          ),
                          _buildMiniStat(
                            '${winRate.toStringAsFixed(0)}% victorias',
                            Icons.check_circle_outline,
                          ),
                          _buildMiniStat(
                            'Récord: ${gameStats.bestScore}',
                            Icons.star_outline,
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '¡Nuevo! Juega por primera vez',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
