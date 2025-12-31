import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/models/pet_preferences.dart';
import 'package:tamagotchi/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PetPreferences', () {
    test('constructor inicializa con valores por defecto', () {
      const prefs = PetPreferences();

      expect(prefs.petColor, Colors.purple);
      expect(prefs.accessory, 'none');
      expect(prefs.soundEnabled, true);
      expect(prefs.notificationsEnabled, true);
    });

    test('constructor acepta valores personalizados', () {
      const prefs = PetPreferences(
        petColor: Colors.blue,
        accessory: 'hat',
        soundEnabled: false,
        notificationsEnabled: false,
      );

      expect(prefs.petColor, Colors.blue);
      expect(prefs.accessory, 'hat');
      expect(prefs.soundEnabled, false);
      expect(prefs.notificationsEnabled, false);
    });

    group('copyWith', () {
      test('actualiza solo los campos proporcionados', () {
        const original = PetPreferences(
          petColor: Colors.purple,
          accessory: 'none',
          soundEnabled: true,
          notificationsEnabled: true,
        );

        final updated = original.copyWith(
          petColor: Colors.red,
          soundEnabled: false,
        );

        expect(updated.petColor, Colors.red);
        expect(updated.accessory, 'none'); // No cambió
        expect(updated.soundEnabled, false);
        expect(updated.notificationsEnabled, true); // No cambió
      });

      test('mantiene valores cuando no se proporcionan parámetros', () {
        const original = PetPreferences(
          petColor: Colors.green,
          accessory: 'bow',
          soundEnabled: false,
          notificationsEnabled: false,
        );

        final copy = original.copyWith();

        expect(copy.petColor, Colors.green);
        expect(copy.accessory, 'bow');
        expect(copy.soundEnabled, false);
        expect(copy.notificationsEnabled, false);
      });
    });

    group('serialización', () {
      test('toJson serializa correctamente', () {
        const prefs = PetPreferences(
          petColor: Colors.blue,
          accessory: 'hat',
          soundEnabled: false,
          notificationsEnabled: true,
        );

        final json = prefs.toJson();

        expect(json['petColorValue'], Colors.blue.toARGB32());
        expect(json['accessory'], 'hat');
        expect(json['soundEnabled'], false);
        expect(json['notificationsEnabled'], true);
      });

      test('fromJson deserializa correctamente', () {
        final json = {
          'petColorValue': Colors.red.toARGB32(),
          'accessory': 'glasses',
          'soundEnabled': true,
          'notificationsEnabled': false,
        };

        final prefs = PetPreferences.fromJson(json);

        expect(prefs.petColor.toARGB32(), Colors.red.toARGB32());
        expect(prefs.accessory, 'glasses');
        expect(prefs.soundEnabled, true);
        expect(prefs.notificationsEnabled, false);
      });

      test('fromJson usa valores por defecto para campos faltantes', () {
        final json = <String, dynamic>{};
        final prefs = PetPreferences.fromJson(json);

        expect(prefs.petColor.toARGB32(), Colors.purple.toARGB32());
        expect(prefs.accessory, 'none');
        expect(prefs.soundEnabled, true);
        expect(prefs.notificationsEnabled, true);
      });

      test('fromJson usa valores por defecto para valores null', () {
        final json = {
          'petColorValue': null,
          'accessory': null,
          'soundEnabled': null,
          'notificationsEnabled': null,
        };

        final prefs = PetPreferences.fromJson(json);

        expect(prefs.petColor.toARGB32(), Colors.purple.toARGB32());
        expect(prefs.accessory, 'none');
        expect(prefs.soundEnabled, true);
        expect(prefs.notificationsEnabled, true);
      });

      test('roundtrip toJson -> fromJson preserva datos', () {
        const original = PetPreferences(
          petColor: Colors.teal,
          accessory: 'scarf',
          soundEnabled: false,
          notificationsEnabled: true,
        );

        final json = original.toJson();
        final restored = PetPreferences.fromJson(json);

        expect(restored.petColor.toARGB32(), original.petColor.toARGB32());
        expect(restored.accessory, original.accessory);
        expect(restored.soundEnabled, original.soundEnabled);
        expect(restored.notificationsEnabled, original.notificationsEnabled);
      });
    });

    group('availableColors', () {
      test('contiene 8 colores', () {
        expect(PetPreferences.availableColors.length, 8);
      });

      test('incluye todos los colores esperados', () {
        expect(PetPreferences.availableColors, contains(Colors.purple));
        expect(PetPreferences.availableColors, contains(Colors.pink));
        expect(PetPreferences.availableColors, contains(Colors.blue));
        expect(PetPreferences.availableColors, contains(Colors.green));
        expect(PetPreferences.availableColors, contains(Colors.orange));
        expect(PetPreferences.availableColors, contains(Colors.red));
        expect(PetPreferences.availableColors, contains(Colors.teal));
        expect(PetPreferences.availableColors, contains(Colors.amber));
      });
    });

    group('availableAccessories', () {
      test('contiene 5 accesorios', () {
        expect(PetPreferences.availableAccessories.length, 5);
      });

      test('incluye todos los accesorios esperados', () {
        expect(PetPreferences.availableAccessories, contains('none'));
        expect(PetPreferences.availableAccessories, contains('bow'));
        expect(PetPreferences.availableAccessories, contains('hat'));
        expect(PetPreferences.availableAccessories, contains('glasses'));
        expect(PetPreferences.availableAccessories, contains('scarf'));
      });
    });

    group('accessoryEmoji', () {
      test('devuelve emoji correcto para bow', () {
        const prefs = PetPreferences(accessory: 'bow');
        expect(prefs.accessoryEmoji, '🎀');
      });

      test('devuelve emoji correcto para hat', () {
        const prefs = PetPreferences(accessory: 'hat');
        expect(prefs.accessoryEmoji, '🎩');
      });

      test('devuelve emoji correcto para glasses', () {
        const prefs = PetPreferences(accessory: 'glasses');
        expect(prefs.accessoryEmoji, '🕶️');
      });

      test('devuelve emoji correcto para scarf', () {
        const prefs = PetPreferences(accessory: 'scarf');
        expect(prefs.accessoryEmoji, '🧣');
      });

      test('devuelve string vacío para none', () {
        const prefs = PetPreferences(accessory: 'none');
        expect(prefs.accessoryEmoji, '');
      });

      test('devuelve string vacío para accesorio desconocido', () {
        const prefs = PetPreferences(accessory: 'unknown');
        expect(prefs.accessoryEmoji, '');
      });
    });

    group('accessoryName', () {
      test('devuelve nombre correcto para bow', () {
        const prefs = PetPreferences(accessory: 'bow');
        expect(prefs.accessoryName, 'Moño');
      });

      test('devuelve nombre correcto para hat', () {
        const prefs = PetPreferences(accessory: 'hat');
        expect(prefs.accessoryName, 'Sombrero');
      });

      test('devuelve nombre correcto para glasses', () {
        const prefs = PetPreferences(accessory: 'glasses');
        expect(prefs.accessoryName, 'Lentes');
      });

      test('devuelve nombre correcto para scarf', () {
        const prefs = PetPreferences(accessory: 'scarf');
        expect(prefs.accessoryName, 'Bufanda');
      });

      test('devuelve "Ninguno" para none', () {
        const prefs = PetPreferences(accessory: 'none');
        expect(prefs.accessoryName, 'Ninguno');
      });

      test('devuelve "Ninguno" para accesorio desconocido', () {
        const prefs = PetPreferences(accessory: 'unknown');
        expect(prefs.accessoryName, 'Ninguno');
      });
    });
  });

  group('PreferencesService', () {
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test
      SharedPreferences.setMockInitialValues({});
    });

    group('savePreferences', () {
      test('guarda preferencias correctamente', () async {
        const prefs = PetPreferences(
          petColor: Colors.blue,
          accessory: 'hat',
          soundEnabled: false,
          notificationsEnabled: true,
        );

        await PreferencesService.savePreferences(prefs);

        final sp = await SharedPreferences.getInstance();
        final saved = sp.getString('pet_preferences');

        expect(saved, isNotNull);
        expect(saved, contains('petColorValue'));
        expect(saved, contains('hat'));
      });

      test('sobrescribe preferencias anteriores', () async {
        const prefs1 = PetPreferences(accessory: 'bow');
        const prefs2 = PetPreferences(accessory: 'hat');

        await PreferencesService.savePreferences(prefs1);
        await PreferencesService.savePreferences(prefs2);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.accessory, 'hat');
      });
    });

    group('loadPreferences', () {
      test('carga preferencias guardadas correctamente', () async {
        const original = PetPreferences(
          petColor: Colors.green,
          accessory: 'scarf',
          soundEnabled: false,
          notificationsEnabled: false,
        );

        await PreferencesService.savePreferences(original);
        final loaded = await PreferencesService.loadPreferences();

        expect(loaded.petColor.toARGB32(), Colors.green.toARGB32());
        expect(loaded.accessory, 'scarf');
        expect(loaded.soundEnabled, false);
        expect(loaded.notificationsEnabled, false);
      });

      test('retorna valores por defecto cuando no hay preferencias guardadas', () async {
        final loaded = await PreferencesService.loadPreferences();

        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32());
        expect(loaded.accessory, 'none');
        expect(loaded.soundEnabled, true);
        expect(loaded.notificationsEnabled, true);
      });

      test('retorna valores por defecto cuando JSON está corrupto', () async {
        final sp = await SharedPreferences.getInstance();
        await sp.setString('pet_preferences', 'invalid json data {]');

        final loaded = await PreferencesService.loadPreferences();

        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32());
        expect(loaded.accessory, 'none');
        expect(loaded.soundEnabled, true);
        expect(loaded.notificationsEnabled, true);
      });

      test('retorna valores por defecto cuando JSON es vacío', () async {
        final sp = await SharedPreferences.getInstance();
        await sp.setString('pet_preferences', '{}');

        final loaded = await PreferencesService.loadPreferences();

        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32());
        expect(loaded.accessory, 'none');
        expect(loaded.soundEnabled, true);
        expect(loaded.notificationsEnabled, true);
      });

      test('maneja correctamente valores parciales en JSON', () async {
        final sp = await SharedPreferences.getInstance();
        await sp.setString(
          'pet_preferences',
          '{"accessory": "bow", "soundEnabled": false}',
        );

        final loaded = await PreferencesService.loadPreferences();

        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32()); // Default
        expect(loaded.accessory, 'bow'); // Cargado
        expect(loaded.soundEnabled, false); // Cargado
        expect(loaded.notificationsEnabled, true); // Default
      });
    });

    group('updatePetColor', () {
      test('actualiza color de mascota correctamente', () async {
        const initial = PetPreferences(petColor: Colors.purple);
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updatePetColor(Colors.red.toARGB32());

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.red.toARGB32());
      });

      test('mantiene otras preferencias al actualizar color', () async {
        const initial = PetPreferences(
          petColor: Colors.purple,
          accessory: 'hat',
          soundEnabled: false,
          notificationsEnabled: false,
        );
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updatePetColor(Colors.blue.toARGB32());

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.blue.toARGB32());
        expect(loaded.accessory, 'hat'); // No cambió
        expect(loaded.soundEnabled, false); // No cambió
        expect(loaded.notificationsEnabled, false); // No cambió
      });

      test('funciona cuando no hay preferencias previas', () async {
        await PreferencesService.updatePetColor(Colors.teal.toARGB32());

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.teal.toARGB32());
        expect(loaded.accessory, 'none'); // Defaults
        expect(loaded.soundEnabled, true); // Defaults
      });
    });

    group('updateAccessory', () {
      test('actualiza accesorio correctamente', () async {
        const initial = PetPreferences(accessory: 'none');
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updateAccessory('bow');

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.accessory, 'bow');
      });

      test('mantiene otras preferencias al actualizar accesorio', () async {
        const initial = PetPreferences(
          petColor: Colors.pink,
          accessory: 'none',
          soundEnabled: false,
          notificationsEnabled: true,
        );
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updateAccessory('glasses');

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.pink.toARGB32()); // No cambió
        expect(loaded.accessory, 'glasses');
        expect(loaded.soundEnabled, false); // No cambió
        expect(loaded.notificationsEnabled, true); // No cambió
      });

      test('funciona cuando no hay preferencias previas', () async {
        await PreferencesService.updateAccessory('scarf');

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.accessory, 'scarf');
        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32()); // Defaults
      });

      test('puede cambiar de un accesorio a otro', () async {
        await PreferencesService.updateAccessory('hat');
        await PreferencesService.updateAccessory('bow');
        await PreferencesService.updateAccessory('glasses');

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.accessory, 'glasses');
      });

      test('puede quitar accesorio estableciendo none', () async {
        await PreferencesService.updateAccessory('hat');
        await PreferencesService.updateAccessory('none');

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.accessory, 'none');
      });
    });

    group('updateSoundEnabled', () {
      test('actualiza estado de sonido correctamente', () async {
        const initial = PetPreferences(soundEnabled: true);
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updateSoundEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.soundEnabled, false);
      });

      test('mantiene otras preferencias al actualizar sonido', () async {
        const initial = PetPreferences(
          petColor: Colors.orange,
          accessory: 'bow',
          soundEnabled: true,
          notificationsEnabled: false,
        );
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updateSoundEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.orange.toARGB32()); // No cambió
        expect(loaded.accessory, 'bow'); // No cambió
        expect(loaded.soundEnabled, false);
        expect(loaded.notificationsEnabled, false); // No cambió
      });

      test('funciona cuando no hay preferencias previas', () async {
        await PreferencesService.updateSoundEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.soundEnabled, false);
        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32()); // Defaults
      });

      test('puede alternar entre true y false', () async {
        await PreferencesService.updateSoundEnabled(false);
        await PreferencesService.updateSoundEnabled(true);
        await PreferencesService.updateSoundEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.soundEnabled, false);
      });
    });

    group('updateNotificationsEnabled', () {
      test('actualiza estado de notificaciones correctamente', () async {
        const initial = PetPreferences(notificationsEnabled: true);
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updateNotificationsEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.notificationsEnabled, false);
      });

      test('mantiene otras preferencias al actualizar notificaciones', () async {
        const initial = PetPreferences(
          petColor: Colors.amber,
          accessory: 'scarf',
          soundEnabled: false,
          notificationsEnabled: true,
        );
        await PreferencesService.savePreferences(initial);

        await PreferencesService.updateNotificationsEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.amber.toARGB32()); // No cambió
        expect(loaded.accessory, 'scarf'); // No cambió
        expect(loaded.soundEnabled, false); // No cambió
        expect(loaded.notificationsEnabled, false);
      });

      test('funciona cuando no hay preferencias previas', () async {
        await PreferencesService.updateNotificationsEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.notificationsEnabled, false);
        expect(loaded.petColor.toARGB32(), Colors.purple.toARGB32()); // Defaults
      });

      test('puede alternar entre true y false', () async {
        await PreferencesService.updateNotificationsEnabled(false);
        await PreferencesService.updateNotificationsEnabled(true);
        await PreferencesService.updateNotificationsEnabled(false);

        final loaded = await PreferencesService.loadPreferences();
        expect(loaded.notificationsEnabled, false);
      });
    });

    group('integración', () {
      test('múltiples actualizaciones mantienen consistencia', () async {
        // Configuración inicial
        await PreferencesService.updatePetColor(Colors.blue.toARGB32());
        await PreferencesService.updateAccessory('hat');
        await PreferencesService.updateSoundEnabled(false);
        await PreferencesService.updateNotificationsEnabled(true);

        final loaded1 = await PreferencesService.loadPreferences();
        expect(loaded1.petColor.toARGB32(), Colors.blue.toARGB32());
        expect(loaded1.accessory, 'hat');
        expect(loaded1.soundEnabled, false);
        expect(loaded1.notificationsEnabled, true);

        // Más actualizaciones
        await PreferencesService.updatePetColor(Colors.green.toARGB32());
        await PreferencesService.updateAccessory('bow');

        final loaded2 = await PreferencesService.loadPreferences();
        expect(loaded2.petColor.toARGB32(), Colors.green.toARGB32());
        expect(loaded2.accessory, 'bow');
        expect(loaded2.soundEnabled, false); // Se mantuvo
        expect(loaded2.notificationsEnabled, true); // Se mantuvo
      });

      test('guarda todos los colores disponibles correctamente', () async {
        for (final color in PetPreferences.availableColors) {
          await PreferencesService.updatePetColor(color.toARGB32());
          final loaded = await PreferencesService.loadPreferences();
          expect(loaded.petColor.toARGB32(), color.toARGB32());
        }
      });

      test('guarda todos los accesorios disponibles correctamente', () async {
        for (final accessory in PetPreferences.availableAccessories) {
          await PreferencesService.updateAccessory(accessory);
          final loaded = await PreferencesService.loadPreferences();
          expect(loaded.accessory, accessory);
        }
      });

      test('persiste datos después de múltiples ciclos load-update-save', () async {
        // Ciclo 1
        await PreferencesService.updatePetColor(Colors.red.toARGB32());
        var loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.red.toARGB32());

        // Ciclo 2
        await PreferencesService.updateAccessory('glasses');
        loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.red.toARGB32()); // Se mantuvo
        expect(loaded.accessory, 'glasses');

        // Ciclo 3
        await PreferencesService.updateSoundEnabled(false);
        loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.red.toARGB32()); // Se mantuvo
        expect(loaded.accessory, 'glasses'); // Se mantuvo
        expect(loaded.soundEnabled, false);

        // Ciclo 4
        await PreferencesService.updateNotificationsEnabled(false);
        loaded = await PreferencesService.loadPreferences();
        expect(loaded.petColor.toARGB32(), Colors.red.toARGB32()); // Se mantuvo
        expect(loaded.accessory, 'glasses'); // Se mantuvo
        expect(loaded.soundEnabled, false); // Se mantuvo
        expect(loaded.notificationsEnabled, false);
      });
    });
  });
}
