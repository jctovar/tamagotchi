import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/life_stage.dart';

void main() {
  group('LifeStage Enum', () {
    test('has correct number of stages', () {
      expect(LifeStage.values.length, 5);
    });

    test('stages are in correct order', () {
      expect(LifeStage.values, [
        LifeStage.egg,
        LifeStage.baby,
        LifeStage.child,
        LifeStage.teen,
        LifeStage.adult,
      ]);
    });

    test('egg stage has index 0', () {
      expect(LifeStage.egg.index, 0);
    });

    test('adult stage has index 4', () {
      expect(LifeStage.adult.index, 4);
    });
  });

  group('LifeStageExtension - Display Names', () {
    test('egg stage has correct display name', () {
      expect(LifeStage.egg.displayName, 'Huevo');
    });

    test('baby stage has correct display name', () {
      expect(LifeStage.baby.displayName, 'Bebé');
    });

    test('child stage has correct display name', () {
      expect(LifeStage.child.displayName, 'Niño');
    });

    test('teen stage has correct display name', () {
      expect(LifeStage.teen.displayName, 'Adolescente');
    });

    test('adult stage has correct display name', () {
      expect(LifeStage.adult.displayName, 'Adulto');
    });
  });

  group('LifeStageExtension - Base Emojis', () {
    test('egg stage has correct emoji', () {
      expect(LifeStage.egg.baseEmoji, '🥚');
    });

    test('baby stage has correct emoji', () {
      expect(LifeStage.baby.baseEmoji, '🐣');
    });

    test('child stage has correct emoji', () {
      expect(LifeStage.child.baseEmoji, '🐥');
    });

    test('teen stage has correct emoji', () {
      expect(LifeStage.teen.baseEmoji, '🐤');
    });

    test('adult stage has correct emoji', () {
      expect(LifeStage.adult.baseEmoji, '🐦');
    });
  });

  group('LifeStageExtension - Time Requirements', () {
    test('egg stage requires 0 seconds', () {
      expect(LifeStage.egg.minTimeSeconds, 0);
    });

    test('baby stage requires 5 minutes (300 seconds)', () {
      expect(LifeStage.baby.minTimeSeconds, 300);
    });

    test('child stage requires 30 minutes (1800 seconds)', () {
      expect(LifeStage.child.minTimeSeconds, 1800);
    });

    test('teen stage requires 2 hours (7200 seconds)', () {
      expect(LifeStage.teen.minTimeSeconds, 7200);
    });

    test('adult stage requires 6 hours (21600 seconds)', () {
      expect(LifeStage.adult.minTimeSeconds, 21600);
    });

    test('time requirements are in ascending order', () {
      final times = LifeStage.values.map((stage) => stage.minTimeSeconds).toList();
      final sortedTimes = List<int>.from(times)..sort();
      expect(times, equals(sortedTimes));
    });
  });

  group('LifeStageExtension - Experience Requirements', () {
    test('egg stage requires 0 experience', () {
      expect(LifeStage.egg.requiredExperience, 0);
    });

    test('baby stage requires 100 experience', () {
      expect(LifeStage.baby.requiredExperience, 100);
    });

    test('child stage requires 500 experience', () {
      expect(LifeStage.child.requiredExperience, 500);
    });

    test('teen stage requires 1500 experience', () {
      expect(LifeStage.teen.requiredExperience, 1500);
    });

    test('adult stage requires 3000 experience', () {
      expect(LifeStage.adult.requiredExperience, 3000);
    });

    test('experience requirements are in ascending order', () {
      final xpRequirements = LifeStage.values.map((stage) => stage.requiredExperience).toList();
      final sortedXp = List<int>.from(xpRequirements)..sort();
      expect(xpRequirements, equals(sortedXp));
    });
  });

  group('LifeStageExtension - Next Stage', () {
    test('egg next stage is baby', () {
      expect(LifeStage.egg.nextStage, LifeStage.baby);
    });

    test('baby next stage is child', () {
      expect(LifeStage.baby.nextStage, LifeStage.child);
    });

    test('child next stage is teen', () {
      expect(LifeStage.child.nextStage, LifeStage.teen);
    });

    test('teen next stage is adult', () {
      expect(LifeStage.teen.nextStage, LifeStage.adult);
    });

    test('adult has no next stage', () {
      expect(LifeStage.adult.nextStage, isNull);
    });
  });

  group('LifeStageExtension - Colors', () {
    test('each stage has a unique color', () {
      final colors = LifeStage.values.map((stage) => stage.colorValue).toSet();
      expect(colors.length, LifeStage.values.length);
    });

    test('egg stage has gray color', () {
      expect(LifeStage.egg.colorValue, 0xFFE0E0E0);
    });

    test('baby stage has orange color', () {
      expect(LifeStage.baby.colorValue, 0xFFFFE0B2);
    });

    test('all colors are valid ARGB values', () {
      for (final stage in LifeStage.values) {
        expect(stage.colorValue, greaterThanOrEqualTo(0x00000000));
        expect(stage.colorValue, lessThanOrEqualTo(0xFFFFFFFF));
      }
    });
  });

  group('PetVariant Enum', () {
    test('has correct number of variants', () {
      expect(PetVariant.values.length, 3);
    });

    test('variants are in correct order', () {
      expect(PetVariant.values, [
        PetVariant.neglected,
        PetVariant.normal,
        PetVariant.excellent,
      ]);
    });
  });

  group('PetVariantExtension - Display Names', () {
    test('neglected variant has correct display name', () {
      expect(PetVariant.neglected.displayName, 'Descuidado');
    });

    test('normal variant has correct display name', () {
      expect(PetVariant.normal.displayName, 'Normal');
    });

    test('excellent variant has correct display name', () {
      expect(PetVariant.excellent.displayName, 'Excelente');
    });
  });

  group('PetVariantExtension - Modifiers', () {
    test('neglected variant has skull emoji', () {
      expect(PetVariant.neglected.modifier, '💀');
    });

    test('normal variant has bird emoji', () {
      expect(PetVariant.normal.modifier, '🐦');
    });

    test('excellent variant has eagle emoji', () {
      expect(PetVariant.excellent.modifier, '🦅');
    });

    test('each variant has unique modifier', () {
      final modifiers = PetVariant.values.map((v) => v.modifier).toSet();
      expect(modifiers.length, PetVariant.values.length);
    });
  });

  group('EvolutionUtils - calculateLifeStage', () {
    test('returns egg for new pet with no time or experience', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0,
        experience: 0,
      );
      expect(stage, LifeStage.egg);
    });

    test('prioritizes experience over time - baby stage', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0, // Not enough time
        experience: 100, // Enough XP for baby
      );
      expect(stage, LifeStage.baby);
    });

    test('prioritizes experience over time - adult stage', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 1000, // Not enough time for adult
        experience: 3000, // Enough XP for adult
      );
      expect(stage, LifeStage.adult);
    });

    test('uses time when experience is insufficient - baby stage', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 300, // 5 minutes - enough for baby
        experience: 50, // Not enough XP
      );
      expect(stage, LifeStage.baby);
    });

    test('uses time when experience is insufficient - child stage', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 1800, // 30 minutes - enough for child
        experience: 50, // Not enough XP (< 100 for baby)
      );
      expect(stage, LifeStage.child);
    });

    test('uses time when experience is insufficient - teen stage', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 7200, // 2 hours - enough for teen
        experience: 50, // Not enough XP (< 100 for baby)
      );
      expect(stage, LifeStage.teen);
    });

    test('uses time when experience is insufficient - adult stage', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 21600, // 6 hours - enough for adult
        experience: 50, // Not enough XP (< 100 for baby)
      );
      expect(stage, LifeStage.adult);
    });

    test('returns adult for maximum values', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 100000,
        experience: 10000,
      );
      expect(stage, LifeStage.adult);
    });

    test('experience threshold of 100 exactly gives baby', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0,
        experience: 100,
      );
      expect(stage, LifeStage.baby);
    });

    test('experience threshold of 500 exactly gives child', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0,
        experience: 500,
      );
      expect(stage, LifeStage.child);
    });

    test('experience threshold of 1500 exactly gives teen', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0,
        experience: 1500,
      );
      expect(stage, LifeStage.teen);
    });

    test('experience threshold of 3000 exactly gives adult', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0,
        experience: 3000,
      );
      expect(stage, LifeStage.adult);
    });

    test('99 experience gives egg (just below baby threshold)', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 0,
        experience: 99,
      );
      expect(stage, LifeStage.egg);
    });
  });

  group('EvolutionUtils - calculateVariant', () {
    test('returns excellent for high average metrics (>= 70)', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 90,
        avgHappiness: 85,
        avgEnergy: 95,
      );
      expect(variant, PetVariant.excellent);
    });

    test('returns excellent for exactly 70 average', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 70,
        avgHappiness: 70,
        avgEnergy: 70,
      );
      expect(variant, PetVariant.excellent);
    });

    test('returns normal for average metrics (40-69)', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 50,
        avgHappiness: 60,
        avgEnergy: 55,
      );
      expect(variant, PetVariant.normal);
    });

    test('returns normal for exactly 40 average', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 40,
        avgHappiness: 40,
        avgEnergy: 40,
      );
      expect(variant, PetVariant.normal);
    });

    test('returns neglected for low average metrics (< 40)', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 30,
        avgHappiness: 25,
        avgEnergy: 20,
      );
      expect(variant, PetVariant.neglected);
    });

    test('returns neglected for zero metrics', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 0,
        avgHappiness: 0,
        avgEnergy: 0,
      );
      expect(variant, PetVariant.neglected);
    });

    test('calculates average correctly - mixed high values', () {
      // Average: (100 + 80 + 90) / 3 = 90
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 100,
        avgHappiness: 80,
        avgEnergy: 90,
      );
      expect(variant, PetVariant.excellent);
    });

    test('calculates average correctly - boundary case at 69.9', () {
      // Average: (69 + 70 + 70) / 3 = 69.67 (should be normal)
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 69,
        avgHappiness: 70,
        avgEnergy: 70,
      );
      expect(variant, PetVariant.normal);
    });

    test('calculates average correctly - boundary case at 39.9', () {
      // Average: (39 + 40 + 40) / 3 = 39.67 (should be neglected)
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 39,
        avgHappiness: 40,
        avgEnergy: 40,
      );
      expect(variant, PetVariant.neglected);
    });

    test('handles maximum values', () {
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 100,
        avgHappiness: 100,
        avgEnergy: 100,
      );
      expect(variant, PetVariant.excellent);
    });
  });

  group('EvolutionUtils - getExperienceForAction', () {
    test('feed action gives 10 XP', () {
      expect(EvolutionUtils.getExperienceForAction('feed'), 10);
    });

    test('play action gives 15 XP', () {
      expect(EvolutionUtils.getExperienceForAction('play'), 15);
    });

    test('clean action gives 10 XP', () {
      expect(EvolutionUtils.getExperienceForAction('clean'), 10);
    });

    test('rest action gives 5 XP', () {
      expect(EvolutionUtils.getExperienceForAction('rest'), 5);
    });

    test('unknown action gives 0 XP', () {
      expect(EvolutionUtils.getExperienceForAction('unknown'), 0);
    });

    test('empty string gives 0 XP', () {
      expect(EvolutionUtils.getExperienceForAction(''), 0);
    });

    test('case sensitive - Feed gives 0 XP', () {
      expect(EvolutionUtils.getExperienceForAction('Feed'), 0);
    });

    test('random action gives 0 XP', () {
      expect(EvolutionUtils.getExperienceForAction('dance'), 0);
    });

    test('play gives most XP among actions', () {
      final xpValues = ['feed', 'play', 'clean', 'rest']
          .map((action) => EvolutionUtils.getExperienceForAction(action))
          .toList();
      expect(xpValues.reduce((a, b) => a > b ? a : b), 15);
    });
  });

  group('EvolutionUtils - calculateLevel', () {
    test('0 experience gives level 1', () {
      // (0 / 100).floor() + 1 = 0 + 1 = 1
      expect(EvolutionUtils.calculateLevel(0), 1);
    });

    test('50 experience gives level 1', () {
      // (50 / 100).floor() + 1 = 0 + 1 = 1
      expect(EvolutionUtils.calculateLevel(50), 1);
    });

    test('100 experience gives level 2', () {
      // (100 / 100).floor() + 1 = 1 + 1 = 2
      expect(EvolutionUtils.calculateLevel(100), 2);
    });

    test('200 experience gives level 3', () {
      // (200 / 100).floor() + 1 = 2 + 1 = 3
      expect(EvolutionUtils.calculateLevel(200), 3);
    });

    test('500 experience gives level 6', () {
      // (500 / 100).floor() + 1 = 5 + 1 = 6
      expect(EvolutionUtils.calculateLevel(500), 6);
    });

    test('1000 experience gives level 11', () {
      // (1000 / 100).floor() + 1 = 10 + 1 = 11
      expect(EvolutionUtils.calculateLevel(1000), 11);
    });

    test('10000 experience gives level 101', () {
      // (10000 / 100).floor() + 1 = 100 + 1 = 101
      expect(EvolutionUtils.calculateLevel(10000), 101);
    });

    test('level increases with experience', () {
      final level1 = EvolutionUtils.calculateLevel(100);
      final level2 = EvolutionUtils.calculateLevel(200);
      final level3 = EvolutionUtils.calculateLevel(300);

      expect(level2, greaterThan(level1));
      expect(level3, greaterThan(level2));
    });
  });

  group('EvolutionUtils - experienceForNextLevel', () {
    test('level 1 requires 100 XP for next level', () {
      expect(EvolutionUtils.experienceForNextLevel(1), 100);
    });

    test('level 2 requires 400 XP for next level', () {
      expect(EvolutionUtils.experienceForNextLevel(2), 400);
    });

    test('level 5 requires 2500 XP for next level', () {
      expect(EvolutionUtils.experienceForNextLevel(5), 2500);
    });

    test('level 10 requires 10000 XP for next level', () {
      expect(EvolutionUtils.experienceForNextLevel(10), 10000);
    });

    test('XP requirement increases quadratically', () {
      final xp1 = EvolutionUtils.experienceForNextLevel(1);
      final xp2 = EvolutionUtils.experienceForNextLevel(2);
      final xp3 = EvolutionUtils.experienceForNextLevel(3);

      expect(xp2 / xp1, greaterThan(1)); // Should grow faster than linear
      expect(xp3 / xp2, greaterThan(1));
    });

    test('formula matches level * level * 100', () {
      for (int level = 1; level <= 10; level++) {
        expect(
          EvolutionUtils.experienceForNextLevel(level),
          level * level * 100,
        );
      }
    });
  });

  group('EvolutionUtils - levelProgress', () {
    test('0 experience at level 1 gives 0 progress', () {
      final progress = EvolutionUtils.levelProgress(0, 1);
      expect(progress, 0.0);
    });

    test('50 experience at level 1 gives 0.5 progress', () {
      // Level 1: 0-100 XP, so 50 XP = 50% progress
      final progress = EvolutionUtils.levelProgress(50, 1);
      expect(progress, closeTo(0.5, 0.01));
    });

    test('100 experience at level 2 gives 0 progress', () {
      // Level 2 starts at 100 XP
      final progress = EvolutionUtils.levelProgress(100, 2);
      expect(progress, 0.0);
    });

    test('250 experience at level 2 gives 0.5 progress', () {
      // Level 2: 100-400 XP (300 range), so 250 = 150/300 = 0.5
      final progress = EvolutionUtils.levelProgress(250, 2);
      expect(progress, closeTo(0.5, 0.01));
    });

    test('progress is always between 0 and 1', () {
      for (int xp = 0; xp <= 1000; xp += 50) {
        final level = EvolutionUtils.calculateLevel(xp);
        final progress = EvolutionUtils.levelProgress(xp, level);
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      }
    });

    test('progress at exact level threshold is 0', () {
      // At exactly 100 XP (level 2 threshold), progress should be 0
      final progress = EvolutionUtils.levelProgress(100, 2);
      expect(progress, 0.0);
    });

    test('progress increases as experience increases within level', () {
      // Level 3 = 200 XP, Next level (4) = 1600 XP
      // Range: 400 - 900 XP (500 XP range)
      final level = 5;
      final progress1 = EvolutionUtils.levelProgress(1600, level); // Start of level 5
      final progress2 = EvolutionUtils.levelProgress(1800, level); // Middle
      final progress3 = EvolutionUtils.levelProgress(2000, level); // Further in

      expect(progress2, greaterThan(progress1));
      expect(progress3, greaterThan(progress2));
    });
  });

  group('EvolutionUtils - Integration Tests', () {
    test('progression from egg to adult through experience', () {
      final stages = [0, 100, 500, 1500, 3000].map((xp) =>
        EvolutionUtils.calculateLifeStage(totalTimeAlive: 0, experience: xp)
      ).toList();

      expect(stages, [
        LifeStage.egg,
        LifeStage.baby,
        LifeStage.child,
        LifeStage.teen,
        LifeStage.adult,
      ]);
    });

    test('progression from egg to adult through time', () {
      final stages = [0, 300, 1800, 7200, 21600].map((time) =>
        EvolutionUtils.calculateLifeStage(totalTimeAlive: time, experience: 0)
      ).toList();

      expect(stages, [
        LifeStage.egg,
        LifeStage.baby,
        LifeStage.child,
        LifeStage.teen,
        LifeStage.adult,
      ]);
    });

    test('variant changes with care quality', () {
      final variants = [
        [30, 25, 20], // Neglected
        [50, 55, 60], // Normal
        [90, 85, 95], // Excellent
      ].map((metrics) => EvolutionUtils.calculateVariant(
        avgHealth: metrics[0].toDouble(),
        avgHappiness: metrics[1].toDouble(),
        avgEnergy: metrics[2].toDouble(),
      )).toList();

      expect(variants, [
        PetVariant.neglected,
        PetVariant.normal,
        PetVariant.excellent,
      ]);
    });

    test('gaining XP through actions increases level', () {
      int totalXp = 0;
      final initialLevel = EvolutionUtils.calculateLevel(totalXp);

      // Perform 20 play actions (15 XP each)
      for (int i = 0; i < 20; i++) {
        totalXp += EvolutionUtils.getExperienceForAction('play');
      }

      final finalLevel = EvolutionUtils.calculateLevel(totalXp);
      expect(finalLevel, greaterThan(initialLevel));
      expect(totalXp, 300); // 20 * 15
    });
  });

  group('EvolutionUtils - Edge Cases', () {
    test('negative experience is handled', () {
      // (-100 / 100).floor() + 1 = -1 + 1 = 0
      final level = EvolutionUtils.calculateLevel(-100);
      expect(level, 0); // Formula allows negative, returns 0
    });

    test('very large experience values', () {
      final level = EvolutionUtils.calculateLevel(1000000);
      expect(level, greaterThan(0));
    });

    test('very large time values', () {
      final stage = EvolutionUtils.calculateLifeStage(
        totalTimeAlive: 999999999,
        experience: 0,
      );
      expect(stage, LifeStage.adult);
    });

    test('variant calculation with unbalanced metrics', () {
      // Very high health, very low others
      final variant = EvolutionUtils.calculateVariant(
        avgHealth: 100,
        avgHappiness: 10,
        avgEnergy: 10,
      );
      // Average = (100 + 10 + 10) / 3 = 40 -> normal
      expect(variant, PetVariant.normal);
    });
  });
}
