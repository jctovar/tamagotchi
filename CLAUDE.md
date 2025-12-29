# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based Tamagotchi virtual pet application for Android that simulates caring for a digital pet. The app includes mechanics like feeding, playing, health monitoring, and state persistence to keep the pet "alive" even when the app is closed.

## Development Commands

### Setup and Dependencies
```bash
flutter pub get                    # Install dependencies
flutter pub upgrade                # Upgrade dependencies
```

### Running the Application
```bash
flutter run                        # Run on connected device/emulator
flutter run -d <device-id>         # Run on specific device
flutter run --release              # Run in release mode
```

### Testing
```bash
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run a specific test file
flutter test --coverage            # Run tests with coverage report
```

### Code Quality
```bash
flutter analyze                    # Run static analysis
flutter pub outdated               # Check for outdated packages
```

### Building
```bash
flutter build apk                  # Build Android APK
flutter build appbundle            # Build Android App Bundle
flutter build apk --release        # Build release APK
```

### Hot Reload
- Press `r` in the terminal during `flutter run` for hot reload
- Press `R` for hot restart (resets app state)

## Architecture and Design Patterns

### Core Functionality (per README.md)

The app is designed around continuous pet simulation with these key architectural components:

**State Management Architecture:**
- Pet state must persist across app closures using local storage (planned: `shared_preferences` or `Hive`)
- State includes metrics like hunger, happiness, energy, and health
- Timestamp-based calculations to update pet state when app reopens (e.g., time since last feeding)

**Background Processing:**
- Android: Use `WorkManager` for periodic OS-level tasks that survive app closure
- Background tasks update pet metrics (e.g., increase hunger every 15 minutes)
- Isolates for intensive computations without blocking UI
- iOS has more restrictions on background tasks

**Timer-Based Updates:**
- `Timer.periodic` handles foreground metric updates
- Metrics like hunger/happiness decay naturally over time
- Critical state changes trigger notifications

**Notification System:**
- Push notifications for reminders when pet needs attention
- Alerts for critical states (e.g., "Your pet is hungry")
- Integration planned with `firebase_messaging` or `flutter_local_notifications`

### Planned Core Functions

Based on README.md, these are the essential functions to implement:

- `initApp()`: Initialize state, timers, and background services
- `loadPetState()`: Load persistent data and timestamps
- `updateMood()`: Calculate mood based on elapsed time
- `feedPet()`: Update hunger state, set happy mood, save changes
- `playWithPet()`: Improve happiness, update timestamps, trigger animations
- `saveState()`: Persist data to local storage
- `startBackgroundTimer()`: Configure periodic background tasks
- `handleNotifications()`: Send push alerts for critical states
- `disposeResources()`: Clean up timers and services

### Feature Requirements

**Must-Have Features:**
- Routine care actions: feed, clean, play, rest
- Real-time state monitoring: hunger, happiness, energy, health
- Pet customization: naming, appearance changes
- Visual feedback with animations
- Push notifications for care reminders
- State persistence across sessions

**Optional Advanced Features:**
- AI-driven adaptive behaviors using TensorFlow Lite
- Mini-games for rewards (using Flame engine)
- AR integration with ARCore/ARKit
- Social features and multiplayer
- Pet evolution through life stages

## Project Structure

```
lib/
  main.dart           # Entry point with boilerplate Flutter app
test/
  widget_test.dart    # Basic widget test example
android/              # Android-specific configuration
ios/                  # iOS-specific configuration (future)
```

## Important Notes

### Current State
- The project currently contains only Flutter's default counter app boilerplate
- Main implementation following the README.md architecture has not yet begun
- No state management, background processing, or persistence is currently implemented

### When Implementing Features
- Background tasks on Android require WorkManager plugin
- State persistence should use `shared_preferences` or `Hive`
- Use `flutter_bloc` or similar for reactive state management
- Animations can use Flutter's built-in animation framework
- Consider battery optimization for background timer intervals

### Linting
- Uses `package:flutter_lints/flutter.yaml` for recommended Flutter lints
- Run `flutter analyze` before committing changes
