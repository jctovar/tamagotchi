import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/minigame_stats.dart';

/// Tests para la lógica core de MiniGameStats
///
/// NOTA: Los tests completos del provider con Riverpod requieren mock de Firebase Analytics.
/// Estos tests se enfocan en la lógica del modelo MiniGameStats que es utilizada por el provider.
/// Para tests de integración completos con Firebase, ver integration tests.

void main() {
  group('GameStats Model', () {
    test('GameStats se crea con valores por defecto correctos', () {
      // Act
      final stats = GameStats(gameType: MiniGameType.memory);

      // Assert
      expect(stats.gameType, MiniGameType.memory);
      expect(stats.timesPlayed, 0);
      expect(stats.timesWon, 0);
      expect(stats.bestScore, 0);
      expect(stats.totalXpEarned, 0);
      expect(stats.totalCoinsEarned, 0);
    });

    test('winRate calcula el porcentaje correctamente', () {
      // Arrange & Act
      final noGames = GameStats(gameType: MiniGameType.memory);
      final allWins = GameStats(
        gameType: MiniGameType.memory,
        timesPlayed: 10,
        timesWon: 10,
      );
      final halfWins = GameStats(
        gameType: MiniGameType.memory,
        timesPlayed: 20,
        timesWon: 10,
      );
      final noWins = GameStats(
        gameType: MiniGameType.memory,
        timesPlayed: 5,
        timesWon: 0,
      );

      // Assert
      expect(noGames.winRate, 0.0); // 0 partidas = 0%
      expect(allWins.winRate, 100.0); // 10/10 = 100%
      expect(halfWins.winRate, 50.0); // 10/20 = 50%
      expect(noWins.winRate, 0.0); // 0/5 = 0%
    });

    test('copyWith actualiza correctamente los campos', () {
      // Arrange
      final original = GameStats(
        gameType: MiniGameType.slidingPuzzle,
        timesPlayed: 5,
        timesWon: 3,
        bestScore: 1000,
        totalXpEarned: 150,
        totalCoinsEarned: 50,
      );

      // Act
      final updated = original.copyWith(
        timesPlayed: 6,
        timesWon: 4,
        bestScore: 1200,
      );

      // Assert
      expect(updated.gameType, MiniGameType.slidingPuzzle); // No cambia
      expect(updated.timesPlayed, 6); // Actualizado
      expect(updated.timesWon, 4); // Actualizado
      expect(updated.bestScore, 1200); // Actualizado
      expect(updated.totalXpEarned, 150); // No cambia
      expect(updated.totalCoinsEarned, 50); // No cambia
    });

    test('toJson serializa correctamente', () {
      // Arrange
      final stats = GameStats(
        gameType: MiniGameType.reactionRace,
        timesPlayed: 10,
        timesWon: 8,
        bestScore: 950,
        totalXpEarned: 400,
        totalCoinsEarned: 120,
      );

      // Act
      final json = stats.toJson();

      // Assert
      expect(json['gameType'], MiniGameType.reactionRace.index);
      expect(json['timesPlayed'], 10);
      expect(json['timesWon'], 8);
      expect(json['bestScore'], 950);
      expect(json['totalXpEarned'], 400);
      expect(json['totalCoinsEarned'], 120);
    });

    test('fromJson deserializa correctamente', () {
      // Arrange
      final json = {
        'gameType': MiniGameType.memory.index,
        'timesPlayed': 15,
        'timesWon': 12,
        'bestScore': 850,
        'totalXpEarned': 600,
        'totalCoinsEarned': 180,
      };

      // Act
      final stats = GameStats.fromJson(json);

      // Assert
      expect(stats.gameType, MiniGameType.memory);
      expect(stats.timesPlayed, 15);
      expect(stats.timesWon, 12);
      expect(stats.bestScore, 850);
      expect(stats.totalXpEarned, 600);
      expect(stats.totalCoinsEarned, 180);
    });

    test('fromJson usa valores por defecto para campos faltantes', () {
      // Arrange
      final json = {
        'gameType': MiniGameType.slidingPuzzle.index,
      };

      // Act
      final stats = GameStats.fromJson(json);

      // Assert
      expect(stats.gameType, MiniGameType.slidingPuzzle);
      expect(stats.timesPlayed, 0);
      expect(stats.timesWon, 0);
      expect(stats.bestScore, 0);
      expect(stats.totalXpEarned, 0);
      expect(stats.totalCoinsEarned, 0);
    });
  });

  group('MiniGameStats Model', () {
    test('MiniGameStats se crea con estadísticas vacías para todos los juegos', () {
      // Act
      final allStats = MiniGameStats();

      // Assert
      expect(allStats.stats.length, MiniGameType.values.length);
      expect(allStats.stats.containsKey(MiniGameType.memory), true);
      expect(allStats.stats.containsKey(MiniGameType.slidingPuzzle), true);
      expect(allStats.stats.containsKey(MiniGameType.reactionRace), true);

      // Todas las estadísticas deben estar vacías inicialmente
      for (final gameType in MiniGameType.values) {
        final stats = allStats.getStats(gameType);
        expect(stats.timesPlayed, 0);
        expect(stats.timesWon, 0);
        expect(stats.bestScore, 0);
      }
    });

    test('getStats retorna estadísticas correctas para cada tipo de juego', () {
      // Arrange
      final memoryStats = GameStats(
        gameType: MiniGameType.memory,
        timesPlayed: 10,
        timesWon: 8,
      );
      final puzzleStats = GameStats(
        gameType: MiniGameType.slidingPuzzle,
        timesPlayed: 5,
        timesWon: 3,
      );

      final allStats = MiniGameStats(stats: {
        MiniGameType.memory: memoryStats,
        MiniGameType.slidingPuzzle: puzzleStats,
      });

      // Act & Assert
      expect(allStats.getStats(MiniGameType.memory).timesPlayed, 10);
      expect(allStats.getStats(MiniGameType.memory).timesWon, 8);
      expect(allStats.getStats(MiniGameType.slidingPuzzle).timesPlayed, 5);
      expect(allStats.getStats(MiniGameType.slidingPuzzle).timesWon, 3);
    });

    test('getStats retorna estadísticas vacías para juego no existente', () {
      // Arrange
      final allStats = MiniGameStats(stats: {});

      // Act
      final stats = allStats.getStats(MiniGameType.memory);

      // Assert
      expect(stats.gameType, MiniGameType.memory);
      expect(stats.timesPlayed, 0);
      expect(stats.timesWon, 0);
    });

    test('updateGameStats actualiza correctamente las estadísticas', () {
      // Arrange
      final allStats = MiniGameStats();
      final newMemoryStats = GameStats(
        gameType: MiniGameType.memory,
        timesPlayed: 5,
        timesWon: 4,
        bestScore: 800,
      );

      // Act
      final updated = allStats.updateGameStats(MiniGameType.memory, newMemoryStats);

      // Assert
      expect(updated.getStats(MiniGameType.memory).timesPlayed, 5);
      expect(updated.getStats(MiniGameType.memory).timesWon, 4);
      expect(updated.getStats(MiniGameType.memory).bestScore, 800);

      // Verificar que las otras estadísticas no cambiaron
      expect(updated.getStats(MiniGameType.slidingPuzzle).timesPlayed, 0);
      expect(updated.getStats(MiniGameType.reactionRace).timesPlayed, 0);
    });

    test('totalGamesPlayed calcula suma correcta', () {
      // Arrange
      final allStats = MiniGameStats(stats: {
        MiniGameType.memory: GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
        ),
        MiniGameType.slidingPuzzle: GameStats(
          gameType: MiniGameType.slidingPuzzle,
          timesPlayed: 5,
        ),
        MiniGameType.reactionRace: GameStats(
          gameType: MiniGameType.reactionRace,
          timesPlayed: 8,
        ),
      });

      // Act & Assert
      expect(allStats.totalGamesPlayed, 23); // 10 + 5 + 8
    });

    test('totalWins calcula suma correcta', () {
      // Arrange
      final allStats = MiniGameStats(stats: {
        MiniGameType.memory: GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
          timesWon: 8,
        ),
        MiniGameType.slidingPuzzle: GameStats(
          gameType: MiniGameType.slidingPuzzle,
          timesPlayed: 5,
          timesWon: 3,
        ),
        MiniGameType.reactionRace: GameStats(
          gameType: MiniGameType.reactionRace,
          timesPlayed: 8,
          timesWon: 7,
        ),
      });

      // Act & Assert
      expect(allStats.totalWins, 18); // 8 + 3 + 7
    });

    test('totalXpEarned calcula suma correcta', () {
      // Arrange
      final allStats = MiniGameStats(stats: {
        MiniGameType.memory: GameStats(
          gameType: MiniGameType.memory,
          totalXpEarned: 200,
        ),
        MiniGameType.slidingPuzzle: GameStats(
          gameType: MiniGameType.slidingPuzzle,
          totalXpEarned: 150,
        ),
        MiniGameType.reactionRace: GameStats(
          gameType: MiniGameType.reactionRace,
          totalXpEarned: 300,
        ),
      });

      // Act & Assert
      expect(allStats.totalXpEarned, 650); // 200 + 150 + 300
    });

    test('totalCoinsEarned calcula suma correcta', () {
      // Arrange
      final allStats = MiniGameStats(stats: {
        MiniGameType.memory: GameStats(
          gameType: MiniGameType.memory,
          totalCoinsEarned: 50,
        ),
        MiniGameType.slidingPuzzle: GameStats(
          gameType: MiniGameType.slidingPuzzle,
          totalCoinsEarned: 40,
        ),
        MiniGameType.reactionRace: GameStats(
          gameType: MiniGameType.reactionRace,
          totalCoinsEarned: 60,
        ),
      });

      // Act & Assert
      expect(allStats.totalCoinsEarned, 150); // 50 + 40 + 60
    });

    test('toJson serializa todas las estadísticas correctamente', () {
      // Arrange
      final allStats = MiniGameStats(stats: {
        MiniGameType.memory: GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
          timesWon: 8,
        ),
        MiniGameType.slidingPuzzle: GameStats(
          gameType: MiniGameType.slidingPuzzle,
          timesPlayed: 5,
          timesWon: 3,
        ),
      });

      // Act
      final json = allStats.toJson();

      // Assert
      expect(json.containsKey('stats'), true);
      final statsMap = json['stats'] as Map<String, dynamic>;
      expect(statsMap.containsKey(MiniGameType.memory.index.toString()), true);
      expect(statsMap.containsKey(MiniGameType.slidingPuzzle.index.toString()), true);
    });

    test('fromJson deserializa todas las estadísticas correctamente', () {
      // Arrange
      final json = {
        'stats': {
          '${MiniGameType.memory.index}': {
            'gameType': MiniGameType.memory.index,
            'timesPlayed': 10,
            'timesWon': 8,
            'bestScore': 900,
            'totalXpEarned': 200,
            'totalCoinsEarned': 50,
          },
          '${MiniGameType.slidingPuzzle.index}': {
            'gameType': MiniGameType.slidingPuzzle.index,
            'timesPlayed': 5,
            'timesWon': 3,
            'bestScore': 800,
            'totalXpEarned': 100,
            'totalCoinsEarned': 30,
          },
        }
      };

      // Act
      final allStats = MiniGameStats.fromJson(json);

      // Assert
      expect(allStats.getStats(MiniGameType.memory).timesPlayed, 10);
      expect(allStats.getStats(MiniGameType.memory).timesWon, 8);
      expect(allStats.getStats(MiniGameType.memory).bestScore, 900);
      expect(allStats.getStats(MiniGameType.slidingPuzzle).timesPlayed, 5);
      expect(allStats.getStats(MiniGameType.slidingPuzzle).timesWon, 3);
      expect(allStats.getStats(MiniGameType.slidingPuzzle).bestScore, 800);
    });

    test('fromJson crea estadísticas vacías para juegos faltantes', () {
      // Arrange - JSON solo con Memory, falta SlidingPuzzle y ReactionRace
      final json = {
        'stats': {
          '${MiniGameType.memory.index}': {
            'gameType': MiniGameType.memory.index,
            'timesPlayed': 10,
            'timesWon': 8,
          },
        }
      };

      // Act
      final allStats = MiniGameStats.fromJson(json);

      // Assert - Memory tiene datos
      expect(allStats.getStats(MiniGameType.memory).timesPlayed, 10);

      // Assert - Los otros juegos tienen estadísticas vacías
      expect(allStats.getStats(MiniGameType.slidingPuzzle).timesPlayed, 0);
      expect(allStats.getStats(MiniGameType.reactionRace).timesPlayed, 0);
    });

    test('fromJson con datos null crea estadísticas vacías', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final allStats = MiniGameStats.fromJson(json);

      // Assert - Todos los juegos deben tener estadísticas vacías
      for (final gameType in MiniGameType.values) {
        final stats = allStats.getStats(gameType);
        expect(stats.timesPlayed, 0);
        expect(stats.timesWon, 0);
        expect(stats.bestScore, 0);
        expect(stats.totalXpEarned, 0);
        expect(stats.totalCoinsEarned, 0);
      }
    });
  });

  group('GameResult Model', () {
    test('GameResult se crea con todos los campos requeridos', () {
      // Arrange & Act
      final result = GameResult(
        gameType: MiniGameType.memory,
        won: true,
        score: 850,
        xpEarned: 50,
        coinsEarned: 15,
        duration: const Duration(seconds: 45),
      );

      // Assert
      expect(result.gameType, MiniGameType.memory);
      expect(result.won, true);
      expect(result.score, 850);
      expect(result.xpEarned, 50);
      expect(result.coinsEarned, 15);
      expect(result.duration, const Duration(seconds: 45));
    });

    test('GameResult puede representar victoria y derrota', () {
      // Act
      final victory = GameResult(
        gameType: MiniGameType.slidingPuzzle,
        won: true,
        score: 1000,
        xpEarned: 60,
        coinsEarned: 20,
        duration: const Duration(minutes: 2),
      );

      final defeat = GameResult(
        gameType: MiniGameType.reactionRace,
        won: false,
        score: 0,
        xpEarned: 0,
        coinsEarned: 0,
        duration: const Duration(seconds: 30),
      );

      // Assert
      expect(victory.won, true);
      expect(defeat.won, false);
    });
  });

  group('MiniGameType Extension', () {
    test('displayName retorna nombres correctos', () {
      expect(MiniGameType.memory.displayName, 'Memory');
      expect(MiniGameType.slidingPuzzle.displayName, 'Puzzle Deslizante');
      expect(MiniGameType.reactionRace.displayName, 'Carrera de Reacción');
    });

    test('description retorna descripciones correctas', () {
      expect(MiniGameType.memory.description, 'Encuentra las parejas de emojis');
      expect(MiniGameType.slidingPuzzle.description, 'Ordena los números del 1 al 8');
      expect(MiniGameType.reactionRace.description, 'Presiona cuando cambie el color');
    });

    test('icon retorna emojis correctos', () {
      expect(MiniGameType.memory.icon, '🧠');
      expect(MiniGameType.slidingPuzzle.icon, '🧩');
      expect(MiniGameType.reactionRace.icon, '⚡');
    });

    test('colorValue retorna valores de color válidos', () {
      expect(MiniGameType.memory.colorValue, 0xFF9C27B0);
      expect(MiniGameType.slidingPuzzle.colorValue, 0xFF2196F3);
      expect(MiniGameType.reactionRace.colorValue, 0xFFFF9800);
    });
  });
}
