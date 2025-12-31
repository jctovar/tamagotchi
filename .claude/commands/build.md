# Build Flutter App

Build the Flutter app for the specified platform.

## Arguments
- `$ARGUMENTS` - Platform to build for (apk, appbundle, ios, macos, web)

## Instructions

Run the appropriate Flutter build command based on the platform specified:

```bash
flutter build $ARGUMENTS
```

If no platform is specified, ask the user which platform they want to build for:
- `apk` - Android APK
- `appbundle` - Android App Bundle (for Play Store)
- `ios` - iOS
- `macos` - macOS
- `web` - Web

After the build completes, report the output location and any warnings or errors.
