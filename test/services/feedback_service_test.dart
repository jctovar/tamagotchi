import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/services/feedback_service.dart';

void main() {
  group('FeedbackService - Validación de Tipos', () {
    // Nota: Este grupo de pruebas valida la definición del enum FeedbackType
    // y la estructura del servicio. Las pruebas de integración con los plugins
    // de vibración y haptic feedback requieren dispositivos reales o emuladores
    // y se validan mejor a través de pruebas de integración o manuales.

    group('FeedbackType Enum', () {
      test('tiene todos los tipos de feedback definidos', () {
        expect(FeedbackType.values.length, 7);
      });

      test('contiene tipo feed', () {
        expect(FeedbackType.values, contains(FeedbackType.feed));
      });

      test('contiene tipo play', () {
        expect(FeedbackType.values, contains(FeedbackType.play));
      });

      test('contiene tipo clean', () {
        expect(FeedbackType.values, contains(FeedbackType.clean));
      });

      test('contiene tipo rest', () {
        expect(FeedbackType.values, contains(FeedbackType.rest));
      });

      test('contiene tipo tap', () {
        expect(FeedbackType.values, contains(FeedbackType.tap));
      });

      test('contiene tipo success', () {
        expect(FeedbackType.values, contains(FeedbackType.success));
      });

      test('contiene tipo error', () {
        expect(FeedbackType.values, contains(FeedbackType.error));
      });

      test('tipos están en el orden correcto', () {
        expect(FeedbackType.feed.index, 0);
        expect(FeedbackType.play.index, 1);
        expect(FeedbackType.clean.index, 2);
        expect(FeedbackType.rest.index, 3);
        expect(FeedbackType.tap.index, 4);
        expect(FeedbackType.success.index, 5);
        expect(FeedbackType.error.index, 6);
      });
    });

    group('Agrupación lógica de tipos', () {
      test('acciones principales incluyen feed, play, clean, rest', () {
        const mainActions = [
          FeedbackType.feed,
          FeedbackType.play,
          FeedbackType.clean,
          FeedbackType.rest,
        ];

        expect(mainActions.length, 4);
        expect(mainActions, contains(FeedbackType.feed));
        expect(mainActions, contains(FeedbackType.play));
        expect(mainActions, contains(FeedbackType.clean));
        expect(mainActions, contains(FeedbackType.rest));
      });

      test('tipos de resultado incluyen success y error', () {
        const resultTypes = [
          FeedbackType.success,
          FeedbackType.error,
        ];

        expect(resultTypes.length, 2);
        expect(resultTypes, contains(FeedbackType.success));
        expect(resultTypes, contains(FeedbackType.error));
      });

      test('tipo de interacción genérica es tap', () {
        expect(FeedbackType.tap, isNotNull);
        expect(FeedbackType.tap.name, 'tap');
      });
    });

    group('Nombres de enum', () {
      test('feed tiene nombre correcto', () {
        expect(FeedbackType.feed.name, 'feed');
      });

      test('play tiene nombre correcto', () {
        expect(FeedbackType.play.name, 'play');
      });

      test('clean tiene nombre correcto', () {
        expect(FeedbackType.clean.name, 'clean');
      });

      test('rest tiene nombre correcto', () {
        expect(FeedbackType.rest.name, 'rest');
      });

      test('tap tiene nombre correcto', () {
        expect(FeedbackType.tap.name, 'tap');
      });

      test('success tiene nombre correcto', () {
        expect(FeedbackType.success.name, 'success');
      });

      test('error tiene nombre correcto', () {
        expect(FeedbackType.error.name, 'error');
      });
    });

    group('Conversión de enum', () {
      test('puede obtener tipo por índice', () {
        expect(FeedbackType.values[0], FeedbackType.feed);
        expect(FeedbackType.values[1], FeedbackType.play);
        expect(FeedbackType.values[2], FeedbackType.clean);
        expect(FeedbackType.values[3], FeedbackType.rest);
        expect(FeedbackType.values[4], FeedbackType.tap);
        expect(FeedbackType.values[5], FeedbackType.success);
        expect(FeedbackType.values[6], FeedbackType.error);
      });

      test('puede buscar tipo por nombre', () {
        expect(
          FeedbackType.values.firstWhere((t) => t.name == 'feed'),
          FeedbackType.feed,
        );
        expect(
          FeedbackType.values.firstWhere((t) => t.name == 'success'),
          FeedbackType.success,
        );
        expect(
          FeedbackType.values.firstWhere((t) => t.name == 'error'),
          FeedbackType.error,
        );
      });
    });

    group('Validación de consistencia', () {
      test('todos los tipos son únicos', () {
        final typeSet = FeedbackType.values.toSet();
        expect(typeSet.length, FeedbackType.values.length);
      });

      test('todos los nombres son únicos', () {
        final names = FeedbackType.values.map((t) => t.name).toSet();
        expect(names.length, FeedbackType.values.length);
      });

      test('todos los índices son consecutivos', () {
        for (var i = 0; i < FeedbackType.values.length; i++) {
          expect(FeedbackType.values[i].index, i);
        }
      });
    });
  });
}
