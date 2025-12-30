import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/life_stage.dart';

void main() {
  group('Pet Model -', () {
    group('Constructor and Defaults', () {
      test('creates Pet with default values', () {
        final pet = Pet(name: 'TestPet');

        expect(pet.name, 'TestPet');
        expect(pet.hunger, 0);
        expect(pet.happiness, 100);
        expect(pet.energy, 100);
        expect(pet.health, 100);
        expect(pet.experience, 0);
        expect(pet.totalTimeAlive, 0);
        expect(pet.lifeStage, LifeStage.egg);
        expect(pet.variant, PetVariant.normal);
        expect(pet.coins, 0);
        expect(pet.lastFed, isNotNull);
        expect(pet.lastPlayed, isNotNull);
        expect(pet.lastCleaned, isNotNull);
        expect(pet.lastRested, isNotNull);
        expect(pet.birthDate, isNotNull);
      });

      test('creates Pet with custom values', () {
        final customDate = DateTime(2024, 1, 1);
        final pet = Pet(
          name: 'CustomPet',
          hunger: 50,
          happiness: 75,
          energy: 80,
          health: 90,
          lastFed: customDate,
          lastPlayed: customDate,
          lastCleaned: customDate,
          lastRested: customDate,
          experience: 500,
          totalTimeAlive: 1000,
          birthDate: customDate,
          lifeStage: LifeStage.child,
          variant: PetVariant.excellent,
          coins: 100,
        );

        expect(pet.name, 'CustomPet');
        expect(pet.hunger, 50);
        expect(pet.happiness, 75);
        expect(pet.energy, 80);
        expect(pet.health, 90);
        expect(pet.lastFed, customDate);
        expect(pet.lastPlayed, customDate);
        expect(pet.lastCleaned, customDate);
        expect(pet.lastRested, customDate);
        expect(pet.experience, 500);
        expect(pet.totalTimeAlive, 1000);
        expect(pet.birthDate, customDate);
        expect(pet.lifeStage, LifeStage.child);
        expect(pet.variant, PetVariant.excellent);
        expect(pet.coins, 100);
      });
    });

    group('Serialization (toJson/fromJson)', () {
      test('toJson converts Pet to Map correctly', () {
        final birthDate = DateTime(2024, 6, 15, 10, 30);
        final lastFed = DateTime(2024, 6, 15, 11, 0);
        final pet = Pet(
          name: 'SerializePet',
          hunger: 30,
          happiness: 80,
          energy: 70,
          health: 95,
          lastFed: lastFed,
          lastPlayed: lastFed,
          lastCleaned: lastFed,
          lastRested: lastFed,
          experience: 250,
          totalTimeAlive: 500,
          birthDate: birthDate,
          lifeStage: LifeStage.baby,
          variant: PetVariant.normal,
          coins: 50,
        );

        final json = pet.toJson();

        expect(json['name'], 'SerializePet');
        expect(json['hunger'], 30);
        expect(json['happiness'], 80);
        expect(json['energy'], 70);
        expect(json['health'], 95);
        expect(json['lastFed'], lastFed.toIso8601String());
        expect(json['lastPlayed'], lastFed.toIso8601String());
        expect(json['lastCleaned'], lastFed.toIso8601String());
        expect(json['lastRested'], lastFed.toIso8601String());
        expect(json['experience'], 250);
        expect(json['totalTimeAlive'], 500);
        expect(json['birthDate'], birthDate.toIso8601String());
        expect(json['lifeStage'], LifeStage.baby.index);
        expect(json['variant'], PetVariant.normal.index);
        expect(json['coins'], 50);
      });

      test('fromJson creates Pet from Map correctly', () {
        final birthDate = DateTime(2024, 6, 15, 10, 30);
        final lastFed = DateTime(2024, 6, 15, 11, 0);
        final json = {
          'name': 'DeserializePet',
          'hunger': 40.0,
          'happiness': 60.0,
          'energy': 50.0,
          'health': 85.0,
          'lastFed': lastFed.toIso8601String(),
          'lastPlayed': lastFed.toIso8601String(),
          'lastCleaned': lastFed.toIso8601String(),
          'lastRested': lastFed.toIso8601String(),
          'experience': 300,
          'totalTimeAlive': 600,
          'birthDate': birthDate.toIso8601String(),
          'lifeStage': LifeStage.child.index,
          'variant': PetVariant.excellent.index,
          'coins': 75,
        };

        final pet = Pet.fromJson(json);

        expect(pet.name, 'DeserializePet');
        expect(pet.hunger, 40.0);
        expect(pet.happiness, 60.0);
        expect(pet.energy, 50.0);
        expect(pet.health, 85.0);
        expect(pet.lastFed, lastFed);
        expect(pet.lastPlayed, lastFed);
        expect(pet.lastCleaned, lastFed);
        expect(pet.lastRested, lastFed);
        expect(pet.experience, 300);
        expect(pet.totalTimeAlive, 600);
        expect(pet.birthDate, birthDate);
        expect(pet.lifeStage, LifeStage.child);
        expect(pet.variant, PetVariant.excellent);
        expect(pet.coins, 75);
      });

      test('fromJson handles missing optional fields with defaults', () {
        final json = {
          'name': 'MinimalPet',
          'hunger': 0.0,
          'happiness': 100.0,
          'energy': 100.0,
          'health': 100.0,
          'lastFed': DateTime.now().toIso8601String(),
          'lastPlayed': DateTime.now().toIso8601String(),
          'lastCleaned': DateTime.now().toIso8601String(),
          'lastRested': DateTime.now().toIso8601String(),
        };

        final pet = Pet.fromJson(json);

        expect(pet.name, 'MinimalPet');
        expect(pet.experience, 0);
        expect(pet.totalTimeAlive, 0);
        expect(pet.lifeStage, LifeStage.egg);
        expect(pet.variant, PetVariant.normal);
        expect(pet.coins, 0);
      });

      test('toJson and fromJson preserve all data (round-trip)', () {
        final original = Pet(
          name: 'RoundTripPet',
          hunger: 25.5,
          happiness: 88.3,
          energy: 65.7,
          health: 92.1,
          experience: 1234,
          totalTimeAlive: 5678,
          lifeStage: LifeStage.teen,
          variant: PetVariant.excellent,
          coins: 999,
        );

        final json = original.toJson();
        final restored = Pet.fromJson(json);

        expect(restored.name, original.name);
        expect(restored.hunger, original.hunger);
        expect(restored.happiness, original.happiness);
        expect(restored.energy, original.energy);
        expect(restored.health, original.health);
        expect(restored.experience, original.experience);
        expect(restored.totalTimeAlive, original.totalTimeAlive);
        expect(restored.lifeStage, original.lifeStage);
        expect(restored.variant, original.variant);
        expect(restored.coins, original.coins);
      });
    });

    group('Mood Calculation', () {
      test('returns happy when happiness > 70 and health > 70', () {
        final pet = Pet(
          name: 'HappyPet',
          happiness: 80,
          health: 75,
          hunger: 20,
          energy: 60,
        );

        expect(pet.mood, PetMood.happy);
      });

      test('returns critical when health < 30', () {
        final pet = Pet(
          name: 'CriticalPet',
          health: 25,
          happiness: 100,
          hunger: 0,
          energy: 100,
        );

        expect(pet.mood, PetMood.critical);
      });

      test('returns critical when hunger > 80', () {
        final pet = Pet(
          name: 'StarvingPet',
          hunger: 85,
          health: 100,
          happiness: 100,
          energy: 100,
        );

        expect(pet.mood, PetMood.critical);
      });

      test('returns critical when energy < 20', () {
        final pet = Pet(
          name: 'ExhaustedPet',
          energy: 15,
          health: 100,
          happiness: 100,
          hunger: 0,
        );

        expect(pet.mood, PetMood.critical);
      });

      test('returns sad when happiness < 30', () {
        final pet = Pet(
          name: 'SadPet',
          happiness: 25,
          health: 50,
          hunger: 40,
          energy: 50,
        );

        expect(pet.mood, PetMood.sad);
      });

      test('returns hungry when hunger > 60', () {
        final pet = Pet(
          name: 'HungryPet',
          hunger: 70,
          happiness: 50,
          health: 50,
          energy: 50,
        );

        expect(pet.mood, PetMood.hungry);
      });

      test('returns tired when energy < 40', () {
        final pet = Pet(
          name: 'TiredPet',
          energy: 35,
          happiness: 50,
          health: 50,
          hunger: 30,
        );

        expect(pet.mood, PetMood.tired);
      });

      test('returns neutral when no special conditions are met', () {
        final pet = Pet(
          name: 'NeutralPet',
          happiness: 50,
          health: 50,
          hunger: 40,
          energy: 50,
        );

        expect(pet.mood, PetMood.neutral);
      });

      test('critical state has priority over other moods', () {
        final pet = Pet(
          name: 'CriticalButHappyPet',
          health: 25, // Critical
          happiness: 90, // Would be happy
          hunger: 10,
          energy: 90,
        );

        expect(pet.mood, PetMood.critical);
      });
    });

    group('Status Getters', () {
      test('isCritical returns true when mood is critical', () {
        final pet = Pet(
          name: 'CriticalPet',
          health: 20,
        );

        expect(pet.isCritical, isTrue);
      });

      test('isCritical returns false when mood is not critical', () {
        final pet = Pet(
          name: 'HealthyPet',
          health: 100,
        );

        expect(pet.isCritical, isFalse);
      });

      test('isAlive returns true when health > 0', () {
        final pet = Pet(
          name: 'AlivePet',
          health: 1,
        );

        expect(pet.isAlive, isTrue);
      });

      test('isAlive returns false when health is 0', () {
        final pet = Pet(
          name: 'DeadPet',
          health: 0,
        );

        expect(pet.isAlive, isFalse);
      });
    });

    group('Evolution System', () {
      test('gainExperience increases experience by correct amount for feed', () {
        final pet = Pet(name: 'TestPet', experience: 100);
        final updatedPet = pet.gainExperience('feed');

        expect(updatedPet.experience, 110); // 100 + 10
      });

      test('gainExperience increases experience by correct amount for play', () {
        final pet = Pet(name: 'TestPet', experience: 100);
        final updatedPet = pet.gainExperience('play');

        expect(updatedPet.experience, 115); // 100 + 15
      });

      test('gainExperience increases experience by correct amount for clean', () {
        final pet = Pet(name: 'TestPet', experience: 100);
        final updatedPet = pet.gainExperience('clean');

        expect(updatedPet.experience, 110); // 100 + 10
      });

      test('gainExperience increases experience by correct amount for rest', () {
        final pet = Pet(name: 'TestPet', experience: 100);
        final updatedPet = pet.gainExperience('rest');

        expect(updatedPet.experience, 105); // 100 + 5
      });

      test('gainExperience returns 0 for unknown action', () {
        final pet = Pet(name: 'TestPet', experience: 100);
        final updatedPet = pet.gainExperience('unknown');

        expect(updatedPet.experience, 100); // No change
      });

      test('updateLifeStage updates to correct stage based on experience', () {
        final birthDate = DateTime.now().subtract(const Duration(hours: 1));
        final pet = Pet(
          name: 'TestPet',
          experience: 500, // Enough for child stage
          birthDate: birthDate,
          lifeStage: LifeStage.egg,
        );

        final updatedPet = pet.updateLifeStage();

        expect(updatedPet.lifeStage, LifeStage.child);
      });

      test('updateVariant updates to excellent for high metrics', () {
        final pet = Pet(
          name: 'TestPet',
          health: 90,
          happiness: 85,
          energy: 95,
          variant: PetVariant.normal,
        );

        final updatedPet = pet.updateVariant();

        expect(updatedPet.variant, PetVariant.excellent);
      });

      test('updateVariant updates to neglected for low metrics', () {
        final pet = Pet(
          name: 'TestPet',
          health: 30,
          happiness: 25,
          energy: 20,
          variant: PetVariant.normal,
        );

        final updatedPet = pet.updateVariant();

        expect(updatedPet.variant, PetVariant.neglected);
      });

      test('updateVariant keeps normal for average metrics', () {
        final pet = Pet(
          name: 'TestPet',
          health: 50,
          happiness: 55,
          energy: 60,
          variant: PetVariant.excellent,
        );

        final updatedPet = pet.updateVariant();

        expect(updatedPet.variant, PetVariant.normal);
      });

      test('level getter calculates correct level from experience', () {
        final pet = Pet(name: 'TestPet', experience: 500);

        expect(pet.level, 6); // (500 / 100).floor() + 1
      });

      test('experienceForNextLevel returns correct value', () {
        final pet = Pet(name: 'TestPet', experience: 500); // Level 6

        expect(pet.experienceForNextLevel, 3600); // 6 * 6 * 100
      });

      test('levelProgress returns value between 0 and 1', () {
        final pet = Pet(name: 'TestPet', experience: 250);

        final progress = pet.levelProgress;

        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new Pet with updated name', () {
        final original = Pet(name: 'OriginalName');
        final updated = original.copyWith(name: 'NewName');

        expect(updated.name, 'NewName');
        expect(original.name, 'OriginalName'); // Original unchanged
      });

      test('copyWith creates new Pet with updated metrics', () {
        final original = Pet(
          name: 'TestPet',
          hunger: 10,
          happiness: 90,
          energy: 80,
          health: 100,
        );

        final updated = original.copyWith(
          hunger: 50,
          happiness: 60,
          energy: 40,
          health: 70,
        );

        expect(updated.hunger, 50);
        expect(updated.happiness, 60);
        expect(updated.energy, 40);
        expect(updated.health, 70);
        expect(original.hunger, 10); // Original unchanged
      });

      test('copyWith creates new Pet with updated evolution data', () {
        final original = Pet(
          name: 'TestPet',
          experience: 100,
          totalTimeAlive: 500,
          lifeStage: LifeStage.egg,
          variant: PetVariant.normal,
        );

        final updated = original.copyWith(
          experience: 600,
          totalTimeAlive: 2000,
          lifeStage: LifeStage.teen,
          variant: PetVariant.excellent,
        );

        expect(updated.experience, 600);
        expect(updated.totalTimeAlive, 2000);
        expect(updated.lifeStage, LifeStage.teen);
        expect(updated.variant, PetVariant.excellent);
      });

      test('copyWith preserves unchanged fields', () {
        final original = Pet(
          name: 'TestPet',
          hunger: 10,
          happiness: 90,
          experience: 500,
        );

        final updated = original.copyWith(hunger: 30);

        expect(updated.hunger, 30);
        expect(updated.happiness, 90); // Unchanged
        expect(updated.experience, 500); // Unchanged
        expect(updated.name, 'TestPet'); // Unchanged
      });

      test('copyWith with no parameters creates identical copy', () {
        final original = Pet(
          name: 'TestPet',
          hunger: 25,
          happiness: 75,
          experience: 300,
        );

        final copy = original.copyWith();

        expect(copy.name, original.name);
        expect(copy.hunger, original.hunger);
        expect(copy.happiness, original.happiness);
        expect(copy.experience, original.experience);
      });

      test('copyWith updates coins correctly', () {
        final original = Pet(name: 'TestPet', coins: 50);
        final updated = original.copyWith(coins: 150);

        expect(updated.coins, 150);
        expect(original.coins, 50);
      });
    });

    group('Edge Cases', () {
      test('handles extreme values for metrics', () {
        final pet = Pet(
          name: 'ExtremePet',
          hunger: 100,
          happiness: 0,
          energy: 0,
          health: 0,
        );

        expect(pet.hunger, 100);
        expect(pet.happiness, 0);
        expect(pet.energy, 0);
        expect(pet.health, 0);
        expect(pet.isAlive, isFalse);
      });

      test('handles negative experience gracefully in level calculation', () {
        final pet = Pet(name: 'TestPet', experience: 0);

        expect(pet.level, 1); // Minimum level
      });

      test('mood calculation prioritizes critical conditions', () {
        final pet = Pet(
          name: 'MultiConditionPet',
          health: 25, // Critical
          hunger: 70, // Hungry
          energy: 30, // Tired
          happiness: 20, // Sad
        );

        expect(pet.mood, PetMood.critical); // Critical has highest priority
      });
    });
  });
}
