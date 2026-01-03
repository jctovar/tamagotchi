import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../models/minigame_stats.dart';
import '../../services/feedback_service.dart';
import '../../providers/minigames_provider.dart';

/// Pantalla del juego Sliding Puzzle (rompecabezas deslizante) - Refactorizada con Riverpod
///
/// Implementa el clásico puzzle de 8 fichas donde el jugador debe ordenar
/// los números del 1 al 8 deslizando las fichas hacia el espacio vacío.
/// Las recompensas dependen del número de movimientos y tiempo empleado.
/// Sincronización automática con providers - sin callbacks manuales.
class SlidingPuzzleScreen extends ConsumerStatefulWidget {
  const SlidingPuzzleScreen({super.key});

  @override
  ConsumerState<SlidingPuzzleScreen> createState() => _SlidingPuzzleScreenState();
}

class _SlidingPuzzleScreenState extends ConsumerState<SlidingPuzzleScreen> {
  late List<int> _tiles;
  int _emptyIndex = 8; // Índice del espacio vacío
  int _moves = 0;
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
      await FlameAudio.bgm.play('Relax.wav', volume: 0.3);
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
  /// Genera un puzzle mezclado pero siempre resoluble realizando
  /// movimientos aleatorios válidos desde el estado resuelto.
  void _initGame() {
    // Crear puzzle en estado resuelto (0-8)
    _tiles = List.generate(9, (index) => index);

    // Mezclar haciendo movimientos aleatorios válidos (garantiza que sea resoluble)
    final random = Random();
    for (int i = 0; i < 100; i++) {
      final validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        final randomMove = validMoves[random.nextInt(validMoves.length)];
        _swapTiles(randomMove, _emptyIndex);
      }
    }

    _moves = 0;
    _startTime = DateTime.now();
    _elapsedSeconds = 0;

    // Iniciar timer
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  /// Obtiene las fichas que pueden moverse al espacio vacío
  ///
  /// Retorna una lista con los índices de las fichas adyacentes
  /// al espacio vacío (arriba, abajo, izquierda, derecha).
  List<int> _getValidMoves() {
    final validMoves = <int>[];
    final row = _emptyIndex ~/ 3;
    final col = _emptyIndex % 3;

    // Verificar cada dirección y agregar si está dentro del tablero
    if (row > 0) validMoves.add(_emptyIndex - 3); // Arriba
    if (row < 2) validMoves.add(_emptyIndex + 3); // Abajo
    if (col > 0) validMoves.add(_emptyIndex - 1); // Izquierda
    if (col < 2) validMoves.add(_emptyIndex + 1); // Derecha

    return validMoves;
  }

  void _swapTiles(int index1, int index2) {
    final temp = _tiles[index1];
    _tiles[index1] = _tiles[index2];
    _tiles[index2] = temp;
    _emptyIndex = index1;
  }

  /// Maneja el evento de tocar una ficha
  ///
  /// [index] Índice de la ficha tocada en el grid (0-8)
  /// Solo permite el movimiento si la ficha es adyacente al espacio vacío.
  void _onTileTap(int index) {
    // Verificar que la ficha sea movible (adyacente al espacio vacío)
    if (!_getValidMoves().contains(index)) return;

    FeedbackService.playHaptic(FeedbackType.play);

    setState(() {
      _swapTiles(index, _emptyIndex);
      _moves++;
    });

    // Verificar si ganó
    if (_isPuzzleSolved()) {
      _onGameWon();
    }
  }

  /// Verifica si el puzzle está resuelto
  ///
  /// Retorna true si todas las fichas están en su posición correcta (0-8 en orden).
  bool _isPuzzleSolved() {
    for (int i = 0; i < 9; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  /// Procesa la victoria del juego
  ///
  /// Calcula la puntuación final basada en movimientos y tiempo,
  /// determina las recompensas de XP y monedas, y muestra el diálogo de victoria.
  void _onGameWon() {
    _gameTimer?.cancel();
    final duration = DateTime.now().difference(_startTime);

    FeedbackService.playHaptic(FeedbackType.feed);

    // Calcular puntuación: base menos penalizaciones por movimientos y tiempo
    final baseScore = 1000;
    final movePenalty = _moves * 5;
    final timePenalty = _elapsedSeconds * 3;
    final score = max(0, baseScore - movePenalty - timePenalty);

    // Calcular recompensas base y bonificaciones
    int xpEarned = 60;
    int coinsEarned = 15;

    // Bonificaciones por eficiencia en movimientos
    if (_moves <= 50) {
      xpEarned += 40;
      coinsEarned += 20;
    } else if (_moves <= 100) {
      xpEarned += 25;
      coinsEarned += 12;
    } else if (_moves <= 150) {
      xpEarned += 15;
      coinsEarned += 8;
    }

    // Bonificación por velocidad (completar en menos de 2 minutos)
    if (_elapsedSeconds <= 120) {
      xpEarned += 25;
      coinsEarned += 10;
    }

    final result = GameResult(
      gameType: MiniGameType.slidingPuzzle,
      won: true,
      score: score,
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
      duration: duration,
    );

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
            const Text(
              '¡Has resuelto el puzzle!',
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
            onPressed: () async {
              // Actualizar estadísticas y recompensas automáticamente vía provider
              await ref.read(miniGameStatsStateProvider.notifier).updateStats(result);

              // Navegar de vuelta y mostrar mensaje
              if (mounted) {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver al menú

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
        title: const Text('Sliding Puzzle'),
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
              // Instrucciones
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Ordena los números del 1 al 8',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Estadísticas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Movimientos', _moves.toString()),
                      _buildStat('Tiempo', '${_elapsedSeconds}s'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Puzzle Grid
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return _buildTile(index);
                      },
                    ),
                  ),
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

  Widget _buildTile(int index) {
    final tileValue = _tiles[index];
    final isEmpty = tileValue == 0;
    final canMove = _getValidMoves().contains(index);

    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: isEmpty
              ? Colors.grey[200]
              : canMove
                  ? Colors.blue[400]
                  : Colors.blue[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty ? Colors.grey[300]! : Colors.blue[700]!,
            width: 2,
          ),
          boxShadow: isEmpty
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: isEmpty
              ? null
              : Text(
                  tileValue.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
