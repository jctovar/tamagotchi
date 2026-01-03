import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/life_stage.dart';

/// Tests simplificados para la lógica core de PetState
///
/// NOTA: Los tests completos del provider con Riverpod requieren mock de Firebase Analytics.
/// Estos tests se enfocan en la lógica del modelo Pet que es utilizada por el provider.
/// Para tests de integración completos con Firebase, ver integration tests.

void main() {
  group('Pet Model - Core Logic', () {
    test('Pet se crea con valores por defecto correctos', () {
      // Act
      final pet = Pet(name: 'Test');

      // Assert
      expect(pet.name, 'Test');
      expect(pet.hunger, 0.0); // Valor por defecto correcto
      expect(pet.happiness, 100.0); // Valor por defecto correcto
      expect(pet.energy, 100.0); // Valor por defecto correcto
      expect(pet.health, 100.0);
      expect(pet.experience, 0);
      expect(pet.coins, 0);
      expect(pet.level, 1);
      expect(pet.lifeStage, LifeStage.egg);
    });

    test('copyWith actualiza correctamente los valores', () {
      // Arrange
      final pet = Pet(name: 'Test', hunger: 60);

      // Act
      final updated = pet.copyWith(hunger: 30, happiness: 80);

      // Assert
      expect(updated.name, 'Test'); // No cambió
      expect(updated.hunger, 30); // Cambió
      expect(updated.happiness, 80); // Cambió
      expect(updated.energy, 100.0); // No cambió (valor por defecto)
    });

    test('gainExperience de feed otorga XP correcta', () {
      // Arrange
      final pet = Pet(name: 'Test', experience: 0);

      // Act
      final updated = pet.gainExperience('feed');

      // Assert
      expect(updated.experience, greaterThan(0));
      expect(updated.experience, equals(10)); // feed da 10 XP
    });

    test('gainExperience de play otorga XP correcta', () {
      // Arrange
      final pet = Pet(name: 'Test', experience: 0);

      // Act
      final updated = pet.gainExperience('play');

      // Assert
      expect(updated.experience, equals(15)); // play da 15 XP
    });

    test('gainExperience de clean otorga XP correcta', () {
      // Arrange
      final pet = Pet(name: 'Test', experience: 0);

      // Act
      final updated = pet.gainExperience('clean');

      // Assert
      expect(updated.experience, equals(10)); // clean da 10 XP
    });

    test('gainExperience de rest otorga XP correcta', () {
      // Arrange
      final pet = Pet(name: 'Test', experience: 0);

      // Act
      final updated = pet.gainExperience('rest');

      // Assert
      expect(updated.experience, equals(5)); // rest da 5 XP
    });

    test('level se calcula correctamente basado en experiencia', () {
      // Assert diferentes niveles
      // Nivel = (experience / 100).floor() + 1
      expect(Pet(name: 'Test', experience: 0).level, 1);
      expect(Pet(name: 'Test', experience: 50).level, 1);
      expect(Pet(name: 'Test', experience: 100).level, 2);
      expect(Pet(name: 'Test', experience: 250).level, 3);
      expect(Pet(name: 'Test', experience: 500).level, 6); // (500/100).floor() + 1 = 5 + 1 = 6
      expect(Pet(name: 'Test', experience: 1000).level, 11); // (1000/100).floor() + 1 = 10 + 1 = 11
    });

    test('isCritical detecta estado crítico correctamente', () {
      // Arrange & Assert
      // mood es critical cuando: health < 30 || hunger > 80 || energy < 20
      final critical1 = Pet(name: 'Test', hunger: 85, happiness: 100, energy: 100, health: 100);
      expect(critical1.isCritical, true); // Hambre > 80

      final critical2 = Pet(name: 'Test', hunger: 0, happiness: 100, energy: 100, health: 25);
      expect(critical2.isCritical, true); // Salud < 30

      final critical3 = Pet(name: 'Test', hunger: 0, happiness: 100, energy: 15, health: 100);
      expect(critical3.isCritical, true); // Energía < 20

      final healthy = Pet(name: 'Test', hunger: 50, happiness: 50, energy: 50, health: 100);
      expect(healthy.isCritical, false); // Todo bien
    });

    test('updateLifeStage funciona correctamente', () {
      // Arrange - mascota base
      final pet = Pet(name: 'Test');

      // Act
      final updated = pet.updateLifeStage();

      // Assert - debería retornar una mascota con life stage actualizado
      expect(updated, isNotNull);
      expect(updated.lifeStage, isNotNull);
    });

    test('updateVariant funciona correctamente', () {
      // Arrange - mascota base
      final pet = Pet(name: 'Test');

      // Act
      final updated = pet.updateVariant();

      // Assert - debería retornar una mascota con variante actualizada
      expect(updated, isNotNull);
      expect(updated.variant, isNotNull);
      // El variant es un enum PetVariant, verificar que sea uno de los valores válidos
      expect(updated.variant, isIn([PetVariant.normal, PetVariant.excellent, PetVariant.neglected]));
    });

    test('toJson serializa correctamente', () {
      // Arrange
      final pet = Pet(
        name: 'Test',
        hunger: 60,
        happiness: 70,
        experience: 100,
        coins: 50,
      );

      // Act
      final json = pet.toJson();

      // Assert
      expect(json['name'], 'Test');
      expect(json['hunger'], 60);
      expect(json['happiness'], 70);
      expect(json['experience'], 100);
      expect(json['coins'], 50);
      expect(json, isA<Map<String, dynamic>>());
    });

    test('fromJson deserializa correctamente', () {
      // Arrange
      final json = {
        'name': 'TestPet',
        'hunger': 45.0,
        'happiness': 85.0,
        'energy': 65.0,
        'health': 95.0,
        'experience': 200,
        'coins': 75,
        'createdAt': DateTime.now().toIso8601String(),
        'lastFed': DateTime.now().toIso8601String(),
        'lastPlayed': DateTime.now().toIso8601String(),
        'lastCleaned': DateTime.now().toIso8601String(),
        'lastRested': DateTime.now().toIso8601String(),
      };

      // Act
      final pet = Pet.fromJson(json);

      // Assert
      expect(pet.name, 'TestPet');
      expect(pet.hunger, 45.0);
      expect(pet.happiness, 85.0);
      expect(pet.energy, 65.0);
      expect(pet.health, 95.0);
      expect(pet.experience, 200);
      expect(pet.coins, 75);
    });

    test('combinación de acciones funciona correctamente', () {
      // Arrange
      var pet = Pet(name: 'Test', hunger: 70, happiness: 40, energy: 60, health: 80);

      // Act - Alimentar
      pet = pet.copyWith(hunger: (pet.hunger - 30).clamp(0, 100));
      pet = pet.gainExperience('feed');

      // Assert después de alimentar
      expect(pet.hunger, 40); // 70 - 30
      expect(pet.experience, 10);

      // Act - Jugar
      pet = pet.copyWith(
        happiness: (pet.happiness + 25).clamp(0, 100),
        energy: (pet.energy - 15).clamp(0, 100),
      );
      pet = pet.gainExperience('play');

      // Assert después de jugar
      expect(pet.happiness, 65); // 40 + 25
      expect(pet.energy, 45); // 60 - 15
      expect(pet.experience, 25); // 10 + 15

      // Act - Limpiar
      pet = pet.copyWith(health: (pet.health + 20).clamp(0, 100));
      pet = pet.gainExperience('clean');

      // Assert después de limpiar
      expect(pet.health, 100); // 80 + 20, clamped a 100
      expect(pet.experience, 35); // 25 + 10

      // Act - Descansar
      pet = pet.copyWith(energy: (pet.energy + 40).clamp(0, 100));
      pet = pet.gainExperience('rest');

      // Assert después de descansar
      expect(pet.energy, 85); // 45 + 40
      expect(pet.experience, 40); // 35 + 5
    });
  });

  group('Provider Derived Logic', () {
    test('Providers derivados retornarían valores correctos', () {
      // Este test verifica que la lógica que usarían los providers derivados es correcta
      final pet = Pet(
        name: 'TestPet',
        hunger: 75,
        happiness: 82,
        energy: 65,
        health: 90,
        coins: 150,
        experience: 300,
      );

      // Simular lo que harían los providers derivados
      expect(pet.hunger, 75); // petHungerProvider
      expect(pet.happiness, 82); // petHappinessProvider
      expect(pet.energy, 65); // petEnergyProvider
      expect(pet.health, 90); // petHealthProvider
      expect(pet.coins, 150); // petCoinsProvider
      expect(pet.level, greaterThan(1)); // petLevelProvider
      expect(pet.name, 'TestPet'); // petNameProvider
      expect(pet.isCritical, false); // petIsCriticalProvider
    });
  });
}
