# Firebase Analytics - Documentación Técnica

## Descripción General

Firebase Analytics es un servicio de análisis de aplicaciones móviles que proporciona insights sobre el uso de la aplicación y el comportamiento del usuario. Esta integración permite rastrear eventos personalizados, métricas de usuario y patrones de interacción en la aplicación Tamagotchi.

## Características Implementadas

### 1. Eventos de Ciclo de Vida
- **pet_created**: Cuando un usuario crea su primera mascota
- **onboarding_completed**: Al completar el tutorial inicial

### 2. Eventos de Interacción
- **pet_fed**: Alimentación de la mascota (con métricas de hambre)
- **pet_played**: Juego con la mascota (con métricas de felicidad)
- **pet_cleaned**: Limpieza de la mascota (con métricas de salud)
- **pet_rested**: Descanso de la mascota (con métricas de energía)

### 3. Eventos de Personalización
- **pet_renamed**: Cambio de nombre de la mascota
- **pet_color_changed**: Cambio de color (con gasto de monedas)
- **accessory_purchased**: Compra de accesorios (con gasto de monedas)
- **accessory_changed**: Cambio de accesorio equipado

### 4. Eventos de Evolución
- **pet_evolved**: Evolución a nueva etapa de vida
- **level_up**: Subida de nivel de la mascota
- **experience_gained**: Ganancia de experiencia (con fuente)

### 5. Eventos de Mini-Juegos
- **minigame_started**: Inicio de un mini-juego
- **minigame_completed**: Finalización de mini-juego (con puntuación, resultado, monedas y duración)

### 6. Eventos de Estado Crítico
- **critical_state**: Cuando la mascota alcanza un estado crítico
- **pet_died**: Cuando la mascota muere (todas las métricas en 0)

### 7. Eventos de Notificaciones
- **notification_shown**: Cuando se muestra una notificación
- **notification_opened**: Cuando el usuario abre la app desde una notificación

### 8. Eventos de Economía
- **coins_earned**: Ganancia de monedas (con fuente)
- **coins_spent**: Gasto de monedas (con tipo y nombre del ítem)

### 9. Eventos de Sesión
- **app_open**: Apertura de la aplicación (evento estándar)
- **screen_view**: Navegación entre pantallas

### 10. Propiedades de Usuario
- **pet_stage**: Etapa actual de vida de la mascota
- **pet_level**: Nivel actual de la mascota
- **pet_variant**: Variante de la mascota (neglected, normal, excellent)
- **total_coins**: Total de monedas acumuladas

## Arquitectura

### Servicio Centralizado

```dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Métodos estáticos para registro de eventos
}
```

El servicio está diseñado como una clase con métodos estáticos para facilitar su uso desde cualquier parte de la aplicación sin necesidad de instanciación.

### Observer para Navegación

El `FirebaseAnalyticsObserver` se integra con el sistema de navegación de Flutter para rastrear automáticamente las transiciones entre pantallas:

```dart
MaterialApp(
  navigatorObservers: [AnalyticsService.observer],
  // ...
)
```

## Integración en la Aplicación

### Eventos de Interacción (HomeScreen)

```dart
// Ejemplo: Al alimentar la mascota
await AnalyticsService.logFeedPet(
  hungerBefore: oldHunger,
  hungerAfter: newHunger,
  petLevel: currentPet.level,
);

await AnalyticsService.logExperienceGained(
  experienceAmount: xpGained,
  totalExperience: currentPet.experience,
  source: 'interaction',
);
```

### Eventos de Mini-Juegos (MinigamesMenuScreen)

```dart
// Al iniciar un mini-juego
await AnalyticsService.logMinigameStarted(
  gameType: gameType.name,
);

// Al completar un mini-juego
await AnalyticsService.logMinigameCompleted(
  gameType: gameType.name,
  score: finalScore,
  won: victory,
  coinsEarned: coinsWon,
  durationSeconds: duration,
);
```

### Eventos de Personalización (SettingsScreen)

```dart
// Al cambiar el color de la mascota
await AnalyticsService.logPetColorChanged(
  newColor: selectedColor.toString(),
  coinsSpent: colorCost,
);

// Al comprar un accesorio
await AnalyticsService.logAccessoryPurchased(
  accessoryType: accessory,
  coinsSpent: accessoryCost,
);
```

### Eventos de Onboarding (OnboardingScreen)

```dart
// Al completar el onboarding
await AnalyticsService.logOnboardingCompleted();
await AnalyticsService.logPetCreated(
  petName: defaultPetName,
  initialColor: defaultColor,
);
```

### Actualización de Propiedades de Usuario

```dart
// Actualizar propiedades después de cambios significativos
await AnalyticsService.updateUserProperties(updatedPet);
```

## Parámetros de Eventos

### Parámetros Comunes

Todos los eventos incluyen parámetros relevantes para análisis detallado:

| Evento | Parámetros Principales |
|--------|----------------------|
| `pet_fed` | `hunger_before`, `hunger_after`, `hunger_reduced`, `pet_level` |
| `pet_played` | `happiness_before`, `happiness_after`, `happiness_gained`, `pet_level` |
| `pet_evolved` | `from_stage`, `to_stage`, `variant`, `level`, `experience` |
| `minigame_completed` | `game_type`, `score`, `won`, `coins_earned`, `duration_seconds` |
| `coins_earned` | `amount`, `source` |
| `coins_spent` | `amount`, `item_type`, `item_name` |

### Timestamps

Los eventos de ciclo de vida incluyen timestamps ISO 8601 para análisis temporal preciso:

```dart
'timestamp': DateTime.now().toIso8601String()
```

## Casos de Uso de Análisis

### 1. Análisis de Retención
- Rastreo de `onboarding_completed` vs usuarios activos
- Análisis de `app_open` para patrones de uso diario

### 2. Análisis de Engagement
- Frecuencia de interacciones (`pet_fed`, `pet_played`, etc.)
- Participación en mini-juegos (`minigame_started`, `minigame_completed`)
- Tiempo de juego por sesión

### 3. Análisis de Progresión
- Tasa de evolución (`pet_evolved`)
- Velocidad de subida de nivel (`level_up`)
- Distribución de variantes de adulto (excellent, normal, neglected)

### 4. Análisis de Economía
- Balance de monedas ganadas vs gastadas
- Fuentes principales de ingresos (`coins_earned` por source)
- Ítems más comprados (`coins_spent` por item_type)

### 5. Análisis de Estado de Salud
- Frecuencia de estados críticos
- Tasa de mortalidad (`pet_died`)
- Días promedio de supervivencia

### 6. Análisis de Personalización
- Colores más populares
- Accesorios más comprados
- Tasa de cambio de nombre

## Privacidad y GDPR

### Datos No Personales

Todos los eventos están diseñados para NO recopilar información personal identificable (PII):
- No se rastrean nombres de usuario reales
- No se rastrean correos electrónicos
- No se rastrean datos de ubicación
- Nombres de mascotas son datos generados por el usuario (no PII)

### User ID Opcional

```dart
await AnalyticsService.setUserId(userId);
```

El User ID es opcional y debe usarse solo con consentimiento explícito del usuario para análisis cross-device.

## Configuración

### Dependencias (pubspec.yaml)

```yaml
dependencies:
  firebase_core: ^4.3.0
  firebase_analytics: ^12.1.0
```

### Inicialización (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Analytics se inicializa automáticamente con Firebase.initializeApp()

  runApp(MyApp());
}
```

### Observer de Navegación

```dart
MaterialApp(
  navigatorObservers: [AnalyticsService.observer],
  // ...
)
```

## Debugging y Verificación

### Verificación Local

Firebase Analytics solo envía eventos en builds de release por defecto. Para verificar eventos en debug:

```bash
# Android
adb shell setprop debug.firebase.analytics.app <package_name>

# iOS
En Xcode, agregar -FIRDebugEnabled en Arguments Passed On Launch
```

### Ver Eventos en Tiempo Real

1. Abrir Firebase Console
2. Navegar a Analytics > DebugView
3. Seleccionar el dispositivo de prueba
4. Observar eventos en tiempo real

### Dashboards Personalizados

Los eventos personalizados aparecen en Analytics después de ~24 horas. Crear dashboards personalizados en:
- Firebase Console > Analytics > Custom Dashboards
- BigQuery (para análisis avanzado)

## Mejores Prácticas Implementadas

### 1. Nomenclatura Consistente
- Eventos en snake_case: `pet_evolved`, `minigame_completed`
- Parámetros descriptivos: `hunger_before`, `coins_earned`

### 2. Parámetros Significativos
- Incluir contexto completo: valores before/after
- Agregar metadata útil: level, stage, source

### 3. Granularidad Apropiada
- Balance entre detalle y sobrecarga
- Parámetros numéricos en valores enteros cuando es apropiado

### 4. Agrupación Lógica
- Eventos organizados por categorías en el código
- Documentación clara de cada categoría

### 5. Async/Await
- Todos los métodos son async para no bloquear UI
- Manejo silencioso de errores (Firebase maneja internamente)

## Limitaciones de Firebase Analytics

### Límites de Eventos
- **500 eventos distintos** por aplicación
- **25 parámetros únicos** por evento
- **100 propiedades de usuario** por aplicación

### Límites de Datos
- Nombres de eventos: max 40 caracteres
- Nombres de parámetros: max 40 caracteres
- Valores de string: max 100 caracteres

### Frecuencia
- Límite de **~1000 eventos/segundo** por dispositivo
- Los eventos se agrupan antes de enviar (batch)

## Próximos Pasos Potenciales

### Análisis Avanzado
- [ ] Integración con BigQuery para análisis SQL avanzado
- [ ] Funnels de conversión personalizados
- [ ] Cohortes de usuarios basados en comportamiento

### Optimización
- [ ] A/B testing con Firebase Remote Config
- [ ] Predicciones de abandono con Firebase Predictions
- [ ] Segmentación de audiencias para notificaciones

### Machine Learning
- [ ] Análisis de patrones de juego con ML
- [ ] Predicción de necesidades de la mascota
- [ ] Optimización de recompensas de mini-juegos

## Referencias

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [FlutterFire Analytics](https://firebase.flutter.dev/docs/analytics/overview/)
- [Analytics Best Practices](https://firebase.google.com/docs/analytics/best-practices)
- [GDPR Compliance](https://firebase.google.com/support/privacy)

## Resumen

Firebase Analytics está completamente integrado en la aplicación Tamagotchi con:
- ✅ **23 eventos personalizados** cubriendo todas las características principales
- ✅ **4 propiedades de usuario** para segmentación
- ✅ **Observer de navegación** para rastreo automático de pantallas
- ✅ **Servicio centralizado** para fácil mantenimiento
- ✅ **Cumplimiento de privacidad** sin PII

Los eventos proporcionan insights completos sobre:
- Comportamiento de usuario y engagement
- Progresión y retención
- Economía del juego
- Salud y estado de las mascotas
- Popularidad de características

Esta instrumentación permite tomar decisiones informadas sobre:
- Mejoras de features
- Balance de mecánicas de juego
- Optimización de UX
- Estrategias de retención
