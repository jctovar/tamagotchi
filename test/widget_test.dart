import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/screens/onboarding_screen.dart';

void main() {
  // Setup que se ejecuta antes de cada prueba
  setUp(() {
    // Limpiar SharedPreferences antes de cada prueba
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingScreen Static Methods', () {
    test('hasSeenOnboarding returns false when not set', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await OnboardingScreen.hasSeenOnboarding();

      expect(result, isFalse);
    });

    test('hasSeenOnboarding returns false explicitly when set to false',
        () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': false,
      });

      final result = await OnboardingScreen.hasSeenOnboarding();

      expect(result, isFalse);
    });

    test('hasSeenOnboarding returns true when set to true', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final result = await OnboardingScreen.hasSeenOnboarding();

      expect(result, isTrue);
    });

    test('setOnboardingComplete sets the preference to true', () async {
      SharedPreferences.setMockInitialValues({});

      // Initially should be false
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isNull);

      // Set onboarding complete
      await OnboardingScreen.setOnboardingComplete();

      // Should now be true
      prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    test('setOnboardingComplete overwrites existing false value', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': false,
      });

      await OnboardingScreen.setOnboardingComplete();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    test('setOnboardingComplete is idempotent', () async {
      SharedPreferences.setMockInitialValues({});

      // Call multiple times
      await OnboardingScreen.setOnboardingComplete();
      await OnboardingScreen.setOnboardingComplete();
      await OnboardingScreen.setOnboardingComplete();

      // Should still be true
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });
  });

  group('OnboardingScreen State Flow', () {
    test('new user flow: false -> complete -> true', () async {
      SharedPreferences.setMockInitialValues({});

      // New user
      var hasSeenOnboarding = await OnboardingScreen.hasSeenOnboarding();
      expect(hasSeenOnboarding, isFalse);

      // Complete onboarding
      await OnboardingScreen.setOnboardingComplete();

      // Returning user
      hasSeenOnboarding = await OnboardingScreen.hasSeenOnboarding();
      expect(hasSeenOnboarding, isTrue);
    });

    test('returning user sees onboarding as completed', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final hasSeenOnboarding = await OnboardingScreen.hasSeenOnboarding();
      expect(hasSeenOnboarding, isTrue);
    });
  });

  group('SharedPreferences Integration', () {
    test('onboarding key is correctly stored in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      await OnboardingScreen.setOnboardingComplete();

      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      expect(allKeys.contains('has_seen_onboarding'), isTrue);
    });

    test('hasSeenOnboarding handles null value gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'some_other_key': 'value',
      });

      // Key doesn't exist, should return false
      final result = await OnboardingScreen.hasSeenOnboarding();
      expect(result, isFalse);
    });
  });

  group('Edge Cases', () {
    test('concurrent calls to setOnboardingComplete are handled', () async {
      SharedPreferences.setMockInitialValues({});

      // Call concurrently
      await Future.wait([
        OnboardingScreen.setOnboardingComplete(),
        OnboardingScreen.setOnboardingComplete(),
        OnboardingScreen.setOnboardingComplete(),
      ]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    test('hasSeenOnboarding called multiple times returns consistent result',
        () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final results = await Future.wait([
        OnboardingScreen.hasSeenOnboarding(),
        OnboardingScreen.hasSeenOnboarding(),
        OnboardingScreen.hasSeenOnboarding(),
      ]);

      expect(results, everyElement(isTrue));
    });
  });

  group('Performance Tests', () {
    test('hasSeenOnboarding completes quickly', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final stopwatch = Stopwatch()..start();
      await OnboardingScreen.hasSeenOnboarding();
      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('setOnboardingComplete completes quickly', () async {
      SharedPreferences.setMockInitialValues({});

      final stopwatch = Stopwatch()..start();
      await OnboardingScreen.setOnboardingComplete();
      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Data Persistence', () {
    test('onboarding completion persists across multiple checks', () async {
      SharedPreferences.setMockInitialValues({});

      // Complete onboarding
      await OnboardingScreen.setOnboardingComplete();

      // Check multiple times - should stay true
      for (int i = 0; i < 10; i++) {
        final result = await OnboardingScreen.hasSeenOnboarding();
        expect(result, isTrue, reason: 'Check $i failed');
      }
    });

    test('can read value set directly in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);

      // Should be readable through the static method
      final result = await OnboardingScreen.hasSeenOnboarding();
      expect(result, isTrue);
    });
  });

  group('Boolean Logic', () {
    test('null value is treated as false', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await OnboardingScreen.hasSeenOnboarding();
      expect(result, isFalse);
      expect(result, isNot(isTrue));
    });

    test('true value returns true', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final result = await OnboardingScreen.hasSeenOnboarding();
      expect(result, isTrue);
      expect(result, isNot(isFalse));
    });

    test('false value returns false', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': false,
      });

      final result = await OnboardingScreen.hasSeenOnboarding();
      expect(result, isFalse);
      expect(result, isNot(isTrue));
    });
  });

  group('Async Behavior', () {
    test('hasSeenOnboarding is properly async', () {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final future = OnboardingScreen.hasSeenOnboarding();
      expect(future, isA<Future<bool>>());
    });

    test('setOnboardingComplete is properly async', () {
      SharedPreferences.setMockInitialValues({});

      final future = OnboardingScreen.setOnboardingComplete();
      expect(future, isA<Future<void>>());
    });

    test('multiple async operations complete in order', () async {
      SharedPreferences.setMockInitialValues({});

      final results = <bool>[];

      // Check (should be false)
      results.add(await OnboardingScreen.hasSeenOnboarding());

      // Set complete
      await OnboardingScreen.setOnboardingComplete();

      // Check again (should be true)
      results.add(await OnboardingScreen.hasSeenOnboarding());

      expect(results, [false, true]);
    });
  });
}
