import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/minigame_stats.dart';

void main() {
  group('MiniGameType', () {
    test('tiene todos los tipos definidos', () {
      expect(MiniGameType.values.length, 3);
      expect(MiniGameType.values, contains(MiniGameType.memory));
      expect(MiniGameType.values, contains(MiniGameType.slidingPuzzle));
      expect(MiniGameType.values, contains(MiniGameType.reactionRace));
    });
  });

  group('MiniGameTypeExtension', () {
    test('displayName devuelve nombres correctos', () {
      expect(MiniGameType.memory.displayName, 'Memory');
      expect(MiniGameType.slidingPuzzle.displayName, 'Puzzle Deslizante');
      expect(MiniGameType.reactionRace.displayName, 'Carrera de Reacción');
    });

    test('description devuelve descripciones correctas', () {
      expect(MiniGameType.memory.description, 'Encuentra las parejas de emojis');
      expect(MiniGameType.slidingPuzzle.description, 'Ordena los números del 1 al 8');
      expect(MiniGameType.reactionRace.description, 'Presiona cuando cambie el color');
    });

    test('icon devuelve emojis correctos', () {
      expect(MiniGameType.memory.icon, '🧠');
      expect(MiniGameType.slidingPuzzle.icon, '🧩');
      expect(MiniGameType.reactionRace.icon, '⚡');
    });

    test('colorValue devuelve colores correctos', () {
      expect(MiniGameType.memory.colorValue, 0xFF9C27B0); // Púrpura
      expect(MiniGameType.slidingPuzzle.colorValue, 0xFF2196F3); // Azul
      expect(MiniGameType.reactionRace.colorValue, 0xFFFF9800); // Naranja
    });
  });

  group('GameStats', () {
    test('constructor inicializa con valores por defecto', () {
      final stats = GameStats(gameType: MiniGameType.memory);

      expect(stats.gameType, MiniGameType.memory);
      expect(stats.timesPlayed, 0);
      expect(stats.timesWon, 0);
      expect(stats.bestScore, 0);
      expect(stats.totalXpEarned, 0);
      expect(stats.totalCoinsEarned, 0);
    });

    test('constructor acepta valores personalizados', () {
      final stats = GameStats(
        gameType: MiniGameType.slidingPuzzle,
        timesPlayed: 10,
        timesWon: 7,
        bestScore: 500,
        totalXpEarned: 350,
        totalCoinsEarned: 100,
      );

      expect(stats.gameType, MiniGameType.slidingPuzzle);
      expect(stats.timesPlayed, 10);
      expect(stats.timesWon, 7);
      expect(stats.bestScore, 500);
      expect(stats.totalXpEarned, 350);
      expect(stats.totalCoinsEarned, 100);
    });

    group('winRate', () {
      test('devuelve 0 cuando no se ha jugado', () {
        final stats = GameStats(gameType: MiniGameType.memory);
        expect(stats.winRate, 0.0);
      });

      test('calcula porcentaje correctamente', () {
        final stats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
          timesWon: 7,
        );

        expect(stats.winRate, 70.0);
      });

      test('devuelve 100 cuando se ha ganado todo', () {
        final stats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 5,
          timesWon: 5,
        );

        expect(stats.winRate, 100.0);
      });

      test('devuelve 0 cuando no se ha ganado nada', () {
        final stats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 5,
          timesWon: 0,
        );

        expect(stats.winRate, 0.0);
      });

      test('calcula porcentaje decimal correctamente', () {
        final stats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 3,
          timesWon: 1,
        );

        expect(stats.winRate, closeTo(33.33, 0.01));
      });
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        final stats = GameStats(
          gameType: MiniGameType.slidingPuzzle,
          timesPlayed: 15,
          timesWon: 10,
          bestScore: 750,
          totalXpEarned: 500,
          totalCoinsEarned: 150,
        );

        final json = stats.toJson();

        expect(json['gameType'], MiniGameType.slidingPuzzle.index);
        expect(json['timesPlayed'], 15);
        expect(json['timesWon'], 10);
        expect(json['bestScore'], 750);
        expect(json['totalXpEarned'], 500);
        expect(json['totalCoinsEarned'], 150);
      });

      test('fromJson deserializa correctamente', () {
        final json = {
          'gameType': MiniGameType.memory.index,
          'timesPlayed': 20,
          'timesWon': 12,
          'bestScore': 1000,
          'totalXpEarned': 600,
          'totalCoinsEarned': 200,
        };

        final stats = GameStats.fromJson(json);

        expect(stats.gameType, MiniGameType.memory);
        expect(stats.timesPlayed, 20);
        expect(stats.timesWon, 12);
        expect(stats.bestScore, 1000);
        expect(stats.totalXpEarned, 600);
        expect(stats.totalCoinsEarned, 200);
      });

      test('fromJson usa valores por defecto para campos faltantes', () {
        final json = {
          'gameType': MiniGameType.reactionRace.index,
        };

        final stats = GameStats.fromJson(json);

        expect(stats.gameType, MiniGameType.reactionRace);
        expect(stats.timesPlayed, 0);
        expect(stats.timesWon, 0);
        expect(stats.bestScore, 0);
        expect(stats.totalXpEarned, 0);
        expect(stats.totalCoinsEarned, 0);
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = GameStats(
          gameType: MiniGameType.slidingPuzzle,
          timesPlayed: 25,
          timesWon: 15,
          bestScore: 999,
          totalXpEarned: 750,
          totalCoinsEarned: 250,
        );

        final json = original.toJson();
        final restored = GameStats.fromJson(json);

        expect(restored.gameType, original.gameType);
        expect(restored.timesPlayed, original.timesPlayed);
        expect(restored.timesWon, original.timesWon);
        expect(restored.bestScore, original.bestScore);
        expect(restored.totalXpEarned, original.totalXpEarned);
        expect(restored.totalCoinsEarned, original.totalCoinsEarned);
      });
    });

    group('copyWith', () {
      test('actualiza solo los campos proporcionados', () {
        final original = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
          bestScore: 500,
        );

        final updated = original.copyWith(
          timesPlayed: 11,
          timesWon: 5,
        );

        expect(updated.gameType, MiniGameType.memory);
        expect(updated.timesPlayed, 11);
        expect(updated.timesWon, 5);
        expect(updated.bestScore, 500); // No cambió
      });

      test('mantiene valores cuando no se proporcionan parámetros', () {
        final original = GameStats(
          gameType: MiniGameType.slidingPuzzle,
          timesPlayed: 20,
          timesWon: 15,
          bestScore: 1000,
        );

        final copy = original.copyWith();

        expect(copy.gameType, original.gameType);
        expect(copy.timesPlayed, original.timesPlayed);
        expect(copy.timesWon, original.timesWon);
        expect(copy.bestScore, original.bestScore);
      });

      test('no modifica gameType', () {
        final original = GameStats(gameType: MiniGameType.memory);
        final copy = original.copyWith(timesPlayed: 5);

        expect(copy.gameType, MiniGameType.memory);
      });
    });
  });

  group('MiniGameStats', () {
    test('constructor con valores por defecto inicializa todos los juegos', () {
      final stats = MiniGameStats();

      expect(stats.stats.length, MiniGameType.values.length);
      expect(stats.stats[MiniGameType.memory], isNotNull);
      expect(stats.stats[MiniGameType.slidingPuzzle], isNotNull);
      expect(stats.stats[MiniGameType.reactionRace], isNotNull);

      // Verificar que todos empiezan en 0
      expect(stats.stats[MiniGameType.memory]!.timesPlayed, 0);
      expect(stats.stats[MiniGameType.slidingPuzzle]!.timesPlayed, 0);
      expect(stats.stats[MiniGameType.reactionRace]!.timesPlayed, 0);
    });

    test('constructor acepta stats personalizados', () {
      final customStats = {
        MiniGameType.memory: GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
          timesWon: 5,
        ),
      };

      final stats = MiniGameStats(stats: customStats);

      expect(stats.stats[MiniGameType.memory]!.timesPlayed, 10);
      expect(stats.stats[MiniGameType.memory]!.timesWon, 5);
    });

    group('getters agregados', () {
      test('totalGamesPlayed suma todas las partidas', () {
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            timesPlayed: 10,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            timesPlayed: 15,
          ),
          MiniGameType.reactionRace: GameStats(
            gameType: MiniGameType.reactionRace,
            timesPlayed: 5,
          ),
        });

        expect(stats.totalGamesPlayed, 30);
      });

      test('totalGamesPlayed es 0 cuando no hay partidas', () {
        final stats = MiniGameStats();
        expect(stats.totalGamesPlayed, 0);
      });

      test('totalWins suma todas las victorias', () {
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            timesWon: 7,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            timesWon: 10,
          ),
          MiniGameType.reactionRace: GameStats(
            gameType: MiniGameType.reactionRace,
            timesWon: 3,
          ),
        });

        expect(stats.totalWins, 20);
      });

      test('totalWins es 0 cuando no hay victorias', () {
        final stats = MiniGameStats();
        expect(stats.totalWins, 0);
      });

      test('totalXpEarned suma toda la experiencia', () {
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            totalXpEarned: 100,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            totalXpEarned: 200,
          ),
          MiniGameType.reactionRace: GameStats(
            gameType: MiniGameType.reactionRace,
            totalXpEarned: 150,
          ),
        });

        expect(stats.totalXpEarned, 450);
      });

      test('totalXpEarned es 0 cuando no hay experiencia', () {
        final stats = MiniGameStats();
        expect(stats.totalXpEarned, 0);
      });

      test('totalCoinsEarned suma todas las monedas', () {
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            totalCoinsEarned: 50,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            totalCoinsEarned: 75,
          ),
          MiniGameType.reactionRace: GameStats(
            gameType: MiniGameType.reactionRace,
            totalCoinsEarned: 25,
          ),
        });

        expect(stats.totalCoinsEarned, 150);
      });

      test('totalCoinsEarned es 0 cuando no hay monedas', () {
        final stats = MiniGameStats();
        expect(stats.totalCoinsEarned, 0);
      });
    });

    group('getStats', () {
      test('devuelve estadísticas existentes', () {
        final memoryStats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 10,
        );
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: memoryStats,
        });

        final retrieved = stats.getStats(MiniGameType.memory);

        expect(retrieved, memoryStats);
        expect(retrieved.timesPlayed, 10);
      });

      test('devuelve nuevo GameStats si no existe', () {
        final stats = MiniGameStats(stats: {});

        final retrieved = stats.getStats(MiniGameType.slidingPuzzle);

        expect(retrieved, isNotNull);
        expect(retrieved.gameType, MiniGameType.slidingPuzzle);
        expect(retrieved.timesPlayed, 0);
      });
    });

    group('updateGameStats', () {
      test('actualiza estadísticas de un juego específico', () {
        final stats = MiniGameStats();

        final newMemoryStats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 5,
          timesWon: 3,
        );

        final updated = stats.updateGameStats(MiniGameType.memory, newMemoryStats);

        expect(updated.stats[MiniGameType.memory]!.timesPlayed, 5);
        expect(updated.stats[MiniGameType.memory]!.timesWon, 3);
      });

      test('no modifica las otras estadísticas', () {
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            timesPlayed: 10,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            timesPlayed: 15,
          ),
        });

        final newMemoryStats = GameStats(
          gameType: MiniGameType.memory,
          timesPlayed: 20,
        );

        final updated = stats.updateGameStats(MiniGameType.memory, newMemoryStats);

        expect(updated.stats[MiniGameType.memory]!.timesPlayed, 20);
        expect(updated.stats[MiniGameType.slidingPuzzle]!.timesPlayed, 15); // No cambió
      });

      test('devuelve nueva instancia de MiniGameStats', () {
        final stats = MiniGameStats();
        final newStats = GameStats(gameType: MiniGameType.memory, timesPlayed: 5);

        final updated = stats.updateGameStats(MiniGameType.memory, newStats);

        expect(updated, isNot(same(stats)));
      });
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        final stats = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            timesPlayed: 10,
            timesWon: 7,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            timesPlayed: 5,
            timesWon: 3,
          ),
          MiniGameType.reactionRace: GameStats(
            gameType: MiniGameType.reactionRace,
            timesPlayed: 8,
            timesWon: 6,
          ),
        });

        final json = stats.toJson();

        expect(json['stats'], isA<Map>());
        expect(json['stats']['0'], isNotNull); // memory index = 0
        expect(json['stats']['1'], isNotNull); // slidingPuzzle index = 1
        expect(json['stats']['2'], isNotNull); // reactionRace index = 2
      });

      test('fromJson deserializa correctamente', () {
        final json = {
          'stats': {
            '0': {
              'gameType': 0,
              'timesPlayed': 10,
              'timesWon': 7,
              'bestScore': 500,
              'totalXpEarned': 350,
              'totalCoinsEarned': 100,
            },
            '1': {
              'gameType': 1,
              'timesPlayed': 5,
              'timesWon': 3,
              'bestScore': 300,
              'totalXpEarned': 150,
              'totalCoinsEarned': 50,
            },
          },
        };

        final stats = MiniGameStats.fromJson(json);

        expect(stats.stats[MiniGameType.memory]!.timesPlayed, 10);
        expect(stats.stats[MiniGameType.memory]!.timesWon, 7);
        expect(stats.stats[MiniGameType.slidingPuzzle]!.timesPlayed, 5);
        expect(stats.stats[MiniGameType.slidingPuzzle]!.timesWon, 3);
      });

      test('fromJson asegura que todos los juegos tengan estadísticas', () {
        final json = {
          'stats': {
            '0': {
              'gameType': 0,
              'timesPlayed': 10,
            },
          },
        };

        final stats = MiniGameStats.fromJson(json);

        // Memory debería tener datos
        expect(stats.stats[MiniGameType.memory]!.timesPlayed, 10);

        // Los otros deberían tener valores por defecto
        expect(stats.stats[MiniGameType.slidingPuzzle], isNotNull);
        expect(stats.stats[MiniGameType.reactionRace], isNotNull);
        expect(stats.stats[MiniGameType.slidingPuzzle]!.timesPlayed, 0);
        expect(stats.stats[MiniGameType.reactionRace]!.timesPlayed, 0);
      });

      test('fromJson maneja json vacío', () {
        final json = <String, dynamic>{};
        final stats = MiniGameStats.fromJson(json);

        expect(stats.stats.length, MiniGameType.values.length);
        for (final gameType in MiniGameType.values) {
          expect(stats.stats[gameType], isNotNull);
          expect(stats.stats[gameType]!.timesPlayed, 0);
        }
      });

      test('fromJson maneja stats null', () {
        final json = {'stats': null};
        final stats = MiniGameStats.fromJson(json);

        expect(stats.stats.length, MiniGameType.values.length);
        for (final gameType in MiniGameType.values) {
          expect(stats.stats[gameType], isNotNull);
        }
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = MiniGameStats(stats: {
          MiniGameType.memory: GameStats(
            gameType: MiniGameType.memory,
            timesPlayed: 25,
            timesWon: 20,
            bestScore: 1500,
            totalXpEarned: 1000,
            totalCoinsEarned: 300,
          ),
          MiniGameType.slidingPuzzle: GameStats(
            gameType: MiniGameType.slidingPuzzle,
            timesPlayed: 15,
            timesWon: 10,
            bestScore: 800,
            totalXpEarned: 500,
            totalCoinsEarned: 150,
          ),
          MiniGameType.reactionRace: GameStats(
            gameType: MiniGameType.reactionRace,
            timesPlayed: 30,
            timesWon: 25,
            bestScore: 2000,
            totalXpEarned: 1500,
            totalCoinsEarned: 450,
          ),
        });

        final json = original.toJson();
        final restored = MiniGameStats.fromJson(json);

        expect(restored.totalGamesPlayed, original.totalGamesPlayed);
        expect(restored.totalWins, original.totalWins);
        expect(restored.totalXpEarned, original.totalXpEarned);
        expect(restored.totalCoinsEarned, original.totalCoinsEarned);

        for (final gameType in MiniGameType.values) {
          expect(
            restored.stats[gameType]!.timesPlayed,
            original.stats[gameType]!.timesPlayed,
          );
          expect(
            restored.stats[gameType]!.timesWon,
            original.stats[gameType]!.timesWon,
          );
          expect(
            restored.stats[gameType]!.bestScore,
            original.stats[gameType]!.bestScore,
          );
        }
      });
    });
  });

  group('GameResult', () {
    test('constructor inicializa correctamente', () {
      final result = GameResult(
        gameType: MiniGameType.memory,
        won: true,
        score: 500,
        xpEarned: 50,
        coinsEarned: 25,
        duration: const Duration(seconds: 30),
      );

      expect(result.gameType, MiniGameType.memory);
      expect(result.won, true);
      expect(result.score, 500);
      expect(result.xpEarned, 50);
      expect(result.coinsEarned, 25);
      expect(result.duration, const Duration(seconds: 30));
    });

    test('puede representar derrota', () {
      final result = GameResult(
        gameType: MiniGameType.slidingPuzzle,
        won: false,
        score: 100,
        xpEarned: 10,
        coinsEarned: 0,
        duration: const Duration(minutes: 2),
      );

      expect(result.won, false);
      expect(result.coinsEarned, 0);
    });
  });
}
