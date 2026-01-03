import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_preferences.dart';

/// Tests para la lógica core de PetPreferences
///
/// NOTA: Los tests completos del provider con Riverpod requieren mock de servicios.
/// Estos tests se enfocan en la lógica del modelo PetPreferences que es utilizado por el provider.
/// Para tests de integración completos, ver integration tests.

void main() {
  group('PetPreferences Model', () {
    test('PetPreferences se crea con valores por defecto correctos', () {
      // Act
      const prefs = PetPreferences();

      // Assert
      expect(prefs.petColor, Colors.purple);
      expect(prefs.accessory, 'none');
      expect(prefs.soundEnabled, true);
      expect(prefs.notificationsEnabled, true);
    });

    test('PetPreferences se puede crear con valores personalizados', () {
      // Act
      const prefs = PetPreferences(
        petColor: Colors.blue,
        accessory: 'hat',
        soundEnabled: false,
        notificationsEnabled: false,
      );

      // Assert
      expect(prefs.petColor, Colors.blue);
      expect(prefs.accessory, 'hat');
      expect(prefs.soundEnabled, false);
      expect(prefs.notificationsEnabled, false);
    });

    test('copyWith actualiza correctamente los campos', () {
      // Arrange
      const original = PetPreferences(
        petColor: Colors.purple,
        accessory: 'none',
        soundEnabled: true,
        notificationsEnabled: true,
      );

      // Act
      final updated = original.copyWith(
        petColor: Colors.red,
        accessory: 'bow',
      );

      // Assert
      expect(updated.petColor, Colors.red); // Cambió
      expect(updated.accessory, 'bow'); // Cambió
      expect(updated.soundEnabled, true); // No cambió
      expect(updated.notificationsEnabled, true); // No cambió
    });

    test('copyWith con todos los campos', () {
      // Arrange
      const original = PetPreferences();

      // Act
      final updated = original.copyWith(
        petColor: Colors.green,
        accessory: 'glasses',
        soundEnabled: false,
        notificationsEnabled: false,
      );

      // Assert
      expect(updated.petColor, Colors.green);
      expect(updated.accessory, 'glasses');
      expect(updated.soundEnabled, false);
      expect(updated.notificationsEnabled, false);
    });

    test('toJson serializa correctamente', () {
      // Arrange
      const prefs = PetPreferences(
        petColor: Colors.blue,
        accessory: 'hat',
        soundEnabled: false,
        notificationsEnabled: true,
      );

      // Act
      final json = prefs.toJson();

      // Assert
      expect(json['petColorValue'], Colors.blue.toARGB32());
      expect(json['accessory'], 'hat');
      expect(json['soundEnabled'], false);
      expect(json['notificationsEnabled'], true);
    });

    test('fromJson deserializa correctamente', () {
      // Arrange
      final json = {
        'petColorValue': Colors.red.toARGB32(),
        'accessory': 'scarf',
        'soundEnabled': false,
        'notificationsEnabled': false,
      };

      // Act
      final prefs = PetPreferences.fromJson(json);

      // Assert
      expect(prefs.petColor.value, Colors.red.value);
      expect(prefs.accessory, 'scarf');
      expect(prefs.soundEnabled, false);
      expect(prefs.notificationsEnabled, false);
    });

    test('fromJson usa valores por defecto para campos faltantes', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final prefs = PetPreferences.fromJson(json);

      // Assert
      expect(prefs.petColor.value, Colors.purple.value);
      expect(prefs.accessory, 'none');
      expect(prefs.soundEnabled, true);
      expect(prefs.notificationsEnabled, true);
    });

    test('fromJson deserializa y serializa correctamente (round-trip)', () {
      // Arrange
      const original = PetPreferences(
        petColor: Colors.teal,
        accessory: 'bow',
        soundEnabled: true,
        notificationsEnabled: false,
      );

      // Act
      final json = original.toJson();
      final deserialized = PetPreferences.fromJson(json);

      // Assert
      expect(deserialized.petColor.value, original.petColor.value);
      expect(deserialized.accessory, original.accessory);
      expect(deserialized.soundEnabled, original.soundEnabled);
      expect(deserialized.notificationsEnabled, original.notificationsEnabled);
    });

    test('accessoryEmoji retorna emoji correcto para cada accesorio', () {
      expect(const PetPreferences(accessory: 'none').accessoryEmoji, '');
      expect(const PetPreferences(accessory: 'bow').accessoryEmoji, '🎀');
      expect(const PetPreferences(accessory: 'hat').accessoryEmoji, '🎩');
      expect(const PetPreferences(accessory: 'glasses').accessoryEmoji, '🕶️');
      expect(const PetPreferences(accessory: 'scarf').accessoryEmoji, '🧣');
    });

    test('accessoryName retorna nombre correcto para cada accesorio', () {
      expect(const PetPreferences(accessory: 'none').accessoryName, 'Ninguno');
      expect(const PetPreferences(accessory: 'bow').accessoryName, 'Moño');
      expect(const PetPreferences(accessory: 'hat').accessoryName, 'Sombrero');
      expect(const PetPreferences(accessory: 'glasses').accessoryName, 'Lentes');
      expect(const PetPreferences(accessory: 'scarf').accessoryName, 'Bufanda');
    });

    test('accessoryEmoji retorna string vacío para accesorio desconocido', () {
      // Act
      const prefs = PetPreferences(accessory: 'unknown');

      // Assert
      expect(prefs.accessoryEmoji, '');
    });

    test('accessoryName retorna "Ninguno" para accesorio desconocido', () {
      // Act
      const prefs = PetPreferences(accessory: 'unknown');

      // Assert
      expect(prefs.accessoryName, 'Ninguno');
    });

    test('availableColors contiene 8 colores', () {
      expect(PetPreferences.availableColors.length, 8);
    });

    test('availableColors contiene todos los colores esperados', () {
      final colors = PetPreferences.availableColors;

      expect(colors.contains(Colors.purple), true);
      expect(colors.contains(Colors.pink), true);
      expect(colors.contains(Colors.blue), true);
      expect(colors.contains(Colors.green), true);
      expect(colors.contains(Colors.orange), true);
      expect(colors.contains(Colors.red), true);
      expect(colors.contains(Colors.teal), true);
      expect(colors.contains(Colors.amber), true);
    });

    test('availableAccessories contiene 5 accesorios', () {
      expect(PetPreferences.availableAccessories.length, 5);
    });

    test('availableAccessories contiene todos los accesorios esperados', () {
      final accessories = PetPreferences.availableAccessories;

      expect(accessories.contains('none'), true);
      expect(accessories.contains('bow'), true);
      expect(accessories.contains('hat'), true);
      expect(accessories.contains('glasses'), true);
      expect(accessories.contains('scarf'), true);
    });

    test('petColor por defecto está en availableColors', () {
      const prefs = PetPreferences();

      expect(PetPreferences.availableColors.contains(prefs.petColor), true);
    });

    test('accessory por defecto está en availableAccessories', () {
      const prefs = PetPreferences();

      expect(PetPreferences.availableAccessories.contains(prefs.accessory), true);
    });

    test('todos los availableAccessories tienen emoji y nombre', () {
      for (final accessory in PetPreferences.availableAccessories) {
        final prefs = PetPreferences(accessory: accessory);

        expect(prefs.accessoryEmoji, isA<String>());
        expect(prefs.accessoryName, isA<String>());
        expect(prefs.accessoryName, isNotEmpty);
      }
    });

    test('soundEnabled puede ser true o false', () {
      const enabledPrefs = PetPreferences(soundEnabled: true);
      const disabledPrefs = PetPreferences(soundEnabled: false);

      expect(enabledPrefs.soundEnabled, true);
      expect(disabledPrefs.soundEnabled, false);
    });

    test('notificationsEnabled puede ser true o false', () {
      const enabledPrefs = PetPreferences(notificationsEnabled: true);
      const disabledPrefs = PetPreferences(notificationsEnabled: false);

      expect(enabledPrefs.notificationsEnabled, true);
      expect(disabledPrefs.notificationsEnabled, false);
    });

    test('múltiples copyWith en secuencia funcionan correctamente', () {
      // Arrange
      const original = PetPreferences();

      // Act
      final step1 = original.copyWith(petColor: Colors.blue);
      final step2 = step1.copyWith(accessory: 'hat');
      final step3 = step2.copyWith(soundEnabled: false);
      final step4 = step3.copyWith(notificationsEnabled: false);

      // Assert
      expect(step4.petColor, Colors.blue);
      expect(step4.accessory, 'hat');
      expect(step4.soundEnabled, false);
      expect(step4.notificationsEnabled, false);
    });
  });
}
