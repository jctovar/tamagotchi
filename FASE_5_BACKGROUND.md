# Fase 5: Background Processing - COMPLETADA ✅

## Implementación Realizada

### 1. Dependencia Agregada

- **workmanager**: ^0.9.0 - Plugin para ejecutar tareas en background

### 2. Servicio de Background Creado

**Archivo**: `lib/services/background_service.dart`

Este servicio gestiona:
- ✅ **Inicialización de WorkManager**
- ✅ **Registro de tareas periódicas**
- ✅ **Callback que se ejecuta en background**
- ✅ **Actualización de métricas cuando la app está cerrada**
- ✅ **Cancelación de tareas**

### 3. Características Implementadas

**Tarea Periódica**:
- Se ejecuta cada 15 minutos (configurable en constants.dart)
- Funciona incluso con la app completamente cerrada
- Sobrevive a reinicios del dispositivo
- Usa Android WorkManager (optimizado para batería)

**Callback de Background**:
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Cargar estado de la mascota
    // Actualizar métricas basado en tiempo transcurrido
    // Guardar estado actualizado
    // Detectar estados críticos
  });
}
```

**Configuración**:
- Frecuencia: 15 minutos (mínimo permitido por Android)
- Delay inicial: 1 minuto
- No requiere conexión a internet
- No requiere batería alta
- No requiere carga
- Política de reintentos: Linear backoff

## Cómo Funciona

### Flujo de Background Processing

```
App se cierra
  ↓
Sistema Android mantiene tarea programada
  ↓
Cada 15 minutos:
  1. Android activa el callback
  2. Carga estado guardado de la mascota
  3. Calcula tiempo transcurrido
  4. Aplica decaimiento de métricas
  5. Guarda nuevo estado
  6. Detecta si es crítico (para futuras notificaciones)
  ↓
Tarea termina, Android espera otros 15 min
```

### Integración en main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar y registrar background service
  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicTask();

  runApp(const TamagotchiApp());
}
```

## Logs del Sistema

### Al Iniciar la App:
```
I/flutter: 🔧 WorkManager inicializado
I/flutter: 📅 Tarea periódica registrada: cada 15 minutos
D/WM-SystemJobScheduler: Scheduling work ID [UUID] Job ID 0
```

### Durante Ejecución en Background (cada 15 min):
```
I/flutter: 🔄 Ejecutando tarea en background: petUpdateTask
I/flutter: 📊 Estado antes de actualizar - Hambre: 45.0, Felicidad: 70.0
I/flutter: 📊 Estado después de actualizar - Hambre: 90.0, Felicidad: 43.0
I/flutter: ⚠️ Estado crítico detectado en background!
I/flutter: ✅ Tarea completada exitosamente
```

## Cómo Probar

### Prueba 1: Verificar Registro de Tarea

1. Abre la app (ya está corriendo)
2. Verifica en logs:
   ```
   I/flutter: 🔧 WorkManager inicializado
   I/flutter: 📅 Tarea periódica registrada: cada 15 minutos
   ```
3. ✅ Si ves estos logs, el background service está activo

### Prueba 2: Simular Background Processing

**IMPORTANTE**: Android solo ejecuta tareas periódicas mínimo cada 15 minutos.

Para probar más rápido, puedes modificar temporalmente:

```dart
// En background_service.dart, línea 24
frequency: Duration(minutes: 15), // Cambiar a Duration(minutes: 1) SOLO PARA TESTING
```

**Pasos**:
1. Cambia la frecuencia a 1 minuto (solo para testing)
2. Reinstala la app: `flutter run`
3. Cierra la app COMPLETAMENTE (`q` en terminal)
4. Espera 1-2 minutos
5. Abre la app de nuevo
6. Observa las métricas - deben haber decaído

⚠️ **IMPORTANTE**: Vuelve a cambiar a 15 minutos después de testing

### Prueba 3: Verificar Persistencia a Largo Plazo

1. Interactúa con la mascota (aliméntala)
2. Cierra la app completamente
3. **Espera 30-60 minutos** (o más)
4. Reabre la app
5. Las métricas reflejarán TODO el tiempo transcurrido:
   - Hambre habrá aumentado significativamente
   - Felicidad habrá disminuido
   - Posiblemente en estado crítico

### Prueba 4: Reinicio del Dispositivo

1. Cierra la app
2. Reinicia el emulador
3. Espera 15+ minutos
4. Abre la app
5. Las métricas se habrán actualizado (WorkManager sobrevive reinicios)

## Cálculos de Decaimiento

### En Foreground (app abierta):
- Actualización cada 1 segundo
- Hambre: +0.05/s = +3/min = +180/hora
- Felicidad: -0.03/s = -1.8/min = -108/hora
- Energía: -0.02/s = -1.2/min = -72/hora

### En Background (app cerrada):
- Actualización cada 15 minutos
- Se calcula TODO el tiempo transcurrido
- Aplicando las mismas tasas de decaimiento

### Ejemplo: 1 hora cerrada
```
Tiempo: 60 minutos = 3600 segundos

Hambre: 0 + (3600 × 0.05) = 0 + 180 = 180 → clamped a 100
Felicidad: 100 - (3600 × 0.03) = 100 - 108 = 0 (clamped)
Energía: 100 - (3600 × 0.02) = 100 - 72 = 28
```

## Archivos Creados/Modificados

### Nuevos:
- ✅ `lib/services/background_service.dart`
- ✅ `FASE_5_BACKGROUND.md` (este archivo)

### Modificados:
- ✅ `pubspec.yaml` - Agregado workmanager ^0.9.0
- ✅ `lib/main.dart` - Inicialización de background service

## Limitaciones de Android

### Restricciones del Sistema:
1. **Frecuencia mínima**: 15 minutos
2. **Batería**: Android puede retrasar tareas si batería baja
3. **Doze Mode**: En modo ahorro extremo, las tareas se agrupan
4. **Fabricantes**: Algunos (Xiaomi, Huawei) son muy agresivos matando background tasks

### Soluciones:
- WorkManager está optimizado para estas restricciones
- Usa JobScheduler nativo de Android
- Se re-programa automáticamente si Android lo cancela
- Persiste después de reinicios

## Próximos Pasos (Fase 6)

Con background processing funcionando, lo siguiente es:

### Fase 6: Sistema de Notificaciones
- Agregar `flutter_local_notifications`
- Mostrar notificación cuando estado es crítico
- Integrar con el callback de background
- Notificaciones personalizadas según métrica crítica

## Estado Actual del Proyecto

**Fase 1**: ✅ Estructura base y UI
**Fase 2**: ✅ Interacciones básicas
**Fase 3**: ✅ Persistencia de estado
**Fase 4**: ✅ Temporizadores en tiempo real
**Fase 5**: ✅ **BACKGROUND PROCESSING COMPLETADA** 🎉
**Fase 6**: ⏳ Sistema de notificaciones

## Comandos Útiles

```bash
# Ver logs de WorkManager en Android
adb logcat | grep "WM-"

# Ver todas las tareas programadas
adb shell dumpsys jobscheduler | grep tamagotchi

# Forzar ejecución inmediata (solo para testing)
adb shell cmd jobscheduler run -f mx.unam.iztacala.tamagotchi [JOB_ID]
```

## Notas Técnicas

- **Plugin**: workmanager 0.9.0
- **Android API**: WorkManager (androidx.work)
- **Mínimo Android**: API 23 (Android 6.0)
- **Frecuencia**: 15 minutos (restricción de Android)
- **Persistencia**: Sí, sobrevive reinicios
- **Batería**: Optimizado, uso mínimo

¡Tu Tamagotchi ahora vive 24/7, incluso con la app cerrada! ⏰🎉
