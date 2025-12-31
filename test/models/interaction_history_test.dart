import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/interaction_history.dart';

void main() {
  group('TimeOfDay', () {
    test('fromHour devuelve earlyMorning para horas 0-5', () {
      expect(TimeOfDay.fromHour(0), TimeOfDay.earlyMorning);
      expect(TimeOfDay.fromHour(3), TimeOfDay.earlyMorning);
      expect(TimeOfDay.fromHour(5), TimeOfDay.earlyMorning);
    });

    test('fromHour devuelve morning para horas 6-11', () {
      expect(TimeOfDay.fromHour(6), TimeOfDay.morning);
      expect(TimeOfDay.fromHour(9), TimeOfDay.morning);
      expect(TimeOfDay.fromHour(11), TimeOfDay.morning);
    });

    test('fromHour devuelve afternoon para horas 12-17', () {
      expect(TimeOfDay.fromHour(12), TimeOfDay.afternoon);
      expect(TimeOfDay.fromHour(15), TimeOfDay.afternoon);
      expect(TimeOfDay.fromHour(17), TimeOfDay.afternoon);
    });

    test('fromHour devuelve evening para horas 18-20', () {
      expect(TimeOfDay.fromHour(18), TimeOfDay.evening);
      expect(TimeOfDay.fromHour(19), TimeOfDay.evening);
      expect(TimeOfDay.fromHour(20), TimeOfDay.evening);
    });

    test('fromHour devuelve night para horas 21-23', () {
      expect(TimeOfDay.fromHour(21), TimeOfDay.night);
      expect(TimeOfDay.fromHour(22), TimeOfDay.night);
      expect(TimeOfDay.fromHour(23), TimeOfDay.night);
    });

    test('valores de enum tienen propiedades correctas', () {
      expect(TimeOfDay.earlyMorning.startHour, 0);
      expect(TimeOfDay.earlyMorning.endHour, 6);
      expect(TimeOfDay.morning.displayName, 'Mañana');
      expect(TimeOfDay.afternoon.emoji, '☀️');
    });
  });

  group('InteractionType', () {
    test('tiene id, displayName y emoji correctos', () {
      expect(InteractionType.feed.id, 'feed');
      expect(InteractionType.feed.displayName, 'Alimentar');
      expect(InteractionType.feed.emoji, '🍔');

      expect(InteractionType.play.id, 'play');
      expect(InteractionType.minigame.emoji, '🎯');
    });

    test('todos los tipos tienen valores únicos', () {
      final ids = InteractionType.values.map((t) => t.id).toSet();
      expect(ids.length, InteractionType.values.length);
    });
  });

  group('Interaction', () {
    test('constructor inicializa correctamente con timestamp proporcionado', () {
      final timestamp = DateTime(2024, 1, 15, 14, 30); // Lunes 15 de enero, 14:30
      final interaction = Interaction(
        type: InteractionType.feed,
        timestamp: timestamp,
        hungerBefore: 70.0,
        happinessBefore: 50.0,
        energyBefore: 60.0,
        healthBefore: 80.0,
      );

      expect(interaction.type, InteractionType.feed);
      expect(interaction.timestamp, timestamp);
      expect(interaction.hungerBefore, 70.0);
      expect(interaction.happinessBefore, 50.0);
      expect(interaction.energyBefore, 60.0);
      expect(interaction.healthBefore, 80.0);
      expect(interaction.timeOfDay, TimeOfDay.afternoon);
      expect(interaction.dayOfWeek, DateTime.monday);
    });

    test('factory now() crea interacción con timestamp actual', () {
      final before = DateTime.now();
      final interaction = Interaction.now(
        type: InteractionType.play,
        hungerBefore: 30.0,
        happinessBefore: 80.0,
        energyBefore: 70.0,
        healthBefore: 90.0,
      );
      final after = DateTime.now();

      expect(interaction.type, InteractionType.play);
      expect(interaction.timestamp.isAfter(before) || interaction.timestamp.isAtSameMomentAs(before), true);
      expect(interaction.timestamp.isBefore(after) || interaction.timestamp.isAtSameMomentAs(after), true);
    });

    test('metadata se guarda correctamente', () {
      final interaction = Interaction.now(
        type: InteractionType.minigame,
        hungerBefore: 50.0,
        happinessBefore: 60.0,
        energyBefore: 70.0,
        healthBefore: 80.0,
        metadata: {'game': 'memory', 'score': 100},
      );

      expect(interaction.metadata, isNotNull);
      expect(interaction.metadata!['game'], 'memory');
      expect(interaction.metadata!['score'], 100);
    });

    group('wasReactive', () {
      test('es true cuando hunger > 70', () {
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 75.0,
          happinessBefore: 60.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasReactive, true);
      });

      test('es true cuando happiness < 30', () {
        final interaction = Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0,
          happinessBefore: 25.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasReactive, true);
      });

      test('es true cuando energy < 30', () {
        final interaction = Interaction.now(
          type: InteractionType.rest,
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 25.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasReactive, true);
      });

      test('es true cuando health < 40', () {
        final interaction = Interaction.now(
          type: InteractionType.clean,
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 60.0,
          healthBefore: 35.0,
        );
        expect(interaction.wasReactive, true);
      });

      test('es false cuando todas las métricas están bien', () {
        final interaction = Interaction.now(
          type: InteractionType.play,
          hungerBefore: 50.0,
          happinessBefore: 60.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasReactive, false);
      });
    });

    group('wasProactive', () {
      test('es true cuando todas las condiciones se cumplen', () {
        final interaction = Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0,
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasProactive, true);
      });

      test('es false cuando hunger >= 50', () {
        final interaction = Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 50.0,
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasProactive, false);
      });

      test('es false cuando happiness <= 50', () {
        final interaction = Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0,
          happinessBefore: 50.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasProactive, false);
      });

      test('es false cuando energy <= 50', () {
        final interaction = Interaction.now(
          type: InteractionType.rest,
          hungerBefore: 40.0,
          happinessBefore: 70.0,
          energyBefore: 50.0,
          healthBefore: 80.0,
        );
        expect(interaction.wasProactive, false);
      });

      test('es false cuando health <= 60', () {
        final interaction = Interaction.now(
          type: InteractionType.clean,
          hungerBefore: 40.0,
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 60.0,
        );
        expect(interaction.wasProactive, false);
      });
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        final timestamp = DateTime(2024, 1, 15, 14, 30);
        final interaction = Interaction(
          type: InteractionType.feed,
          timestamp: timestamp,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
          metadata: {'key': 'value'},
        );

        final json = interaction.toJson();

        expect(json['type'], 'feed');
        expect(json['timestamp'], timestamp.toIso8601String());
        expect(json['hungerBefore'], 70.0);
        expect(json['happinessBefore'], 50.0);
        expect(json['energyBefore'], 60.0);
        expect(json['healthBefore'], 80.0);
        expect(json['metadata'], {'key': 'value'});
      });

      test('fromJson deserializa correctamente', () {
        final timestamp = DateTime(2024, 1, 15, 14, 30);
        final json = {
          'type': 'play',
          'timestamp': timestamp.toIso8601String(),
          'hungerBefore': 30.0,
          'happinessBefore': 80.0,
          'energyBefore': 70.0,
          'healthBefore': 90.0,
          'metadata': {'test': 123},
        };

        final interaction = Interaction.fromJson(json);

        expect(interaction.type, InteractionType.play);
        expect(interaction.timestamp, timestamp);
        expect(interaction.hungerBefore, 30.0);
        expect(interaction.happinessBefore, 80.0);
        expect(interaction.energyBefore, 70.0);
        expect(interaction.healthBefore, 90.0);
        expect(interaction.metadata, {'test': 123});
        expect(interaction.timeOfDay, TimeOfDay.afternoon);
        expect(interaction.dayOfWeek, DateTime.monday);
      });

      test('fromJson maneja tipo desconocido con valor por defecto', () {
        final json = {
          'type': 'unknown_type',
          'timestamp': DateTime.now().toIso8601String(),
          'hungerBefore': 50.0,
          'happinessBefore': 50.0,
          'energyBefore': 50.0,
          'healthBefore': 50.0,
        };

        final interaction = Interaction.fromJson(json);
        expect(interaction.type, InteractionType.appOpen);
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = Interaction.now(
          type: InteractionType.minigame,
          hungerBefore: 45.5,
          happinessBefore: 65.3,
          energyBefore: 75.8,
          healthBefore: 85.2,
          metadata: {'game': 'puzzle', 'score': 500},
        );

        final json = original.toJson();
        final restored = Interaction.fromJson(json);

        expect(restored.type, original.type);
        expect(restored.timestamp, original.timestamp);
        expect(restored.hungerBefore, original.hungerBefore);
        expect(restored.happinessBefore, original.happinessBefore);
        expect(restored.energyBefore, original.energyBefore);
        expect(restored.healthBefore, original.healthBefore);
        expect(restored.metadata, original.metadata);
      });
    });
  });

  group('InteractionHistory', () {
    test('constructor con lista vacía inicializa correctamente', () {
      final history = InteractionHistory();

      expect(history.interactions, isEmpty);
      expect(history.firstInteraction, isNull);
      expect(history.lastInteraction, isNull);
      expect(history.totalInteractions, 0);
      expect(history.interactionCounts.length, InteractionType.values.length);
      expect(history.timeOfDayDistribution.length, TimeOfDay.values.length);
      expect(history.dayOfWeekDistribution.length, 7);
    });

    test('constructor con interacciones inicializa fechas correctamente', () {
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: DateTime(2024, 1, 5, 15, 0),
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.firstInteraction, DateTime(2024, 1, 1, 10, 0));
      expect(history.lastInteraction, DateTime(2024, 1, 5, 15, 0));
    });

    test('_countByType cuenta correctamente todas las interacciones', () {
      final interactions = [
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 60.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.interactionCounts[InteractionType.feed], 2);
      expect(history.interactionCounts[InteractionType.play], 1);
      expect(history.interactionCounts[InteractionType.clean], 0);
    });

    test('_countByTimeOfDay cuenta correctamente', () {
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 8, 0), // morning
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: DateTime(2024, 1, 1, 9, 0), // morning
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
        Interaction(
          type: InteractionType.clean,
          timestamp: DateTime(2024, 1, 1, 15, 0), // afternoon
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 85.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.timeOfDayDistribution[TimeOfDay.morning], 2);
      expect(history.timeOfDayDistribution[TimeOfDay.afternoon], 1);
      expect(history.timeOfDayDistribution[TimeOfDay.night], 0);
    });

    test('_countByDayOfWeek cuenta correctamente', () {
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 10, 0), // Monday
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: DateTime(2024, 1, 2, 10, 0), // Tuesday
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
        Interaction(
          type: InteractionType.clean,
          timestamp: DateTime(2024, 1, 8, 10, 0), // Monday (next week)
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 85.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.dayOfWeekDistribution[DateTime.monday], 2);
      expect(history.dayOfWeekDistribution[DateTime.tuesday], 1);
      expect(history.dayOfWeekDistribution[DateTime.wednesday], 0);
    });

    test('daysActive calcula correctamente', () {
      final firstDate = DateTime.now().subtract(const Duration(days: 10));
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: firstDate,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      // daysActive debería ser días desde firstInteraction + 1
      expect(history.daysActive, greaterThanOrEqualTo(10));
    });

    test('daysActive es 0 cuando no hay interacciones', () {
      final history = InteractionHistory();
      expect(history.daysActive, 0);
    });

    test('averageInteractionsPerDay calcula correctamente', () {
      final firstDate = DateTime.now().subtract(const Duration(days: 4));
      final interactions = List.generate(
        10,
        (i) => Interaction(
          type: InteractionType.feed,
          timestamp: firstDate.add(Duration(hours: i)),
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
      );

      final history = InteractionHistory(interactions: interactions);

      // 10 interacciones / (4 días + 1) = 2 por día
      expect(history.averageInteractionsPerDay, closeTo(2.0, 0.1));
    });

    test('averageInteractionsPerDay es 0 cuando daysActive es 0', () {
      final history = InteractionHistory();
      expect(history.averageInteractionsPerDay, 0);
    });

    test('mostFrequentInteraction identifica correctamente', () {
      final interactions = [
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 65.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 60.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.mostFrequentInteraction, InteractionType.feed);
    });

    test('mostFrequentInteraction excluye appOpen y appClose', () {
      final interactions = [
        Interaction.now(
          type: InteractionType.appOpen,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.appOpen,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.appOpen,
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.mostFrequentInteraction, InteractionType.feed);
    });

    test('mostFrequentInteraction es null cuando no hay interacciones', () {
      final history = InteractionHistory();
      expect(history.mostFrequentInteraction, isNull);
    });

    test('mostActiveTimeOfDay identifica correctamente', () {
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: DateTime(2024, 1, 1, 8, 0),
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: DateTime(2024, 1, 1, 9, 0),
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
        Interaction(
          type: InteractionType.clean,
          timestamp: DateTime(2024, 1, 1, 10, 0),
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 85.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.mostActiveTimeOfDay, TimeOfDay.morning);
    });

    test('mostActiveTimeOfDay es null cuando no hay interacciones', () {
      final history = InteractionHistory();
      expect(history.mostActiveTimeOfDay, isNull);
    });

    test('proactiveRatio calcula correctamente', () {
      final interactions = [
        Interaction.now(
          type: InteractionType.play,
          hungerBefore: 30.0, // proactiva
          happinessBefore: 70.0,
          energyBefore: 70.0,
          healthBefore: 80.0,
        ),
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 80.0, // reactiva
          happinessBefore: 30.0,
          energyBefore: 30.0,
          healthBefore: 40.0,
        ),
        Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0, // proactiva
          happinessBefore: 60.0,
          energyBefore: 60.0,
          healthBefore: 70.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.proactiveRatio, closeTo(2 / 3, 0.01));
    });

    test('proactiveRatio es 0 cuando no hay interacciones', () {
      final history = InteractionHistory();
      expect(history.proactiveRatio, 0);
    });

    test('reactiveRatio calcula correctamente', () {
      final interactions = [
        Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 80.0, // reactiva
          happinessBefore: 30.0,
          energyBefore: 30.0,
          healthBefore: 40.0,
        ),
        Interaction.now(
          type: InteractionType.play,
          hungerBefore: 40.0, // proactiva
          happinessBefore: 60.0,
          energyBefore: 60.0,
          healthBefore: 70.0,
        ),
      ];

      final history = InteractionHistory(interactions: interactions);

      expect(history.reactiveRatio, closeTo(0.5, 0.01));
    });

    test('reactiveRatio es 0 cuando no hay interacciones', () {
      final history = InteractionHistory();
      expect(history.reactiveRatio, 0);
    });

    test('addInteraction agrega nueva interacción', () {
      final history = InteractionHistory();
      final interaction = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 70.0,
        happinessBefore: 50.0,
        energyBefore: 60.0,
        healthBefore: 80.0,
      );

      final newHistory = history.addInteraction(interaction);

      expect(newHistory.totalInteractions, 1);
      expect(newHistory.interactions.first, interaction);
    });

    test('addInteraction mantiene solo últimas 1000 interacciones', () {
      // Crear historial con 1000 interacciones
      final interactions = List.generate(
        1000,
        (i) => Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
      );
      final history = InteractionHistory(interactions: interactions);

      // Agregar una más
      final newInteraction = Interaction.now(
        type: InteractionType.play,
        hungerBefore: 40.0,
        happinessBefore: 60.0,
        energyBefore: 70.0,
        healthBefore: 90.0,
      );
      final newHistory = history.addInteraction(newInteraction);

      expect(newHistory.totalInteractions, 1000);
      expect(newHistory.interactions.last, newInteraction);
    });

    test('getLastInteractions devuelve últimas N interacciones', () {
      final interactions = List.generate(
        10,
        (i) => Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
      );
      final history = InteractionHistory(interactions: interactions);

      final last3 = history.getLastInteractions(3);

      expect(last3.length, 3);
      expect(last3, interactions.sublist(7));
    });

    test('getLastInteractions maneja cuando hay menos interacciones que N', () {
      final interactions = List.generate(
        2,
        (i) => Interaction.now(
          type: InteractionType.feed,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
      );
      final history = InteractionHistory(interactions: interactions);

      final last5 = history.getLastInteractions(5);

      expect(last5.length, 2);
    });

    test('getLastInteractions devuelve lista vacía cuando no hay interacciones', () {
      final history = InteractionHistory();
      expect(history.getLastInteractions(5), isEmpty);
    });

    test('getInteractionsLastHours devuelve interacciones recientes', () {
      final now = DateTime.now();
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: now.subtract(const Duration(hours: 1)),
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: now.subtract(const Duration(hours: 5)),
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
        Interaction(
          type: InteractionType.clean,
          timestamp: now.subtract(const Duration(hours: 2)),
          hungerBefore: 50.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 85.0,
        ),
      ];
      final history = InteractionHistory(interactions: interactions);

      final last3Hours = history.getInteractionsLastHours(3);

      expect(last3Hours.length, 2); // Solo las de hace 1 y 2 horas
    });

    test('todayInteractions devuelve solo interacciones de hoy', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final interactions = [
        Interaction(
          type: InteractionType.feed,
          timestamp: now,
          hungerBefore: 70.0,
          happinessBefore: 50.0,
          energyBefore: 60.0,
          healthBefore: 80.0,
        ),
        Interaction(
          type: InteractionType.play,
          timestamp: yesterday,
          hungerBefore: 40.0,
          happinessBefore: 60.0,
          energyBefore: 70.0,
          healthBefore: 90.0,
        ),
      ];
      final history = InteractionHistory(interactions: interactions);

      final today = history.todayInteractions;

      expect(today.length, 1);
      expect(today.first.type, InteractionType.feed);
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        final interactions = [
          Interaction.now(
            type: InteractionType.feed,
            hungerBefore: 70.0,
            happinessBefore: 50.0,
            energyBefore: 60.0,
            healthBefore: 80.0,
          ),
        ];
        final history = InteractionHistory(interactions: interactions);

        final json = history.toJson();

        expect(json['interactions'], isA<List>());
        expect(json['interactions'].length, 1);
      });

      test('fromJson deserializa correctamente', () {
        final json = {
          'interactions': [
            {
              'type': 'feed',
              'timestamp': DateTime.now().toIso8601String(),
              'hungerBefore': 70.0,
              'happinessBefore': 50.0,
              'energyBefore': 60.0,
              'healthBefore': 80.0,
            },
            {
              'type': 'play',
              'timestamp': DateTime.now().toIso8601String(),
              'hungerBefore': 40.0,
              'happinessBefore': 60.0,
              'energyBefore': 70.0,
              'healthBefore': 90.0,
            },
          ],
        };

        final history = InteractionHistory.fromJson(json);

        expect(history.totalInteractions, 2);
        expect(history.interactions[0].type, InteractionType.feed);
        expect(history.interactions[1].type, InteractionType.play);
      });

      test('fromJson maneja lista vacía', () {
        final json = {'interactions': []};
        final history = InteractionHistory.fromJson(json);

        expect(history.totalInteractions, 0);
        expect(history.interactions, isEmpty);
      });

      test('fromJson maneja json sin campo interactions', () {
        final json = <String, dynamic>{};
        final history = InteractionHistory.fromJson(json);

        expect(history.totalInteractions, 0);
        expect(history.interactions, isEmpty);
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = InteractionHistory(
          interactions: [
            Interaction.now(
              type: InteractionType.feed,
              hungerBefore: 70.0,
              happinessBefore: 50.0,
              energyBefore: 60.0,
              healthBefore: 80.0,
            ),
            Interaction.now(
              type: InteractionType.play,
              hungerBefore: 40.0,
              happinessBefore: 60.0,
              energyBefore: 70.0,
              healthBefore: 90.0,
            ),
          ],
        );

        final json = original.toJson();
        final restored = InteractionHistory.fromJson(json);

        expect(restored.totalInteractions, original.totalInteractions);
        expect(restored.interactions[0].type, original.interactions[0].type);
        expect(restored.interactions[1].type, original.interactions[1].type);
      });
    });
  });
}
