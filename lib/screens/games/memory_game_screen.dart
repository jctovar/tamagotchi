import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../models/pet.dart';
import '../../models/minigame_stats.dart';
import '../../services/feedback_service.dart';

/// Pantalla del juego Memory (parejas de emojis)
///
/// Implementa el clásico juego de memoria donde el jugador debe encontrar
/// pares de cartas iguales. Las recompensas se calculan basándose en la
/// cantidad de movimientos y el tiempo empleado.
class MemoryGameScreen extends StatefulWidget {
  /// Mascota actual del jugador
  final Pet pet;

  /// Callback ejecutado al completar el juego con la mascota actualizada y resultados
  final Function(Pet updatedPet, GameResult result) onGameComplete;

  const MemoryGameScreen({
    super.key,
    required this.pet,
    required this.onGameComplete,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  static const List<String> _emojis = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
  ];

  late List<String> _cards;
  late List<bool> _revealed;
  late List<bool> _matched;
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isProcessing = false;
  int _moves = 0;
  int _pairs = 0;
  late DateTime _startTime;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
    _playBackgroundMusic();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _stopBackgroundMusic();
    super.dispose();
  }

  /// Reproduce música de fondo en loop
  void _playBackgroundMusic() async {
    try {
      await FlameAudio.bgm.play('Cool.wav', volume: 0.3);
    } catch (e) {
      debugPrint('Error al reproducir música de fondo: $e');
    }
  }

  /// Detiene la música de fondo
  void _stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  /// Inicializa o reinicia el juego
  ///
  /// Crea el tablero de cartas duplicando los emojis y mezclándolos,
  /// reinicia todos los contadores y el temporizador.
  void _initGame() {
    // Duplicar emojis para crear pares y mezclar
    _cards = [..._emojis, ..._emojis];
    _cards.shuffle(Random());

    // Reiniciar estados de revelado y emparejamiento
    _revealed = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstCardIndex = null;
    _secondCardIndex = null;
    _isProcessing = false;
    _moves = 0;
    _pairs = 0;
    _startTime = DateTime.now();
    _elapsedSeconds = 0;

    // Iniciar timer
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  /// Maneja el evento de tocar una carta
  ///
  /// [index] Índice de la carta en el grid (0-15)
  /// Implementa la lógica del juego: revelar cartas, verificar parejas
  /// y detectar la victoria.
  void _onCardTap(int index) {
    // Ignorar toques en cartas ya reveladas, emparejadas o mientras se procesa
    if (_revealed[index] || _matched[index] || _isProcessing) return;

    setState(() {
      _revealed[index] = true;
    });

    FeedbackService.playHaptic(FeedbackType.play);

    if (_firstCardIndex == null) {
      // Primera carta seleccionada
      _firstCardIndex = index;
    } else if (_secondCardIndex == null) {
      // Segunda carta seleccionada
      _secondCardIndex = index;
      _moves++;
      _isProcessing = true;

      // Verificar si las dos cartas forman una pareja
      if (_cards[_firstCardIndex!] == _cards[_secondCardIndex!]) {
        // Pareja encontrada: marcar como emparejadas y aumentar contador
        FeedbackService.playHaptic(FeedbackType.feed);
        setState(() {
          _matched[_firstCardIndex!] = true;
          _matched[_secondCardIndex!] = true;
          _pairs++;
        });
        _resetSelection();

        // Verificar si ganó
        if (_pairs == 8) {
          _onGameWon();
        }
      } else {
        // No es pareja, ocultar después de un delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _revealed[_firstCardIndex!] = false;
              _revealed[_secondCardIndex!] = false;
            });
            _resetSelection();
          }
        });
      }
    }
  }

  void _resetSelection() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _firstCardIndex = null;
          _secondCardIndex = null;
          _isProcessing = false;
        });
      }
    });
  }

  /// Procesa la victoria del juego
  ///
  /// Calcula la puntuación final basada en movimientos y tiempo,
  /// determina las recompensas de XP y monedas, y muestra el diálogo de victoria.
  void _onGameWon() {
    _gameTimer?.cancel();
    final duration = DateTime.now().difference(_startTime);

    // Calcular puntuación: base menos penalizaciones por movimientos y tiempo
    final baseScore = 1000;
    final movePenalty = _moves * 10;
    final timePenalty = _elapsedSeconds * 2;
    final score = max(0, baseScore - movePenalty - timePenalty);

    // Calcular recompensas base y bonificaciones
    int xpEarned = 50;
    int coinsEarned = 10;

    // Bonificaciones por eficiencia en movimientos
    if (_moves <= 12) {
      xpEarned += 30;
      coinsEarned += 15;
    } else if (_moves <= 16) {
      xpEarned += 20;
      coinsEarned += 10;
    } else if (_moves <= 20) {
      xpEarned += 10;
      coinsEarned += 5;
    }

    // Bonificación por velocidad (completar en menos de 1 minuto)
    if (_elapsedSeconds <= 60) {
      xpEarned += 20;
      coinsEarned += 10;
    }

    final result = GameResult(
      gameType: MiniGameType.memory,
      won: true,
      score: score,
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
      duration: duration,
    );

    // Mostrar diálogo de victoria
    _showVictoryDialog(result);
  }

  void _showVictoryDialog(GameResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 32)),
            SizedBox(width: 8),
            Text('¡Victoria!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Has completado el Memory!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Movimientos', _moves.toString()),
            _buildStatRow('Tiempo', '${_elapsedSeconds}s'),
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
                _initGame();
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
        title: const Text('Memory Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initGame();
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
              // Estadísticas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Movimientos', _moves.toString()),
                      _buildStat('Parejas', '$_pairs/8'),
                      _buildStat('Tiempo', '${_elapsedSeconds}s'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid de cartas
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    return _buildCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildCard(int index) {
    final isRevealed = _revealed[index] || _matched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _matched[index]
              ? Colors.green[100]
              : isRevealed
                  ? Colors.white
                  : Colors.purple[400],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _matched[index]
                ? Colors.green
                : isRevealed
                    ? Colors.purple
                    : Colors.purple[700]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isRevealed
              ? Text(
                  _cards[index],
                  style: const TextStyle(fontSize: 36),
                )
              : const Icon(
                  Icons.help_outline,
                  size: 36,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
