# AGENTS.md

This file provides guidelines for agentic coding assistants working on this Flutter Tamagotchi project.

## Build, Lint, and Test Commands

### Essential Commands
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/models/pet_test.dart

# Run tests with coverage report
flutter test --coverage

# Static analysis (must pass before commits)
flutter analyze

# Format code
dart format lib/ test/

# Check formatting (fails if changes needed)
dart format --set-exit-if-changed lib/ test/

# Complete lint check
make lint  # or: flutter analyze && dart format --set-exit-if-changed lib/ test/
```

### Quick Development Commands
```bash
# Install dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run in release mode (for Firebase Crashlytics testing)
flutter run --release

# Hot reload during development
# Press 'r' in terminal during flutter run

# Clean build cache
flutter clean

# Full project reset
make reset
```

## Code Style Guidelines

### File and Directory Structure
- **File names**: `snake_case.dart` (e.g., `pet_model.dart`, `storage_service.dart`)
- **Directory structure**: Follow existing lib/ organization:
  - `lib/models/` - Data models and entities
  - `lib/services/` - Business logic and services
  - `lib/screens/` - UI screens and navigation
  - `lib/widgets/` - Reusable UI components
  - `lib/config/` - App configuration and themes
  - `lib/utils/` - Utility functions and helpers

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `PetModel`, `StorageService`)
- **Methods**: `camelCase` (e.g., `fromJson()`, `updateLifeStage()`)
- **Variables**: `camelCase` (e.g., `lastFed`, `isCritical`)
- **Constants**: `snake_case` (e.g., `primaryColor`, `hungerColor`)
- **Private members**: `_underscorePrefix` (e.g., `_initializeServices()`)

### Import Organization
```dart
// Dart core imports first
import 'dart:ui';

// Flutter and package imports
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Relative imports from project
import 'config/theme.dart';
import 'screens/main_navigation.dart';
```

### Type System
- **Always specify types**: `String name` not `var name`
- **Use strong typing**: `List<PetModel>` not `List pets`
- **Nullable types**: `DateTime? birthDate` for optional fields
- **Type conversion**: Use proper casting with `as` keyword
- **Generics**: Always specify type parameters `Provider<PetModel>`

### Model Classes
All models must follow this pattern:
```dart
class Pet {
  // Required fields in constructor
  final String name;
  
  // Optional fields with defaults
  final double hunger;
  final int experience;
  
  // Constructor with named parameters and defaults
  Pet({
    required this.name,
    this.hunger = 0,
    this.experience = 0,
  });
  
  // JSON serialization
  Map<String, dynamic> toJson() => {
    'name': name,
    'hunger': hunger,
    'experience': experience,
  };
  
  // JSON deserialization
  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    name: json['name'] as String,
    hunger: (json['hunger'] as num).toDouble(),
    experience: json['experience'] as int? ?? 0,
  );
  
  // Immutable copy method
  Pet copyWith({
    String? name,
    double? hunger,
    int? experience,
  }) => Pet(
    name: name ?? this.name,
    hunger: hunger ?? this.hunger,
    experience: experience ?? this.experience,
  );
}
```

### Error Handling
```dart
// Use try-catch for async operations
try {
  await Firebase.initializeApp();
} catch (e) {
  logger.error('Failed to initialize Firebase: $e');
  rethrow;
}

// Validate inputs
void updateMetric(double value) {
  if (value < 0 || value > 100) {
    throw ArgumentError('Value must be between 0 and 100');
  }
  // ...
}

// Null safety with defaults
final name = json['name'] as String? ?? 'Unknown';
```

### Testing Guidelines
Follow the Arrange-Act-Assert pattern:
```dart
void main() {
  group('Pet Model Tests', () {
    test('creates Pet with default values', () {
      // Arrange
      const petName = 'TestPet';
      
      // Act
      final pet = Pet(name: petName);
      
      // Assert
      expect(pet.name, petName);
      expect(pet.hunger, 0);
      expect(pet.isAlive, true);
    });
  });
}
```

### State Management
- **Current pattern**: Using `Provider` with `StatefulWidget`
- **Migration target**: `Riverpod` (partially implemented)
- **Immutable state**: Always create new instances instead of mutating
- **State updates**: Use `copyWith()` for models, `setState()` for widgets

### Firebase Integration
- **Crashlytics**: Only works in release mode (`flutter run --release`)
- **Analytics**: Works in both debug and release
- **Testing**: Use mock services for unit tests

### Performance Guidelines
- **Background tasks**: Use `WorkManager` for periodic updates (every 15 minutes)
- **Persistence**: `SharedPreferences` with debounced saving (every 20 seconds)
- **Lazy loading**: Initialize heavy objects only when needed
- **Memory**: Cancel timers in `dispose()` methods

### Documentation
- **Public APIs**: Always include documentation comments
- **Complex logic**: Add explanatory comments for non-obvious code
- **TODOs**: Use `// TODO:` format for pending improvements

### Commit Guidelines
- Run `flutter analyze` and `dart format --set-exit-if-changed` before committing
- All tests must pass: `flutter test`
- No static analysis warnings allowed
- Follow existing commit message style from project history

## Project-Specific Notes

### Background Processing
- WorkManager runs every 15 minutes
- Only works on Android (iOS has restrictions)
- Updates metrics based on elapsed time

### Evolution System
- 5 life stages: Egg → Baby → Child → Teen → Adult
- 3 variants: Normal, Excellent, Neglected
- Experience-based leveling system

### Testing Requirements
- 600+ unit tests currently implemented
- Test coverage reports in `coverage/` directory
- Integration tests for persistence and background processing

This project uses the **flutter_lints** package with standard Flutter analysis rules. All code must pass static analysis without warnings.