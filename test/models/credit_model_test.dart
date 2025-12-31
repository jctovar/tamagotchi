import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/credit_model.dart';

void main() {
  group('CreditModel', () {
    group('Constructor', () {
      test('crea modelo con todos los campos', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Development',
          creditMembers: 'John Doe, Jane Smith',
        );

        expect(credit.creditId, 1);
        expect(credit.creditName, 'Development');
        expect(credit.creditMembers, 'John Doe, Jane Smith');
      });

      test('crea modelo con diferentes IDs', () {
        final credit1 = CreditModel(
          creditId: 1,
          creditName: 'Team 1',
          creditMembers: 'Member 1',
        );

        final credit2 = CreditModel(
          creditId: 999,
          creditName: 'Team 2',
          creditMembers: 'Member 2',
        );

        expect(credit1.creditId, 1);
        expect(credit2.creditId, 999);
      });

      test('maneja nombres vacíos', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: '',
          creditMembers: '',
        );

        expect(credit.creditName, '');
        expect(credit.creditMembers, '');
      });

      test('maneja nombres largos', () {
        final longName = 'A' * 1000;
        final credit = CreditModel(
          creditId: 1,
          creditName: longName,
          creditMembers: longName,
        );

        expect(credit.creditName.length, 1000);
        expect(credit.creditMembers.length, 1000);
      });
    });

    group('Serialización - fromJson', () {
      test('deserializa JSON válido', () {
        final json = {
          'credit_id': 1,
          'credit_name': 'Development',
          'credit_members': 'John Doe, Jane Smith',
        };

        final credit = CreditModel.fromJson(json);

        expect(credit.creditId, 1);
        expect(credit.creditName, 'Development');
        expect(credit.creditMembers, 'John Doe, Jane Smith');
      });

      test('deserializa JSON con diferentes tipos de datos', () {
        final json = {
          'credit_id': 42,
          'credit_name': 'Testing Team',
          'credit_members': 'Alice, Bob, Charlie',
        };

        final credit = CreditModel.fromJson(json);

        expect(credit.creditId, 42);
        expect(credit.creditName, 'Testing Team');
        expect(credit.creditMembers, 'Alice, Bob, Charlie');
      });

      test('maneja strings con caracteres especiales', () {
        final json = {
          'credit_id': 1,
          'credit_name': 'Diseño & Arte 🎨',
          'credit_members': 'José García, María López',
        };

        final credit = CreditModel.fromJson(json);

        expect(credit.creditName, contains('🎨'));
        expect(credit.creditMembers, contains('José'));
        expect(credit.creditMembers, contains('María'));
      });

      test('maneja múltiples miembros separados por coma', () {
        final json = {
          'credit_id': 1,
          'credit_name': 'Team',
          'credit_members': 'Member1, Member2, Member3, Member4',
        };

        final credit = CreditModel.fromJson(json);

        expect(credit.creditMembers, contains(','));
        expect(credit.creditMembers.split(',').length, 4);
      });
    });

    group('Serialización - toJson', () {
      test('serializa modelo a JSON', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Development',
          creditMembers: 'John Doe, Jane Smith',
        );

        final json = credit.toJson();

        expect(json['credit_id'], 1);
        expect(json['credit_name'], 'Development');
        expect(json['credit_members'], 'John Doe, Jane Smith');
      });

      test('serializa modelo con strings vacíos', () {
        final credit = CreditModel(
          creditId: 0,
          creditName: '',
          creditMembers: '',
        );

        final json = credit.toJson();

        expect(json['credit_id'], 0);
        expect(json['credit_name'], '');
        expect(json['credit_members'], '');
      });

      test('preserva caracteres especiales', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Arte & Diseño 🎨',
          creditMembers: 'José, María',
        );

        final json = credit.toJson();

        expect(json['credit_name'], contains('🎨'));
        expect(json['credit_members'], contains('José'));
      });
    });

    group('Serialización - Roundtrip', () {
      test('roundtrip toJson -> fromJson preserva datos', () {
        final original = CreditModel(
          creditId: 42,
          creditName: 'QA Team',
          creditMembers: 'Tester1, Tester2',
        );

        final json = original.toJson();
        final restored = CreditModel.fromJson(json);

        expect(restored.creditId, original.creditId);
        expect(restored.creditName, original.creditName);
        expect(restored.creditMembers, original.creditMembers);
      });

      test('roundtrip con múltiples instancias', () {
        final credits = [
          CreditModel(
            creditId: 1,
            creditName: 'Development',
            creditMembers: 'Dev1, Dev2',
          ),
          CreditModel(
            creditId: 2,
            creditName: 'Design',
            creditMembers: 'Designer1',
          ),
          CreditModel(
            creditId: 3,
            creditName: 'QA',
            creditMembers: 'QA1, QA2, QA3',
          ),
        ];

        for (final original in credits) {
          final json = original.toJson();
          final restored = CreditModel.fromJson(json);

          expect(restored.creditId, original.creditId);
          expect(restored.creditName, original.creditName);
          expect(restored.creditMembers, original.creditMembers);
        }
      });
    });

    group('Casos límite', () {
      test('maneja ID negativo', () {
        final credit = CreditModel(
          creditId: -1,
          creditName: 'Test',
          creditMembers: 'Test',
        );

        expect(credit.creditId, -1);
      });

      test('maneja ID muy grande', () {
        final credit = CreditModel(
          creditId: 999999999,
          creditName: 'Test',
          creditMembers: 'Test',
        );

        expect(credit.creditId, 999999999);
      });

      test('maneja nombre con solo espacios', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: '   ',
          creditMembers: '   ',
        );

        expect(credit.creditName, '   ');
        expect(credit.creditMembers, '   ');
      });

      test('maneja saltos de línea en nombres', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Line1\nLine2',
          creditMembers: 'Member1\nMember2',
        );

        expect(credit.creditName, contains('\n'));
        expect(credit.creditMembers, contains('\n'));
      });

      test('maneja comillas en strings', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Team "Awesome"',
          creditMembers: 'John "Johnny" Doe',
        );

        expect(credit.creditName, contains('"'));
        expect(credit.creditMembers, contains('"'));
      });
    });

    group('Diferentes formatos de miembros', () {
      test('maneja un solo miembro', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Solo Team',
          creditMembers: 'Single Member',
        );

        expect(credit.creditMembers, 'Single Member');
        expect(credit.creditMembers, isNot(contains(',')));
      });

      test('maneja dos miembros', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Duo Team',
          creditMembers: 'Member1, Member2',
        );

        expect(credit.creditMembers.split(',').length, 2);
      });

      test('maneja muchos miembros', () {
        final members = List.generate(10, (i) => 'Member$i').join(', ');
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Big Team',
          creditMembers: members,
        );

        expect(credit.creditMembers.split(',').length, 10);
      });

      test('maneja miembros con títulos', () {
        final credit = CreditModel(
          creditId: 1,
          creditName: 'Professional Team',
          creditMembers: 'Dr. Smith, Prof. Johnson, Mr. Williams',
        );

        expect(credit.creditMembers, contains('Dr.'));
        expect(credit.creditMembers, contains('Prof.'));
        expect(credit.creditMembers, contains('Mr.'));
      });
    });

    group('Nombres de equipos comunes', () {
      const teamNames = [
        'Development',
        'Design',
        'QA',
        'Product Management',
        'Marketing',
        'Support',
      ];

      for (final name in teamNames) {
        test('crea crédito para equipo $name', () {
          final credit = CreditModel(
            creditId: 1,
            creditName: name,
            creditMembers: 'Team Member',
          );

          expect(credit.creditName, name);
        });
      }
    });
  });
}
