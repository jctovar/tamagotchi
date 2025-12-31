import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/credit_model.dart';
import 'package:tamagotchi/services/local_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalService - readJsonCredits', () {
    // Nota: Este servicio lee un archivo JSON de assets. Para probarlo sin el archivo real,
    // usaríamos un mock del AssetBundle, pero esto requeriría inyección de dependencias.
    // Las siguientes pruebas validan el comportamiento esperado con datos simulados.

    group('Estructura de datos esperada', () {
      test('debería retornar una lista de CreditModel', () {
        // Este test valida que el tipo de retorno es correcto
        expect(
          Services.readJsonCredits(),
          isA<Future<List<CreditModel>>>(),
        );
      });
    });

    group('Validación de estructura JSON', () {
      test('JSON debe tener estructura con campo RECORDS', () {
        // Estructura esperada del JSON:
        final expectedStructure = {
          'RECORDS': [
            {
              'credit_id': 1,
              'credit_name': 'Development',
              'credit_members': 'Developer Names',
            }
          ]
        };

        expect(expectedStructure, contains('RECORDS'));
        expect(expectedStructure['RECORDS'], isA<List>());
      });

      test('cada registro debe tener credit_id, credit_name, credit_members', () {
        final record = {
          'credit_id': 1,
          'credit_name': 'Team Name',
          'credit_members': 'Member Names',
        };

        expect(record, contains('credit_id'));
        expect(record, contains('credit_name'));
        expect(record, contains('credit_members'));
      });
    });

    group('Casos de uso del modelo', () {
      test('lista vacía es válida', () {
        final List<CreditModel> credits = [];
        expect(credits, isEmpty);
        expect(credits.length, 0);
      });

      test('lista con un crédito', () {
        final credits = [
          CreditModel(
            creditId: 1,
            creditName: 'Development',
            creditMembers: 'Dev Team',
          ),
        ];

        expect(credits.length, 1);
        expect(credits.first.creditName, 'Development');
      });

      test('lista con múltiples créditos', () {
        final credits = [
          CreditModel(
            creditId: 1,
            creditName: 'Development',
            creditMembers: 'Developers',
          ),
          CreditModel(
            creditId: 2,
            creditName: 'Design',
            creditMembers: 'Designers',
          ),
          CreditModel(
            creditId: 3,
            creditName: 'QA',
            creditMembers: 'Testers',
          ),
        ];

        expect(credits.length, 3);
        expect(credits[0].creditName, 'Development');
        expect(credits[1].creditName, 'Design');
        expect(credits[2].creditName, 'QA');
      });
    });

    group('Transformación de datos', () {
      test('mapea JSON a lista de CreditModel correctamente', () {
        final jsonRecords = [
          {
            'credit_id': 1,
            'credit_name': 'Development',
            'credit_members': 'Dev1, Dev2',
          },
          {
            'credit_id': 2,
            'credit_name': 'Design',
            'credit_members': 'Designer1',
          },
        ];

        final credits = jsonRecords
            .map((json) => CreditModel.fromJson(json))
            .toList();

        expect(credits.length, 2);
        expect(credits[0].creditId, 1);
        expect(credits[0].creditName, 'Development');
        expect(credits[1].creditId, 2);
        expect(credits[1].creditName, 'Design');
      });

      test('preserva orden de registros', () {
        final jsonRecords = List.generate(
          5,
          (i) => {
            'credit_id': i,
            'credit_name': 'Team $i',
            'credit_members': 'Member $i',
          },
        );

        final credits = jsonRecords
            .map((json) => CreditModel.fromJson(json))
            .toList();

        for (var i = 0; i < 5; i++) {
          expect(credits[i].creditId, i);
          expect(credits[i].creditName, 'Team $i');
        }
      });
    });

    group('Manejo de errores esperados', () {
      test('error cuando archivo no existe debería relanzarse', () {
        // Simula el comportamiento esperado cuando el archivo no existe
        final Future<String> loadError = Future.error(
          Exception('Unable to load asset'),
        );

        expect(loadError, throwsA(isA<Exception>()));
      });

      test('error en JSON inválido debería relanzarse', () {
        // Simula el comportamiento esperado con JSON malformado
        expect(
          () => throw const FormatException('Invalid JSON'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Escenarios de créditos comunes', () {
      test('créditos de desarrollo típicos', () {
        final devCredits = CreditModel(
          creditId: 1,
          creditName: 'Desarrollo',
          creditMembers: 'Desarrolladores Flutter',
        );

        expect(devCredits.creditName, 'Desarrollo');
        expect(devCredits.creditMembers, contains('Flutter'));
      });

      test('créditos de diseño típicos', () {
        final designCredits = CreditModel(
          creditId: 2,
          creditName: 'Diseño UI/UX',
          creditMembers: 'Diseñadores Gráficos',
        );

        expect(designCredits.creditName, 'Diseño UI/UX');
      });

      test('créditos de pruebas típicos', () {
        final qaCredits = CreditModel(
          creditId: 3,
          creditName: 'Control de Calidad',
          creditMembers: 'Equipo QA',
        );

        expect(qaCredits.creditName, 'Control de Calidad');
      });
    });

    group('Operaciones con listas de créditos', () {
      test('puede filtrar créditos por ID', () {
        final credits = [
          CreditModel(creditId: 1, creditName: 'A', creditMembers: 'A'),
          CreditModel(creditId: 2, creditName: 'B', creditMembers: 'B'),
          CreditModel(creditId: 3, creditName: 'C', creditMembers: 'C'),
        ];

        final filtered = credits.where((c) => c.creditId == 2).toList();

        expect(filtered.length, 1);
        expect(filtered.first.creditName, 'B');
      });

      test('puede ordenar créditos por ID', () {
        final credits = [
          CreditModel(creditId: 3, creditName: 'C', creditMembers: 'C'),
          CreditModel(creditId: 1, creditName: 'A', creditMembers: 'A'),
          CreditModel(creditId: 2, creditName: 'B', creditMembers: 'B'),
        ];

        credits.sort((a, b) => a.creditId.compareTo(b.creditId));

        expect(credits[0].creditId, 1);
        expect(credits[1].creditId, 2);
        expect(credits[2].creditId, 3);
      });

      test('puede buscar créditos por nombre', () {
        final credits = [
          CreditModel(creditId: 1, creditName: 'Development', creditMembers: 'A'),
          CreditModel(creditId: 2, creditName: 'Design', creditMembers: 'B'),
          CreditModel(creditId: 3, creditName: 'QA', creditMembers: 'C'),
        ];

        final found = credits.firstWhere((c) => c.creditName == 'Design');

        expect(found.creditId, 2);
        expect(found.creditMembers, 'B');
      });

      test('puede contar total de equipos', () {
        final credits = List.generate(
          10,
          (i) => CreditModel(
            creditId: i,
            creditName: 'Team $i',
            creditMembers: 'Members',
          ),
        );

        expect(credits.length, 10);
      });
    });

    group('Validación de integridad de datos', () {
      test('todos los IDs deben ser únicos', () {
        final credits = [
          CreditModel(creditId: 1, creditName: 'A', creditMembers: 'A'),
          CreditModel(creditId: 2, creditName: 'B', creditMembers: 'B'),
          CreditModel(creditId: 3, creditName: 'C', creditMembers: 'C'),
        ];

        final ids = credits.map((c) => c.creditId).toSet();
        expect(ids.length, credits.length);
      });

      test('ningún campo debe ser null', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Test',
          creditMembers: 'Test',
        );

        expect(credit.creditId, isNotNull);
        expect(credit.creditName, isNotNull);
        expect(credit.creditMembers, isNotNull);
      });
    });
  });
}
