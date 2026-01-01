import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../models/pet.dart';
import '../../models/minigame_stats.dart';
import '../../services/feedback_service.dart';

/// Pantalla del juego Reaction Race (carrera de reacción)
///
/// Juego de reflejos donde el jugador debe presionar cuando el círculo
/// cambia de naranja a verde. Se mide el tiempo de reacción en cada ronda.
/// Las recompensas dependen de la velocidad de reacción promedio.
class ReactionRaceScreen extends StatefulWidget {
  /// Mascota actual del jugador
  final Pet pet;

  /// Callback ejecutado al completar el juego con la mascota actualizada y resultados
  final Function(Pet updatedPet, GameResult result) onGameComplete;

  const ReactionRaceScreen({
    super.key,
    required this.pet,
    required this.onGameComplete,
  });

  @override
  State<ReactionRaceScreen> createState() => _ReactionRaceScreenState();
}

class _ReactionRaceScreenState extends State<ReactionRaceScreen> {
  static const int _totalRounds = 10;
  static const int _minWaitMs = 1000;
  static const int _maxWaitMs = 4000;

  GameState _gameState = GameState.waiting;
  int _currentRound = 0;
  final List<int> _reactionTimes = [];
  DateTime? _targetTime;
  Timer? _changeTimer;
  bool _tooEarly = false;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _playBackgroundMusic();
  }

  @override
  void dispose() {
    _changeTimer?.cancel();
    _stopBackgroundMusic();
    super.dispose();
  }

  /// Reproduce música de fondo en loop
  void _playBackgroundMusic() async {
    try {
      await FlameAudio.bgm.play('Chase.wav', volume: 0.3);
    } catch (e) {
      debugPrint('Error al reproducir música de fondo: $e');
    }
  }

  /// Detiene la música de fondo
  void _stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  /// Inicia una nueva ronda del juego
  ///
  /// Configura el estado de espera y programa el cambio a verde después
  /// de un tiempo aleatorio entre 1 y 4 segundos.
  void _startRound() {
    if (_currentRound >= _totalRounds) {
      _finishGame();
      return;
    }

    setState(() {
      _gameState = GameState.waiting;
      _tooEarly = false;
    });

    // Programar cambio a verde después de tiempo aleatorio (1-4 segundos)
    final random = Random();
    final waitMs = _minWaitMs + random.nextInt(_maxWaitMs - _minWaitMs);

    _changeTimer?.cancel();
    _changeTimer = Timer(Duration(milliseconds: waitMs), () {
      if (mounted) {
        setState(() {
          _gameState = GameState.react;
          _targetTime = DateTime.now();
        });
      }
    });
  }

  /// Maneja el evento de tocar la pantalla
  ///
  /// Procesa el toque según el estado actual: penaliza si es muy temprano,
  /// mide el tiempo de reacción si es en el momento correcto.
  void _onTap() {
    if (_gameState == GameState.waiting) {
      // Toque prematuro: penalizar y pasar a siguiente ronda
      _changeTimer?.cancel();
      FeedbackService.playHaptic(FeedbackType.error);

      setState(() {
        _tooEarly = true;
        _gameState = GameState.result;
      });

      // Esperar 1.5 segundos antes de continuar a la siguiente ronda
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _currentRound++;
          _startRound();
        }
      });
    } else if (_gameState == GameState.react) {
      // Calcular tiempo de reacción desde que cambió a verde
      final reactionTime = DateTime.now().difference(_targetTime!).inMilliseconds;
      _reactionTimes.add(reactionTime);

      FeedbackService.playHaptic(FeedbackType.success);

      setState(() {
        _gameState = GameState.result;
      });

      // Esperar antes de continuar
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _currentRound++;
          _startRound();
        }
      });
    }
  }

  /// Finaliza el juego y calcula resultados
  ///
  /// Calcula la puntuación basada en el tiempo de reacción promedio,
  /// determina las recompensas y muestra el diálogo de resultados.
  void _finishGame() {
    _changeTimer?.cancel();

    if (_reactionTimes.isEmpty) {
      // No completó ninguna ronda correctamente, salir sin recompensas
      Navigator.pop(context);
      return;
    }

    final duration = DateTime.now().difference(_gameStartTime);
    final avgReactionTime = _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length;

    // Calcular puntuación: base menos penalización por tiempo promedio
    final baseScore = 1000;
    final timePenalty = (avgReactionTime * 0.5).round();
    final score = max(0, baseScore - timePenalty);

    // Calcular recompensas base y bonificaciones
    int xpEarned = 40;
    int coinsEarned = 12;

    // Bonificaciones por velocidad de reacción promedio
    if (avgReactionTime < 300) {
      xpEarned += 50;
      coinsEarned += 25;
    } else if (avgReactionTime < 400) {
      xpEarned += 35;
      coinsEarned += 18;
    } else if (avgReactionTime < 500) {
      xpEarned += 20;
      coinsEarned += 10;
    }

    // Bonificación por completar todas las rondas sin fallar
    final successfulRounds = _reactionTimes.length;
    if (successfulRounds == _totalRounds) {
      xpEarned += 30;
      coinsEarned += 15;
    }

    final result = GameResult(
      gameType: MiniGameType.reactionRace,
      won: true,
      score: score,
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
      duration: duration,
    );

    _showVictoryDialog(result, avgReactionTime);
  }

  void _showVictoryDialog(GameResult result, double avgReactionTime) {
    final successfulRounds = _reactionTimes.length;
    final bestTime = _reactionTimes.isEmpty ? 0 : _reactionTimes.reduce(min);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 32)),
            SizedBox(width: 8),
            Text('¡Terminado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Has completado el Reaction Race!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Rondas exitosas', '$successfulRounds/$_totalRounds'),
            _buildStatRow('Mejor tiempo', '${bestTime}ms'),
            _buildStatRow('Promedio', '${avgReactionTime.round()}ms'),
            _buildStatRow('Puntuación', result.score.toString()),
            const Divider(),
            _buildStatRow('XP Ganado', '+${result.xpEarned}', Colors.green),
            _buildStatRow('Monedas', '+${result.coinsEarned} 🪙', Colors.amber),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentRound = 0;
                _reactionTimes.clear();
                _gameStartTime = DateTime.now();
                _gameState = GameState.waiting;
              });
            },
            child: const Text('Jugar de nuevo'),
          ),
          FilledButton(
            onPressed: () {
              final updatedPet = widget.pet.copyWith(
                experience: widget.pet.experience + result.xpEarned,
                coins: widget.pet.coins + result.coinsEarned,
              );
              Navigator.pop(context);
              widget.onGameComplete(updatedPet, result);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Race'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _changeTimer?.cancel();
                _currentRound = 0;
                _reactionTimes.clear();
                _gameStartTime = DateTime.now();
                _gameState = GameState.waiting;
              });
            },
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Instrucciones
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Presiona cuando el círculo cambie a VERDE',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progreso
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Ronda ${_currentRound + 1} de $_totalRounds',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _currentRound / _totalRounds,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Área de juego
              Expanded(
                child: Center(
                  child: _buildGameArea(),
                ),
              ),

              // Tiempos de reacción
              if (_reactionTimes.isNotEmpty) _buildReactionTimesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    if (_currentRound == 0 && _gameState == GameState.waiting && !_tooEarly) {
      // Pantalla inicial
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Presiona "Empezar" para iniciar',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _startRound,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Empezar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      );
    }

    Color circleColor;
    String message;

    if (_tooEarly) {
      circleColor = Colors.red;
      message = '¡Muy temprano!';
    } else if (_gameState == GameState.waiting) {
      circleColor = Colors.orange;
      message = 'Espera...';
    } else if (_gameState == GameState.react) {
      circleColor = Colors.green;
      message = '¡AHORA!';
    } else {
      // GameState.result
      final lastTime = _reactionTimes.isNotEmpty ? _reactionTimes.last : 0;
      circleColor = Colors.blue;
      message = '$lastTime ms';
    }

    return GestureDetector(
      onTap: _onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: circleColor.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            message,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: circleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionTimesList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiempos de reacción:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reactionTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                final color = time < 300
                    ? Colors.green
                    : time < 500
                        ? Colors.orange
                        : Colors.red;

                return Chip(
                  label: Text(
                    '#${index + 1}: ${time}ms',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: color.withAlpha(30),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estados posibles del juego de reacción
enum GameState {
  /// Esperando que el círculo cambie a verde
  waiting,

  /// El círculo está verde, esperando reacción del jugador
  react,

  /// Mostrando resultado de la ronda actual
  result,
}
