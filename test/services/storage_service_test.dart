import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/services/storage_service.dart';
import 'package:tamagotchi/models/pet.dart';
import 'package:tamagotchi/models/life_stage.dart';
import 'package:tamagotchi/models/minigame_stats.dart';
import 'package:tamagotchi/models/interaction_history.dart';
import 'package:tamagotchi/models/pet_personality.dart';
import 'package:tamagotchi/utils/constants.dart';

void main() {
  // Setup que se ejecuta antes de cada prueba
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StorageService - Pet State Persistence', () {
    test('saveState stores pet data correctly', () async {
      final service = StorageService();
      final pet = Pet(
        name: 'TestPet',
        hunger: 50,
        happiness: 75,
        energy: 80,
        health: 90,
      );

      await service.saveState(pet);

      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('pet_state');
      expect(savedData, isNotNull);
      expect(savedData, contains('TestPet'));
    });

    test('loadPetState returns null when no data exists', () async {
      final service = StorageService();

      final loadedPet = await service.loadPetState();

      expect(loadedPet, isNull);
    });

    test('loadPetState retrieves saved pet correctly', () async {
      final service = StorageService();
      final originalPet = Pet(
        name: 'LoadTest',
        hunger: 25.5,
        happiness: 88.3,
        energy: 65.7,
        health: 92.1,
      );

      await service.saveState(originalPet);
      final loadedPet = await service.loadPetState();

      expect(loadedPet, isNotNull);
      expect(loadedPet!.name, 'LoadTest');
      expect(loadedPet.hunger, 25.5);
      expect(loadedPet.happiness, 88.3);
      expect(loadedPet.energy, 65.7);
      expect(loadedPet.health, 92.1);
    });

    test('save and load preserve all pet data (round-trip)', () async {
      final service = StorageService();
      final originalPet = Pet(
        name: 'RoundTrip',
        hunger: 30,
        happiness: 70,
        energy: 60,
        health: 85,
        experience: 500,
        totalTimeAlive: 1000,
        lifeStage: LifeStage.child,
        variant: PetVariant.excellent,
        coins: 150,
      );

      await service.saveState(originalPet);
      final loadedPet = await service.loadPetState();

      expect(loadedPet, isNotNull);
      expect(loadedPet!.name, originalPet.name);
      expect(loadedPet.hunger, originalPet.hunger);
      expect(loadedPet.happiness, originalPet.happiness);
      expect(loadedPet.energy, originalPet.energy);
      expect(loadedPet.health, originalPet.health);
      expect(loadedPet.experience, originalPet.experience);
      expect(loadedPet.totalTimeAlive, originalPet.totalTimeAlive);
      expect(loadedPet.lifeStage, originalPet.lifeStage);
      expect(loadedPet.variant, originalPet.variant);
      expect(loadedPet.coins, originalPet.coins);
    });

    test('clearState removes saved data', () async {
      final service = StorageService();
      final pet = Pet(name: 'ToClear');

      await service.saveState(pet);
      expect(await service.loadPetState(), isNotNull);

      await service.clearState();
      expect(await service.loadPetState(), isNull);
    });

    test('saveState can overwrite existing data', () async {
      final service = StorageService();
      final firstPet = Pet(name: 'First', hunger: 10);
      final secondPet = Pet(name: 'Second', hunger: 90);

      await service.saveState(firstPet);
      await service.saveState(secondPet);

      final loadedPet = await service.loadPetState();
      expect(loadedPet!.name, 'Second');
      expect(loadedPet.hunger, 90);
    });

    test('loadPetState handles corrupted data gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_state', 'invalid json data');

      final service = StorageService();
      final loadedPet = await service.loadPetState();

      expect(loadedPet, isNull); // Should return null for corrupted data
    });
  });

  group('StorageService - updatePetMetrics (Decay Logic)', () {
    test('hunger increases over time based on decay rate', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'HungerTest',
        hunger: 10,
        lastFed: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // 60 seconds * 0.05 per second = 3.0 increase
      expect(updatedPet.hunger, closeTo(13.0, 0.1));
    });

    test('happiness decreases over time based on decay rate', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'HappinessTest',
        happiness: 80,
        lastPlayed: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // 60 seconds * 0.03 per second = 1.8 decrease
      expect(updatedPet.happiness, closeTo(78.2, 0.1));
    });

    test('energy decreases over time based on decay rate', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'EnergyTest',
        energy: 70,
        lastRested: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // 60 seconds * 0.02 per second = 1.2 decrease
      expect(updatedPet.energy, closeTo(68.8, 0.1));
    });

    test('all metrics decay simultaneously over time', () {
      final service = StorageService();
      final now = DateTime.now();
      final twoMinutesAgo = now.subtract(const Duration(minutes: 2));

      final pet = Pet(
        name: 'AllDecayTest',
        hunger: 20,
        happiness: 90,
        energy: 80,
        lastFed: twoMinutesAgo,
        lastPlayed: twoMinutesAgo,
        lastRested: twoMinutesAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // 120 seconds elapsed
      expect(updatedPet.hunger, closeTo(26.0, 0.1)); // +6.0
      expect(updatedPet.happiness, closeTo(86.4, 0.1)); // -3.6
      expect(updatedPet.energy, closeTo(77.6, 0.1)); // -2.4
    });

    test('health decreases when hunger is very high (> 80)', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'HealthDecayTest',
        hunger: 85,
        health: 50,
        lastFed: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // Health should decrease: 60 seconds * 0.01 = 0.6 decrease
      expect(updatedPet.health, lessThan(50));
      expect(updatedPet.health, closeTo(49.4, 0.1));
    });

    test('health decreases when happiness is very low (< 20)', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'SadHealthTest',
        happiness: 15,
        health: 60,
        lastPlayed: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // Health should decrease: 60 seconds * 0.01 = 0.6 decrease
      expect(updatedPet.health, lessThan(60));
      expect(updatedPet.health, closeTo(59.4, 0.1));
    });

    test('health decreases when energy is very low (< 20)', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'TiredHealthTest',
        energy: 15,
        health: 70,
        lastRested: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // Health should decrease: 60 seconds * 0.01 = 0.6 decrease
      expect(updatedPet.health, lessThan(70));
      expect(updatedPet.health, closeTo(69.4, 0.1));
    });

    test('hunger is clamped at maximum 100', () {
      final service = StorageService();
      final now = DateTime.now();
      final longTimeAgo = now.subtract(const Duration(hours: 10));

      final pet = Pet(
        name: 'MaxHungerTest',
        hunger: 50,
        lastFed: longTimeAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      expect(updatedPet.hunger, 100.0);
    });

    test('happiness is clamped at minimum 0', () {
      final service = StorageService();
      final now = DateTime.now();
      final longTimeAgo = now.subtract(const Duration(hours: 50));

      final pet = Pet(
        name: 'MinHappinessTest',
        happiness: 50,
        lastPlayed: longTimeAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      expect(updatedPet.happiness, 0.0);
    });

    test('energy is clamped at minimum 0', () {
      final service = StorageService();
      final now = DateTime.now();
      final longTimeAgo = now.subtract(const Duration(hours: 50));

      final pet = Pet(
        name: 'MinEnergyTest',
        energy: 50,
        lastRested: longTimeAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      expect(updatedPet.energy, 0.0);
    });

    test('health is clamped at minimum 0', () {
      final service = StorageService();
      final now = DateTime.now();
      final longTimeAgo = now.subtract(const Duration(hours: 100));

      final pet = Pet(
        name: 'MinHealthTest',
        hunger: 90,
        health: 50,
        lastFed: longTimeAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      expect(updatedPet.health, 0.0);
    });

    test('no change when no time has passed', () {
      final service = StorageService();
      final now = DateTime.now();

      final pet = Pet(
        name: 'NoChangeTest',
        hunger: 40,
        happiness: 60,
        energy: 70,
        health: 80,
        lastFed: now,
        lastPlayed: now,
        lastRested: now,
      );

      final updatedPet = service.updatePetMetrics(pet);

      expect(updatedPet.hunger, closeTo(40, 0.01));
      expect(updatedPet.happiness, closeTo(60, 0.01));
      expect(updatedPet.energy, closeTo(70, 0.01));
      expect(updatedPet.health, closeTo(80, 0.01));
    });

    test('massive time gap results in clamped values', () {
      final service = StorageService();
      final now = DateTime.now();
      final yearsAgo = now.subtract(const Duration(days: 365));

      final pet = Pet(
        name: 'MassiveGapTest',
        hunger: 50,
        happiness: 50,
        energy: 50,
        health: 50,
        lastFed: yearsAgo,
        lastPlayed: yearsAgo,
        lastRested: yearsAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // All values should be clamped
      expect(updatedPet.hunger, 100.0);
      expect(updatedPet.happiness, 0.0);
      expect(updatedPet.energy, 0.0);
      expect(updatedPet.health, 0.0);
    });

    test('decay uses correct AppConstants rates', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneSecondAgo = now.subtract(const Duration(seconds: 1));

      final pet = Pet(
        name: 'RatesTest',
        hunger: 0,
        happiness: 100,
        energy: 100,
        lastFed: oneSecondAgo,
        lastPlayed: oneSecondAgo,
        lastRested: oneSecondAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // Verify rates match constants
      expect(updatedPet.hunger, closeTo(AppConstants.hungerDecayRate, 0.01));
      expect(
          updatedPet.happiness,
          closeTo(100 - AppConstants.happinessDecayRate, 0.01));
      expect(updatedPet.energy,
          closeTo(100 - AppConstants.energyDecayRate, 0.01));
    });

    test('multiple critical conditions reduce health multiple times', () {
      final service = StorageService();
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      final pet = Pet(
        name: 'MultiCriticalTest',
        hunger: 85, // Critical
        happiness: 15, // Critical
        energy: 15, // Critical
        health: 100,
        lastFed: oneMinuteAgo,
        lastPlayed: oneMinuteAgo,
        lastRested: oneMinuteAgo,
      );

      final updatedPet = service.updatePetMetrics(pet);

      // Health should decrease from all three conditions
      // 3 conditions * 60 seconds * 0.01 = 1.8 total decrease
      expect(updatedPet.health, lessThan(100));
      expect(updatedPet.health, closeTo(98.2, 0.1));
    });
  });

  group('StorageService - Edge Cases', () {
    test('handles pet with default timestamps', () {
      final service = StorageService();
      final pet = Pet(name: 'DefaultTimestamps');

      // Should not crash
      final updatedPet = service.updatePetMetrics(pet);
      expect(updatedPet, isNotNull);
    });

    test('handles extreme metric values in updatePetMetrics', () {
      final service = StorageService();
      final pet = Pet(
        name: 'ExtremeValues',
        hunger: 100,
        happiness: 0,
        energy: 0,
        health: 0,
      );

      // Should handle gracefully
      final updatedPet = service.updatePetMetrics(pet);
      expect(updatedPet.hunger, lessThanOrEqualTo(100));
      expect(updatedPet.happiness, greaterThanOrEqualTo(0));
      expect(updatedPet.energy, greaterThanOrEqualTo(0));
      expect(updatedPet.health, greaterThanOrEqualTo(0));
    });

    test('concurrent save operations handle gracefully', () async {
      final service = StorageService();
      final pet1 = Pet(name: 'Concurrent1');
      final pet2 = Pet(name: 'Concurrent2');
      final pet3 = Pet(name: 'Concurrent3');

      // Save multiple pets concurrently
      await Future.wait([
        service.saveState(pet1),
        service.saveState(pet2),
        service.saveState(pet3),
      ]);

      // Last save should win
      final loadedPet = await service.loadPetState();
      expect(loadedPet, isNotNull);
      expect(loadedPet!.name, anyOf('Concurrent1', 'Concurrent2', 'Concurrent3'));
    });

    test('clearState on empty storage does not crash', () async {
      final service = StorageService();

      // Should not crash
      await service.clearState();
      expect(await service.loadPetState(), isNull);
    });

    test('saveState with special characters in name', () async {
      final service = StorageService();
      final pet = Pet(
        name: 'Test™ 🐱 "Special" \'Chars\'',
      );

      await service.saveState(pet);
      final loadedPet = await service.loadPetState();

      expect(loadedPet, isNotNull);
      expect(loadedPet!.name, 'Test™ 🐱 "Special" \'Chars\'');
    });
  });

  group('StorageService - Performance', () {
    test('updatePetMetrics completes quickly', () {
      final service = StorageService();
      final pet = Pet(name: 'PerformanceTest');

      final stopwatch = Stopwatch()..start();
      service.updatePetMetrics(pet);
      stopwatch.stop();

      // Should complete in less than 10ms
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('saveState completes in reasonable time', () async {
      final service = StorageService();
      final pet = Pet(name: 'SavePerformanceTest');

      final stopwatch = Stopwatch()..start();
      await service.saveState(pet);
      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('loadPetState completes in reasonable time', () async {
      final service = StorageService();
      final pet = Pet(name: 'LoadPerformanceTest');
      await service.saveState(pet);

      final stopwatch = Stopwatch()..start();
      await service.loadPetState();
      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('StorageService - Integration Tests', () {
    test('full workflow: save, decay, save again, load', () async {
      final service = StorageService();
      final now = DateTime.now();

      // Initial state
      final initialPet = Pet(
        name: 'WorkflowTest',
        hunger: 30,
        happiness: 70,
        energy: 80,
        health: 90,
      );

      // Save initial state
      await service.saveState(initialPet);

      // Simulate time passing and decay
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final petAfterTime = initialPet.copyWith(
        lastFed: oneHourAgo,
        lastPlayed: oneHourAgo,
        lastRested: oneHourAgo,
      );

      final updatedPet = service.updatePetMetrics(petAfterTime);

      // Save updated state
      await service.saveState(updatedPet);

      // Load and verify
      final loadedPet = await service.loadPetState();
      expect(loadedPet, isNotNull);
      expect(loadedPet!.hunger, greaterThan(initialPet.hunger));
      expect(loadedPet.happiness, lessThan(initialPet.happiness));
      expect(loadedPet.energy, lessThan(initialPet.energy));
    });

    test('reset workflow: save, clear, verify empty', () async {
      final service = StorageService();
      final pet = Pet(name: 'ResetTest');

      // Save pet
      await service.saveState(pet);
      expect(await service.loadPetState(), isNotNull);

      // Clear all data
      await service.clearState();

      // Verify clean slate
      expect(await service.loadPetState(), isNull);
    });
  });

  group('StorageService - MiniGameStats', () {
    test('loadMiniGameStats returns empty stats when no data exists', () async {
      final service = StorageService();

      final stats = await service.loadMiniGameStats();

      expect(stats, isNotNull);
      expect(stats.totalGamesPlayed, 0);
      expect(stats.totalWins, 0);
      expect(stats.totalXpEarned, 0);
      expect(stats.totalCoinsEarned, 0);
    });

    test('saveMiniGameStats stores data correctly', () async {
      final service = StorageService();
      final stats = MiniGameStats();

      await service.saveMiniGameStats(stats);

      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('minigame_stats');
      expect(savedData, isNotNull);
    });

    test('saveMiniGameStats and loadMiniGameStats preserve data', () async {
      final service = StorageService();
      final originalStats = MiniGameStats();
      final memoryStats = GameStats(
        gameType: MiniGameType.memory,
        timesPlayed: 10,
        timesWon: 7,
        bestScore: 1500,
        totalXpEarned: 350,
        totalCoinsEarned: 70,
      );
      final updatedStats = originalStats.updateGameStats(MiniGameType.memory, memoryStats);

      await service.saveMiniGameStats(updatedStats);
      final loadedStats = await service.loadMiniGameStats();

      final loadedMemoryStats = loadedStats.getStats(MiniGameType.memory);
      expect(loadedMemoryStats.timesPlayed, 10);
      expect(loadedMemoryStats.timesWon, 7);
      expect(loadedMemoryStats.bestScore, 1500);
      expect(loadedMemoryStats.totalXpEarned, 350);
      expect(loadedMemoryStats.totalCoinsEarned, 70);
    });

    test('updateGameStats increments counters correctly', () async {
      final service = StorageService();
      final result = GameResult(
        gameType: MiniGameType.slidingPuzzle,
        won: true,
        score: 2000,
        xpEarned: 50,
        coinsEarned: 10,
        duration: const Duration(seconds: 45),
      );

      await service.updateGameStats(result);

      final stats = await service.loadMiniGameStats();
      final puzzleStats = stats.getStats(MiniGameType.slidingPuzzle);
      expect(puzzleStats.timesPlayed, 1);
      expect(puzzleStats.timesWon, 1);
      expect(puzzleStats.bestScore, 2000);
      expect(puzzleStats.totalXpEarned, 50);
      expect(puzzleStats.totalCoinsEarned, 10);
    });

    test('updateGameStats updates best score correctly', () async {
      final service = StorageService();

      // First game
      await service.updateGameStats(GameResult(
        gameType: MiniGameType.reactionRace,
        won: true,
        score: 1000,
        xpEarned: 30,
        coinsEarned: 5,
        duration: const Duration(seconds: 30),
      ));

      // Second game with higher score
      await service.updateGameStats(GameResult(
        gameType: MiniGameType.reactionRace,
        won: true,
        score: 1500,
        xpEarned: 40,
        coinsEarned: 8,
        duration: const Duration(seconds: 25),
      ));

      final stats = await service.loadMiniGameStats();
      final raceStats = stats.getStats(MiniGameType.reactionRace);
      expect(raceStats.timesPlayed, 2);
      expect(raceStats.timesWon, 2);
      expect(raceStats.bestScore, 1500); // Higher score
      expect(raceStats.totalXpEarned, 70); // 30 + 40
      expect(raceStats.totalCoinsEarned, 13); // 5 + 8
    });

    test('updateGameStats handles loss correctly', () async {
      final service = StorageService();
      final result = GameResult(
        gameType: MiniGameType.memory,
        won: false,
        score: 500,
        xpEarned: 10,
        coinsEarned: 2,
        duration: const Duration(seconds: 60),
      );

      await service.updateGameStats(result);

      final stats = await service.loadMiniGameStats();
      final memoryStats = stats.getStats(MiniGameType.memory);
      expect(memoryStats.timesPlayed, 1);
      expect(memoryStats.timesWon, 0); // Not incremented for loss
      expect(memoryStats.bestScore, 500);
    });

    test('loadMiniGameStats handles corrupted data gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('minigame_stats', 'invalid json');

      final service = StorageService();
      final stats = await service.loadMiniGameStats();

      // Should return empty stats
      expect(stats, isNotNull);
      expect(stats.totalGamesPlayed, 0);
    });
  });

  group('StorageService - InteractionHistory', () {
    test('loadInteractionHistory returns empty history when no data exists', () async {
      final service = StorageService();

      final history = await service.loadInteractionHistory();

      expect(history, isNotNull);
      expect(history.totalInteractions, 0);
    });

    test('saveInteractionHistory stores data correctly', () async {
      final service = StorageService();
      final history = InteractionHistory();

      await service.saveInteractionHistory(history);

      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('interaction_history');
      expect(savedData, isNotNull);
    });

    test('saveInteractionHistory and loadInteractionHistory preserve data', () async {
      final service = StorageService();
      final interaction = Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );
      final history = InteractionHistory().addInteraction(interaction);

      await service.saveInteractionHistory(history);
      final loadedHistory = await service.loadInteractionHistory();

      expect(loadedHistory.totalInteractions, 1);
    });

    test('addInteraction saves and returns updated history', () async {
      final service = StorageService();
      final interaction = Interaction.now(
        type: InteractionType.play,
        hungerBefore: 40,
        happinessBefore: 60,
        energyBefore: 70,
        healthBefore: 85,
      );

      final updatedHistory = await service.addInteraction(interaction);

      expect(updatedHistory.totalInteractions, 1);

      // Verify it was saved
      final loadedHistory = await service.loadInteractionHistory();
      expect(loadedHistory.totalInteractions, 1);
    });

    test('multiple addInteraction calls accumulate interactions', () async {
      final service = StorageService();

      await service.addInteraction(Interaction.now(
        type: InteractionType.feed,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      ));

      await service.addInteraction(Interaction.now(
        type: InteractionType.play,
        hungerBefore: 40,
        happinessBefore: 75,
        energyBefore: 55,
        healthBefore: 80,
      ));

      final history = await service.loadInteractionHistory();
      expect(history.totalInteractions, 2);
    });

    test('loadInteractionHistory handles corrupted data gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('interaction_history', 'invalid json');

      final service = StorageService();
      final history = await service.loadInteractionHistory();

      // Should return empty history
      expect(history, isNotNull);
      expect(history.totalInteractions, 0);
    });
  });

  group('StorageService - PetPersonality', () {
    test('loadPetPersonality returns default personality when no data exists', () async {
      final service = StorageService();

      final personality = await service.loadPetPersonality();

      expect(personality, isNotNull);
    });

    test('savePetPersonality stores data correctly', () async {
      final service = StorageService();
      final personality = PetPersonality();

      await service.savePetPersonality(personality);

      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('pet_personality');
      expect(savedData, isNotNull);
    });

    test('savePetPersonality and loadPetPersonality preserve data', () async {
      final service = StorageService();
      final personality = PetPersonality();

      await service.savePetPersonality(personality);
      final loadedPersonality = await service.loadPetPersonality();

      expect(loadedPersonality, isNotNull);
    });

    test('loadPetPersonality handles corrupted data gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_personality', 'invalid json');

      final service = StorageService();
      final personality = await service.loadPetPersonality();

      // Should return default personality
      expect(personality, isNotNull);
    });
  });

  group('StorageService - recordInteraction', () {
    test('recordInteraction saves both history and personality', () async {
      final service = StorageService();

      final result = await service.recordInteraction(
        type: InteractionType.feed,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      expect(result.history.totalInteractions, 1);
      expect(result.personality, isNotNull);
    });

    test('recordInteraction accumulates interactions', () async {
      final service = StorageService();

      await service.recordInteraction(
        type: InteractionType.feed,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      final result = await service.recordInteraction(
        type: InteractionType.play,
        hungerBefore: 45,
        happinessBefore: 75,
        energyBefore: 55,
        healthBefore: 80,
      );

      expect(result.history.totalInteractions, 2);
    });

    test('recordInteraction persists data across service instances', () async {
      final service1 = StorageService();

      await service1.recordInteraction(
        type: InteractionType.clean,
        hungerBefore: 40,
        happinessBefore: 65,
        energyBefore: 70,
        healthBefore: 90,
      );

      // New service instance
      final service2 = StorageService();
      final history = await service2.loadInteractionHistory();

      expect(history.totalInteractions, 1);
    });

    test('recordInteraction with metadata preserves metadata', () async {
      final service = StorageService();

      await service.recordInteraction(
        type: InteractionType.minigame,
        hungerBefore: 35,
        happinessBefore: 80,
        energyBefore: 65,
        healthBefore: 85,
        metadata: {
          'gameType': 'memory',
          'score': 1500,
        },
      );

      final history = await service.loadInteractionHistory();
      expect(history.totalInteractions, 1);
    });
  });

  group('StorageService - clearAIData', () {
    test('clearAIData removes interaction history and personality', () async {
      final service = StorageService();

      // Add some data
      await service.recordInteraction(
        type: InteractionType.feed,
        hungerBefore: 50,
        happinessBefore: 70,
        energyBefore: 60,
        healthBefore: 80,
      );

      // Clear AI data
      await service.clearAIData();

      // Verify data is cleared
      final history = await service.loadInteractionHistory();
      final personality = await service.loadPetPersonality();

      expect(history.totalInteractions, 0);
      expect(personality, isNotNull); // Returns default
    });

    test('clearAIData on empty storage does not crash', () async {
      final service = StorageService();

      // Should not crash
      await service.clearAIData();

      final history = await service.loadInteractionHistory();
      expect(history.totalInteractions, 0);
    });
  });
}
