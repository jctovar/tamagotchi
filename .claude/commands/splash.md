# Generate Splash Screens

Generate animated splash screen using Flame engine.

## Instructions

El proyecto usa `flame_splash_screen` en lugar de `flutter_native_splash`.

La configuración del splash screen se hace mediante código en `lib/main.dart`:

```dart
import 'package:flame_splash_screen/flame_splash_screen.dart';

// Ver implementación completa en lib/main.dart
// Clase AppInitializer
```

## Configuración Actual

El splash screen está configurado con:
- Tema blanco de Flame
- Fondo rosa (#FFB5C0)
- Transición automática a onboarding o pantalla principal
- Animación del logo de Flame

## Características

- ✅ Animación fluida con Flame engine
- ✅ Logo animado
- ✅ Transición suave a la app
- ✅ Compatible con Android e iOS
- ✅ Sin necesidad de generar assets nativos

## Personalización

Para personalizar el splash screen, edita la clase `AppInitializer` en `lib/main.dart`:

```dart
FlameSplashScreen(
  theme: FlameSplashTheme.white,  // o FlameSplashTheme.dark
  onFinish: (context) async {
    // Tu lógica de navegación
  },
)
```

### Opciones de Personalización

1. **Cambiar color de fondo**: Envuelve en un `Container` con color
2. **Agregar logo personalizado**: Usa el parámetro `showBefore`
3. **Ajustar timing**: Usa `FlameSplashController`

## Nota Importante

No se requiere comando CLI para generar el splash screen. Todo está integrado directamente en la aplicación mediante código.
