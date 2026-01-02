# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tamagotchi Virtual es una aplicación Flutter completamente funcional de mascota virtual con:
- 12 fases de desarrollo completadas (65 tareas)
- Sistema de evolución con 5 etapas de vida
- IA adaptativa con TensorFlow Lite
- 3 mini-juegos integrados con Flame engine
- Firebase Crashlytics y Analytics
- Background processing 24/7 con WorkManager
- Sistema completo de persistencia
- Dashboard de estadísticas con gráficas

**Estado actual: PRODUCCIÓN - Fase 12 completada**

## Architecture Overview

### Tech Stack

**Frontend:**
- Flutter 3.10.4+
- Material Design 3
- Flame 1.34.0 (Game Engine)
- FL Chart 0.69.0 (Gráficas)

**Backend & Services:**
- SharedPreferences (Local Storage)
- WorkManager (Background Processing)
- Firebase Core, Crashlytics, Analytics
- TensorFlow Lite (Machine Learning)

**State Management:**
- StatefulWidget con setState
- Provider para estado global

### Project Structure

```
lib/
├── config/              # Configuración y temas
│   ├── theme.dart
│   └── app_constants.dart
├── models/              # Modelos de datos
│   ├── pet.dart
│   ├── life_stage.dart
│   ├── pet_preferences.dart
│   ├── pet_personality.dart
│   ├── interaction_history.dart
│   ├── minigame_stats.dart
│   └── credit_model.dart
├── screens/             # Pantallas de la app
│   ├── home_screen.dart
│   ├── main_navigation.dart
│   ├── settings_screen.dart
│   ├── onboarding_screen.dart
│   ├── customization_screen.dart
│   ├── games/           # Mini-juegos
│   │   ├── memory_game_screen.dart
│   │   ├── reaction_game_screen.dart
│   │   └── pattern_game_screen.dart
│   └── ai/              # Pantallas de IA
│       ├── ai_insights_screen.dart
│       └── personality_screen.dart
├── services/            # Capa de servicios
│   ├── storage_service.dart
│   ├── background_service.dart
│   ├── notification_service.dart
│   ├── analytics_service.dart
│   ├── ai_service.dart
│   ├── ml_service.dart
│   ├── feedback_service.dart
│   └── preferences_service.dart
├── widgets/             # Componentes reutilizables
│   ├── pet_widget.dart
│   ├── metric_bar.dart
│   ├── action_button.dart
│   ├── evolution_animation.dart
│   └── ai/
│       ├── personality_trait_card.dart
│       └── emotion_indicator.dart
└── utils/               # Utilidades y constantes
    ├── ml_feature_extractor.dart
    └── ml_performance_tracker.dart
```

### Key Services

1. **StorageService**: Persistencia con SharedPreferences
   - Estado de la mascota
   - Preferencias del usuario
   - Historial de interacciones
   - Estadísticas de mini-juegos

2. **BackgroundService**: WorkManager para procesamiento 24/7
   - Actualización de métricas cada 15 minutos
   - Funciona con app cerrada
   - Solo Android (iOS tiene restricciones)

3. **NotificationService**: Alertas push locales
   - Notificaciones cuando la mascota necesita atención
   - Estados críticos (hambre alta, felicidad baja, etc.)

4. **AnalyticsService**: Tracking de eventos con Firebase
   - 23 eventos personalizados
   - Tracking de acciones del usuario
   - Métricas de engagement

5. **AIService**: Personalidad adaptativa y predicciones
   - 12 traits de personalidad
   - 8 estados emocionales
   - Sistema de vínculo (5 niveles)
   - Predicción de necesidades

6. **MLService**: Machine Learning con TensorFlow Lite
   - Preparado para modelos ML
   - Extracción de features
   - Exportación de datos de entrenamiento

## Development Commands

### Setup and Dependencies
```bash
flutter pub get                    # Install dependencies
flutter pub upgrade                # Upgrade dependencies
make setup                         # Setup completo (dependencias + verificación)
```

### Running the Application
```bash
flutter run                        # Run on connected device/emulator
flutter run -d <device-id>         # Run on specific device
flutter run --release              # Run in release mode
make run                           # Alias para flutter run
make run-release                   # Alias para flutter run --release
```

### Testing
```bash
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run a specific test file
flutter test --coverage            # Run tests with coverage report
make test                          # Alias para flutter test
```

### Code Quality
```bash
flutter analyze                    # Run static analysis
flutter pub outdated               # Check for outdated packages
make analyze                       # Alias para flutter analyze
```

### Building
```bash
flutter build apk                  # Build Android APK
flutter build appbundle            # Build Android App Bundle
flutter build apk --release        # Build release APK
make build-release                 # Build APK release
make build-bundle                  # App bundle para Play Store
./scripts/build.sh optimized       # APKs optimizados por ABI
```

### Hot Reload
- Press `r` in the terminal during `flutter run` for hot reload
- Press `R` for hot restart (resets app state)

## Implemented Features

### ✅ Core Features (Fases 1-6)
- Sistema completo de cuidado (4 acciones: alimentar, jugar, limpiar, descansar)
- Métricas en tiempo real (4 métricas: hambre, felicidad, energía, salud)
- Persistencia total con SharedPreferences
- Background processing con WorkManager (cada 15 minutos)
- Sistema de notificaciones locales
- Animaciones y feedback háptico (vibración)
- Temporizadores de decaimiento en tiempo real

### ✅ Advanced Features (Fases 7-9)
- Personalización completa
  - 8 colores para la mascota
  - 5 tipos de accesorios
  - Renombrar mascota
- Sistema de evolución (5 etapas de vida)
  - Huevo → Bebé → Niño → Adolescente → Adulto
  - 3 variantes según calidad de cuidado (Descuidado, Normal, Excelente)
- Sistema de experiencia y niveles
  - Puntos de experiencia por interacciones
  - Subida de nivel con celebración
- Onboarding interactivo para nuevos usuarios

### ✅ Premium Features (Fases 10-11)
- 3 mini-juegos con Flame engine
  - Memory Game (memoria)
  - Reaction Game (reflejos)
  - Pattern Game (patrones)
- Sistema de monedas y recompensas
  - Ganar monedas en mini-juegos
  - Usar monedas para accesorios
- IA adaptativa
  - 12 traits de personalidad
  - 8 estados emocionales dinámicos
  - Sistema de vínculo (5 niveles: Desconocido → Mejor amigo)
  - Predicción de necesidades
- Preparación para TensorFlow Lite
  - Features extraídas y listas
  - Sistema de exportación de datos

### ✅ Analytics & Stats (Fase 12)
- Pantalla de estadísticas con 3 tabs
  - Tab "Hoy": Timeline de actividades diarias
  - Tab "Juegos": Estadísticas de mini-juegos con gráficas
  - Tab "IA/ML": Dashboard de rendimiento ML
- Gráficas con FL Chart
  - BarChart para win rate de juegos
  - BarChart para rendimiento de modelos ML
- Métricas detalladas
  - Interacciones por tipo y período del día
  - Estadísticas completas por mini-juego
  - Performance de modelos de Machine Learning

### ✅ Production Features
- Firebase Crashlytics (monitoreo de errores)
- Firebase Analytics (23 eventos personalizados)
- Splash screen animado con flame_splash_screen
- Logging completo con logger package
- Sistema de reset de Tamagotchi
- Exportación de datos ML

## Next Phases (Optional)

### Fase 12: Machine Learning Avanzado
- Entrenar modelos TensorFlow Lite
- Predicción de comportamiento del usuario
- Recomendaciones personalizadas

### Fase 13: Realidad Aumentada
- Integración ARCore/ARKit
- Visualización AR de la mascota

### Fase 14: Social Features
- Sistema de amigos
- Compartir mascotas
- Visitas entre usuarios

## Important Notes

### Background Processing
- WorkManager ejecuta cada 15 minutos
- Funciona incluso con app cerrada
- Solo Android (iOS tiene restricciones significativas)
- Las métricas se actualizan basadas en tiempo transcurrido

### Firebase
- Crashlytics SOLO funciona en modo release (por diseño de Firebase)
- Analytics funciona en debug y release
- Configuración en `firebase_options.dart`
- 23 eventos personalizados implementados

### Flame Engine
- Usado para 3 mini-juegos completos
- Usado para splash screen animado
- Audio con `flame_audio`
- Física y colisiones básicas

### TensorFlow Lite
- Features preparadas para 4 modelos ML:
  - Action Predictor (15 features)
  - Critical Time Predictor (20 features)
  - Action Recommender (25 features)
  - Emotion Classifier (16 features)
- Modelo pendiente de entrenar
- Exportación de datos lista (`share_plus`, `path_provider`)

### State Persistence
- Usa `shared_preferences` para todo
- Guardado automático cada 20 segundos
- Guardado en cada acción del usuario
- Cálculo de decaimiento basado en timestamps

## Testing

El proyecto tiene cobertura completa de tests:

### Unit Tests (600+ pruebas)
```bash
flutter test                       # Run all tests
```

**Archivos de prueba:**
- Models: `pet_test.dart`, `life_stage_test.dart`, `interaction_history_test.dart`, `minigame_stats_test.dart`, `pet_personality_test.dart`, `credit_model_test.dart`
- Services: `storage_service_test.dart`, `ai_service_test.dart`, `notification_service_test.dart`, `preferences_service_test.dart`, `feedback_service_test.dart`, `local_service_test.dart`, `ml_service_test.dart`, `ml_data_export_service_test.dart`, `ai_ml_integration_test.dart`, `critical_time_integration_test.dart`, `advanced_ml_integration_test.dart`
- Utils: `ml_feature_extractor_test.dart`, `ml_performance_tracker_test.dart`

### Integration Tests
- Probar persistencia: matar app y reabrir (estado debe mantenerse)
- Probar background: matar app y esperar 15 minutos (métricas deben cambiar)
- Probar notificaciones: dejar mascota en estado crítico

## Common Commands

### Desarrollo
```bash
make run                    # Debug mode
make run-release           # Release mode
make test                  # Run tests
make analyze               # Static analysis
```

### Build
```bash
make build-release         # Build APK release
make build-bundle          # App bundle para Play Store
./scripts/build.sh optimized  # APKs por ABI
```

### Limpieza
```bash
make clean                 # Clean normal
make clean-all            # Deep clean (incluye build cache)
make reset                # Reset completo (limpia todo + pub get)
```

### Firebase
```bash
# Crashlytics solo funciona en release
flutter run --release
# Ver crashes en: https://console.firebase.google.com/project/[tu-proyecto]/crashlytics

# Analytics
# Ver eventos en: https://console.firebase.google.com/project/[tu-proyecto]/analytics
```

### Utilidades
```bash
make devices              # Listar dispositivos
make help                 # Ver todos los comandos
flutter devices           # Listar dispositivos conectados
```

## Documentation

- [README.md](README.md) - Overview completo del proyecto
- [ROADMAP.md](ROADMAP.md) - Hoja de ruta y fases
- [COMANDOS.md](COMANDOS.md) - Guía completa de comandos
- [FIREBASE_CRASHLYTICS.md](FIREBASE_CRASHLYTICS.md) - Integración Firebase Crashlytics
- [FIREBASE_ANALYTICS.md](FIREBASE_ANALYTICS.md) - Sistema de analytics
- [COMO_PROBAR_PERSISTENCIA.md](COMO_PROBAR_PERSISTENCIA.md) - Guía de pruebas
- [FASE_*_*.md](.) - Documentación técnica por fase

## Dependencies Overview

### Production Dependencies (31 packages)

**Flutter Core:**
- `flutter` - Framework base
- `cupertino_icons` - Iconos iOS

**Storage & Persistence:**
- `shared_preferences` - Persistencia local

**Background Processing:**
- `workmanager` - Tareas en background

**Notifications:**
- `flutter_local_notifications` - Notificaciones locales

**UI/UX:**
- `vibration` - Feedback háptico
- `introduction_screen` - Onboarding
- `flutter_svg` - Imágenes SVG
- `provider` - Gestión de estado
- `flutter_launcher_icons` - Iconos de la app

**Games:**
- `flame` - Motor de juegos
- `flame_audio` - Audio para juegos
- `flame_splash_screen` - Splash screen animado
- `audioplayers` - Reproducción de audio

**Utils:**
- `logger` - Sistema de logging
- `timeago` - Timestamps humanizados
- `package_info_plus` - Información del paquete
- `intl` - Internacionalización

**Firebase:**
- `firebase_core` - Core de Firebase
- `firebase_crashlytics` - Monitoreo de errores
- `firebase_analytics` - Analytics

**Machine Learning:**
- `tflite_flutter` - TensorFlow Lite
- `share_plus` - Compartir archivos
- `path_provider` - Acceso al filesystem

### Dev Dependencies (2 packages)
- `flutter_test` - Testing framework
- `flutter_lints` - Linting rules

## Performance Considerations

- Background tasks optimizados para batería (solo cada 15 min)
- Timers cancelados cuando app está en background
- Persistencia eficiente con SharedPreferences (guardado cada 20s)
- Lazy loading de recursos de audio
- Splash screen optimizado con Flame
- Cálculos de decaimiento basados en tiempo transcurrido (no en loops)

## Linting

- Usa `flutter_lints` para análisis estático
- Ejecutar `flutter analyze` antes de commits
- Formatear con `dart format lib/ test/`
- Sin warnings en el análisis estático actual

## Current State Summary

**Fase 12 completada:**
- ✅ 65 tareas completadas
- ✅ 600+ tests pasando
- ✅ Sin warnings de análisis estático
- ✅ Firebase integrado (Crashlytics + Analytics)
- ✅ 3 mini-juegos funcionales
- ✅ IA adaptativa completa
- ✅ Sistema de evolución con 5 etapas
- ✅ Background processing 24/7
- ✅ Persistencia completa
- ✅ Splash screen animado con Flame
- ✅ Dashboard de estadísticas con gráficas

**Próximos pasos opcionales:**
- Entrenar modelos ML con TensorFlow Lite
- Agregar AR con ARCore/ARKit
- Features sociales y multiplayer
- Integración avanzada con Flutter Flame (Fase 13)
