# Run Flutter App

Run the Flutter app on a connected device or emulator.

## Arguments
- `$ARGUMENTS` - Optional: device ID (chrome, macos, android, ios)

## Instructions

First, check available devices:

```bash
flutter devices
```

Then run the app:

```bash
flutter run -d $ARGUMENTS
```

If no device is specified and multiple devices are available, ask the user which device to use.

Remind the user:
- Press 'r' for hot reload
- Press 'R' for hot restart
- Press 'q' to quit
