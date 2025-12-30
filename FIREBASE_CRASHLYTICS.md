# Firebase Crashlytics - Guía de Integración

## 📋 Descripción

Firebase Crashlytics es un servicio de reporte de errores en tiempo real que ayuda a rastrear, priorizar y corregir problemas de estabilidad que afectan la calidad de la aplicación.

## ✅ Estado de la Integración

### Configuración Completada

#### 1. Dependencias (pubspec.yaml)
```yaml
dependencies:
  firebase_core: ^4.3.0
  firebase_crashlytics: ^5.0.6
```

#### 2. Configuración de Android

**Archivo:** `android/settings.gradle.kts`
```kotlin
plugins {
    id("com.google.gms.google-services") version("4.3.15") apply false
    id("com.google.firebase.crashlytics") version("3.0.2") apply false  // ✅ Agregado
}
```

**Archivo:** `android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")                    // ✅ Google Services
    id("com.google.firebase.crashlytics")                   // ✅ Crashlytics
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

#### 3. Inicialización en la App (lib/main.dart)

```dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Configurar Crashlytics para capturar errores de Flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // ✅ Capturar errores asíncronos no manejados
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Otros servicios...
  await NotificationService.initialize();
  await BackgroundService.initialize();

  // ✅ Ejecutar app dentro de zona de errores
  runZonedGuarded(
    () => runApp(const TamagotchiApp()),
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
```

## 🎯 Tipos de Errores Capturados

### 1. Errores Fatales de Flutter
Errores que causan que la app se cierre o entre en un estado inválido:
```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

**Ejemplos capturados:**
- Widgets que lanzan excepciones durante build
- Errores en el árbol de widgets
- Estados inválidos en StatefulWidgets

### 2. Errores Asíncronos No Manejados
Errores en Futures y async/await que no tienen try-catch:
```dart
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

**Ejemplos capturados:**
- Errores en peticiones HTTP sin manejo
- Errores en operaciones de base de datos
- Timeouts no manejados

### 3. Errores en Zonas de Ejecución
Cualquier error que ocurra dentro de la zona principal de la app:
```dart
runZonedGuarded(
  () => runApp(const TamagotchiApp()),
  (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  },
);
```

**Ejemplos capturados:**
- Errores de inicialización
- Excepciones no capturadas en callbacks
- Errores en plugins nativos

## 🧪 Cómo Probar la Integración

### 1. Forzar un Crash de Prueba

Agrega este botón temporal en cualquier pantalla:

```dart
ElevatedButton(
  onPressed: () {
    // Forzar un crash fatal
    FirebaseCrashlytics.instance.crash();
  },
  child: const Text('Test Crash'),
)
```

### 2. Registrar un Error No Fatal

```dart
try {
  // Código que puede fallar
  throw Exception('Test error from Tamagotchi');
} catch (error, stackTrace) {
  // Registrar error en Crashlytics
  await FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    reason: 'Testing Crashlytics integration',
    fatal: false,
  );
}
```

### 3. Agregar Información Contextual

```dart
// Agregar ID de usuario para debugging
FirebaseCrashlytics.instance.setUserIdentifier('user_123');

// Agregar claves personalizadas
FirebaseCrashlytics.instance.setCustomKey('pet_name', pet.name);
FirebaseCrashlytics.instance.setCustomKey('pet_level', pet.level);
FirebaseCrashlytics.instance.setCustomKey('coins', pet.coins);

// Agregar logs
FirebaseCrashlytics.instance.log('Usuario alimentó a la mascota');
```

### 4. Verificar en Firebase Console

1. Ejecuta la app en modo **release** (Crashlytics no funciona en debug):
   ```bash
   flutter run --release
   ```

2. Fuerza un crash o registra errores

3. Espera 5-10 minutos

4. Ve a Firebase Console → Crashlytics

5. Deberías ver los reportes de errores

## 📊 Información que Captura Crashlytics

### Datos Automáticos
- ✅ **Stack trace** completo del error
- ✅ **Dispositivo**: Modelo, fabricante, OS version
- ✅ **Memoria**: RAM disponible, uso de memoria
- ✅ **Estado de la app**: Foreground/background
- ✅ **Timestamp**: Fecha y hora exacta
- ✅ **Versión de la app**: Build number y version name
- ✅ **Orientación**: Portrait/landscape
- ✅ **Estado de red**: WiFi/celular/offline

### Datos Personalizados (que podemos agregar)
- ⭐ ID de usuario
- ⭐ Estado de la mascota (nivel, salud, etc.)
- ⭐ Última acción del usuario
- ⭐ Configuración activa

## 🎮 Integración con Mini-Juegos (Fase 10)

### Ejemplo de Uso en Mini-Juegos

```dart
// En memory_game_screen.dart, sliding_puzzle_screen.dart, etc.

void _onGameComplete(GameResult result) {
  try {
    // Lógica del juego...

    // Registrar evento exitoso
    FirebaseCrashlytics.instance.log(
      'Game completed: ${result.gameType.displayName}, Score: ${result.score}'
    );

    // Agregar contexto
    FirebaseCrashlytics.instance.setCustomKey('last_game', result.gameType.toString());
    FirebaseCrashlytics.instance.setCustomKey('last_score', result.score);

  } catch (error, stackTrace) {
    // Si algo falla, registrar error
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Error completing ${result.gameType.displayName}',
      fatal: false,
    );
  }
}
```

## 🔧 Configuración Adicional (Opcional)

### 1. Habilitar/Deshabilitar Recolección de Datos

```dart
// En settings o durante onboarding
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
```

### 2. Modo Debug

Por defecto, Crashlytics está deshabilitado en debug builds. Para habilitarlo:

```dart
if (kDebugMode) {
  // Forzar habilitación en debug (solo para pruebas)
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
}
```

### 3. Filtrar Errores Sensibles

```dart
FlutterError.onError = (FlutterErrorDetails details) {
  // Filtrar errores que contengan información sensible
  if (details.exception.toString().contains('password')) {
    // No enviar a Crashlytics
    return;
  }

  FirebaseCrashlytics.instance.recordFlutterFatalError(details);
};
```

## 📈 Mejores Prácticas

### 1. **Agregar Contexto en Pantallas Críticas**

```dart
@override
void initState() {
  super.initState();

  // Registrar que el usuario entró a esta pantalla
  FirebaseCrashlytics.instance.log('User opened mini-games menu');
  FirebaseCrashlytics.instance.setCustomKey('screen', 'minigames_menu');
}
```

### 2. **Capturar Errores de Servicios**

```dart
// En storage_service.dart
Future<void> saveState(Pet pet) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final petJson = jsonEncode(pet.toJson());
    await prefs.setString(_petStateKey, petJson);
  } catch (error, stackTrace) {
    debugPrint('❌ Error guardando estado: $error');

    // Registrar en Crashlytics
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Failed to save pet state',
      fatal: false,
    );
  }
}
```

### 3. **Monitorear Operaciones Críticas**

```dart
// En background_service.dart
Future<void> updatePetInBackground() async {
  try {
    FirebaseCrashlytics.instance.log('Background task started');

    // Operaciones críticas...

    FirebaseCrashlytics.instance.log('Background task completed successfully');
  } catch (error, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Background task failed',
      fatal: false,
    );
  }
}
```

## 🚨 Errores Comunes y Soluciones

### 1. "Firebase not initialized"
**Problema:** Firebase.initializeApp() no se llamó antes de usar Crashlytics

**Solución:** Asegurarse que main() tenga:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 2. "No crashes appearing in console"
**Problemas posibles:**
- App corriendo en modo debug (Crashlytics deshabilitado)
- No esperaste 5-10 minutos
- google-services.json no está en android/app/

**Solución:**
- Ejecutar en release: `flutter run --release`
- Esperar al menos 10 minutos
- Verificar que google-services.json existe

### 3. "Build failed after adding Crashlytics"
**Problema:** Plugins de Gradle mal configurados

**Solución:** Verificar que ambos plugins están aplicados:
```kotlin
// En app/build.gradle.kts
id("com.google.gms.google-services")
id("com.google.firebase.crashlytics")
```

## 📱 Comandos Útiles

```bash
# Ejecutar en release para probar Crashlytics
flutter run --release

# Limpiar y reconstruir si hay problemas
flutter clean
flutter pub get
flutter run --release

# Ver logs de Crashlytics en tiempo real
adb logcat | grep -i crashlytics

# Verificar que Firebase está inicializado
adb logcat | grep -i firebase
```

## 📊 Métricas Recomendadas para Monitorear

1. **Crash-free rate**: % de sesiones sin crashes (objetivo: >99%)
2. **Errores por versión**: Comparar estabilidad entre versiones
3. **Top crashes**: Los 10 errores más frecuentes
4. **Errores por dispositivo**: Identificar problemas en modelos específicos
5. **Errores en mini-juegos**: Monitorear estabilidad de cada juego

## ✅ Checklist de Verificación

- [x] firebase_core y firebase_crashlytics en pubspec.yaml
- [x] google-services.json en android/app/
- [x] firebase_options.dart generado
- [x] Plugin google-services en settings.gradle.kts
- [x] Plugin crashlytics en settings.gradle.kts
- [x] Ambos plugins aplicados en app/build.gradle.kts
- [x] Firebase.initializeApp() en main()
- [x] FlutterError.onError configurado
- [x] PlatformDispatcher.instance.onError configurado
- [x] runZonedGuarded() envolviendo runApp()

## 🎓 Conclusión

Firebase Crashlytics está ahora **completamente integrado** en el proyecto Tamagotchi.

**Beneficios:**
- ✅ Detección automática de crashes
- ✅ Reportes detallados con stack traces
- ✅ Información de dispositivo y contexto
- ✅ Monitoreo de estabilidad en tiempo real
- ✅ Priorización de bugs por impacto

**Próximos Pasos:**
1. Ejecutar la app en release
2. Probar con crash forzado
3. Verificar reportes en Firebase Console
4. Agregar logging contextual en funciones críticas
5. Monitorear estabilidad de mini-juegos

---

**Integración completada el:** 2024-12-30
**Versión de Crashlytics:** 5.0.6
**Versión de Firebase Core:** 4.3.0
