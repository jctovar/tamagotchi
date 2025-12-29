# Fase 6: Sistema de Notificaciones - COMPLETADA ✅

## Implementación Realizada

### 1. Dependencia Agregada

- **flutter_local_notifications**: ^18.0.1 - Plugin para notificaciones locales en Android/iOS

### 2. Servicio de Notificaciones Creado

**Archivo**: `lib/services/notification_service.dart`

Este servicio gestiona:
- ✅ **Inicialización del sistema de notificaciones**
- ✅ **Solicitud de permisos** (Android 13+)
- ✅ **Creación de canales de notificación**
- ✅ **Notificaciones de estado crítico**
- ✅ **Notificaciones recordatorio**
- ✅ **Manejo de taps en notificaciones**

### 3. Características Implementadas

**Tipos de Notificaciones**:

1. **Notificación Crítica** (Alta prioridad):
   - Se dispara cuando la mascota entra en estado crítico
   - Mensaje específico según la métrica crítica
   - Con sonido y vibración
   - Canal: "Estado Crítico"

2. **Notificación Recordatorio** (Normal):
   - Recordatorios generales
   - Menos intrusiva

**Mensajes Personalizados**:
- Salud < 30: "Tu Tamagotchi está muy enfermo. ¡Necesita cuidados ahora!"
- Hambre > 80: "Tu Tamagotchi tiene mucha hambre. ¡Aliméntalo pronto!"
- Energía < 20: "Tu Tamagotchi está agotado. ¡Deja que descanse!"
- Felicidad < 30: "Tu Tamagotchi está muy triste. ¡Juega con él!"

### 4. Integración Completa

**En Foreground** (app abierta):
```dart
// Detecta cuando la mascota entra en estado crítico
if (_pet.isCritical && !_wasCritical) {
  NotificationService.showCriticalNotification(_pet);
}
```

**En Background** (app cerrada):
```dart
// WorkManager ejecuta cada 15 minutos
if (updatedPet.isCritical) {
  await NotificationService.showCriticalNotification(updatedPet);
}
```

### 5. Configuración Android

**Permisos agregados** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

**Core Library Desugaring** (`build.gradle.kts`):
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## Cómo Funciona

### Flujo de Notificaciones

**Escenario 1: App Abierta**
```
Timer actualiza métricas cada 1s
  ↓
Detecta cambio a estado crítico
  ↓
showCriticalNotification(_pet)
  ↓
Notificación aparece en barra de estado
  ↓
Usuario toca → Abre la app
```

**Escenario 2: App Cerrada**
```
WorkManager ejecuta cada 15 min
  ↓
Actualiza métricas en background
  ↓
Detecta estado crítico
  ↓
showCriticalNotification(_pet)
  ↓
Notificación aparece (app cerrada)
  ↓
Usuario toca → Abre la app
```

### Prevención de Spam

Se implementó `_wasCritical` para evitar notificaciones repetidas:
- Solo notifica cuando entra en crítico
- No notifica si ya estaba en crítico
- Se resetea cuando sale del estado crítico

## Logs del Sistema

### Al Iniciar la App:
```
I/flutter: 🔔 Servicio de notificaciones inicializado
I/flutter: 🔔 Permisos de notificación: Concedidos
I/flutter: 🔧 WorkManager inicializado
I/flutter: 📅 Tarea periódica registrada: cada 15 minutos
```

### Cuando se Envía Notificación:
```
I/flutter: 🔔 Notificación crítica enviada: Mi Tamagotchi tiene mucha hambre. ¡Aliméntalo pronto!
```

### Cuando se Toca Notificación:
```
I/flutter: 📱 Notificación tocada: critical_state
```

## Cómo Probar

### Prueba 1: Notificación en Foreground (Inmediata)

1. **Con la app abierta**, observa las métricas
2. Espera a que alguna métrica entre en crítico:
   - Hambre > 80
   - Felicidad < 30
   - Energía < 20
   - Salud < 30
3. **¡Aparecerá una notificación!**
4. Toca la notificación (llevará a la app)
5. Cuida a tu mascota para salir del estado crítico

### Prueba 2: Notificación en Background (15 min)

1. Cuida a tu mascota (deja métricas normales)
2. Cierra la app completamente (`q`)
3. **Espera 15-30 minutos** (WorkManager ejecutará)
4. Deberías recibir una notificación si está crítico
5. Toca la notificación para abrir la app

### Prueba 3: Verificar Permisos

1. En el emulador, ve a **Configuración → Apps**
2. Busca "Tamagotchi"
3. Entra en **Notificaciones**
4. Verifica que estén habilitadas
5. Puedes personalizar el comportamiento del canal "Estado Crítico"

### Prueba 4: Forzar Estado Crítico (Debug)

Puedes modificar temporalmente las métricas para probar:

```dart
// En home_screen.dart, después de cargar el estado
_pet = _pet.copyWith(hunger: 85); // Forzar hambre crítica
```

Esto disparará inmediatamente una notificación.

## Archivos Creados/Modificados

### Nuevos:
- ✅ `lib/services/notification_service.dart`
- ✅ `FASE_6_NOTIFICACIONES.md` (este archivo)

### Modificados:
- ✅ `pubspec.yaml` - Agregado flutter_local_notifications
- ✅ `lib/main.dart` - Inicialización de notificaciones
- ✅ `lib/services/background_service.dart` - Integración de notificaciones
- ✅ `lib/screens/home_screen.dart` - Detección en foreground
- ✅ `android/app/src/main/AndroidManifest.xml` - Permisos
- ✅ `android/app/build.gradle.kts` - Core library desugaring

## Personalización de Notificaciones

### Cambiar Sonido o Vibración

En `notification_service.dart`:

```dart
const androidDetails = AndroidNotificationDetails(
  _channelId,
  _channelName,
  importance: Importance.max,        // Cambiar prioridad
  priority: Priority.max,            // Cambiar prioridad
  enableVibration: true,             // Habilitar/deshabilitar
  playSound: true,                   // Habilitar/deshabilitar
  sound: RawResourceAndroidNotificationSound('custom_sound'), // Sonido custom
);
```

### Agregar Acciones a Notificaciones

```dart
// Agregar botones a la notificación
styleInformation: BigTextStyleInformation(
  body,
  htmlFormatBigText: true,
  actions: [
    AndroidNotificationAction('feed', 'Alimentar'),
    AndroidNotificationAction('play', 'Jugar'),
  ],
)
```

## Estado Actual del Proyecto

**Fase 1**: ✅ Estructura base y UI
**Fase 2**: ✅ Interacciones básicas
**Fase 3**: ✅ Persistencia de estado
**Fase 4**: ✅ Temporizadores en tiempo real
**Fase 5**: ✅ Background processing
**Fase 6**: ✅ **SISTEMA DE NOTIFICACIONES COMPLETADO** 🎉

## Características Completas del Proyecto

Tu app Tamagotchi ahora tiene:

1. ✅ **Interfaz completa** con visualización de mascota y métricas
2. ✅ **4 acciones de cuidado** (alimentar, jugar, limpiar, descansar)
3. ✅ **Persistencia de estado** entre sesiones
4. ✅ **Temporizadores en tiempo real** (decaimiento continuo)
5. ✅ **Background processing** (vive 24/7)
6. ✅ **Sistema de notificaciones** (te avisa cuando necesita atención)
7. ✅ **Estados de ánimo** dinámicos (feliz, triste, hambriento, etc.)
8. ✅ **Alertas visuales** cuando está en peligro
9. ✅ **Lifecycle management** (pausa/resume correcto)
10. ✅ **Guardado automático** periódico

## Próximas Mejoras Opcionales

Si quieres continuar mejorando:

### Fase 7: Animaciones y UX
- Animaciones al interactuar
- Transiciones suaves
- Efectos de partículas
- Sonidos de feedback

### Fase 8: Evolución
- Sistema de niveles
- Evolución de la mascota
- Diferentes formas según cuidado

### Fase 9: Mini-Juegos
- Juegos para ganar puntos
- Recompensas por jugar
- Sistema de monedas

### Fase 10: Social
- Compartir en redes
- Comparar con amigos
- Tabla de clasificación

## Comandos Útiles

```bash
# Ver notificaciones activas
adb shell dumpsys notification

# Listar canales de notificación
adb shell cmd notification list_channels mx.unam.iztacala.tamagotchi

# Probar notificación manualmente (desde app)
NotificationService.showCriticalNotification(_pet);
```

## Notas Técnicas

- **Plugin**: flutter_local_notifications 18.0.1
- **Android API**: NotificationManager + NotificationChannel
- **Mínimo Android**: API 23 (Android 6.0)
- **Permisos runtime**: Android 13+ requiere POST_NOTIFICATIONS
- **Desugaring**: Requerido para compatibilidad con APIs modernas

¡Tu Tamagotchi está completo y listo para cuidar! 🎊🐾
