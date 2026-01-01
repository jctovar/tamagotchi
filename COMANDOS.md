# 📋 Comandos del Proyecto Tamagotchi

Guía completa de comandos disponibles para el desarrollo del proyecto.

## 🚀 Inicio Rápido

### Opción 1: Usar Makefile (Recomendado)

```bash
# Ver todos los comandos disponibles
make help

# Setup inicial
make setup

# Ejecutar app
make run

# Tests
make test

# Build release
make build-release
```

### Opción 2: Usar Scripts Bash

```bash
# Ver ayuda del script principal
./scripts/dev.sh help

# Setup inicial
./scripts/dev.sh setup

# Ejecutar app
./scripts/dev.sh run
```

---

## 📦 Setup y Dependencias

### Instalación de Dependencias

```bash
# Instalar dependencias
flutter pub get
# o
make deps

# Actualizar dependencias
flutter pub upgrade
# o
make upgrade

# Ver paquetes desactualizados
flutter pub outdated
# o
make outdated
```

### Setup Inicial Completo

```bash
# Setup completo (dependencias + verificaciones)
make setup
# o
./scripts/dev.sh setup
```

---

## ▶️ Ejecución de la App

### Ejecutar en Modo Debug

```bash
flutter run
# o
make run
# o
./scripts/dev.sh run
```

### Ejecutar en Modo Release

```bash
flutter run --release
# o
make run-release
# o
./scripts/dev.sh run release
```

### Ver Dispositivos Disponibles

```bash
flutter devices
# o
make devices
```

### Ejecutar en Dispositivo Específico

```bash
flutter run -d <device-id>
```

### Hot Reload Durante Ejecución

Cuando la app está ejecutándose:
- `r` - Hot reload (mantiene el estado)
- `R` - Hot restart (reinicia la app)
- `q` - Quit (salir)

---

## 🧪 Testing

### Ejecutar Todos los Tests

```bash
flutter test
# o
make test
# o
./scripts/test.sh
```

### Tests con Cobertura

```bash
flutter test --coverage
# o
make test-coverage
# o
./scripts/test.sh coverage
```

### Ejecutar Test Específico

```bash
flutter test test/widget_test.dart
# o
./scripts/test.sh test/widget_test.dart
```

### Suite Completa de Tests

```bash
# Ejecuta: formato + análisis + tests + cobertura
./scripts/test.sh all
```

---

## 🔨 Build

### Build APK Debug

```bash
flutter build apk
# o
make build-apk
# o
./scripts/build.sh debug
```

### Build APK Release

```bash
flutter build apk --release
# o
make build-release
# o
./scripts/build.sh release
```

### Build Android App Bundle (Play Store)

```bash
flutter build appbundle
# o
make build-bundle
# o
./scripts/build.sh bundle
```

### Build Optimizado por ABI

```bash
# Genera APKs separados para cada arquitectura (más pequeños)
flutter build apk --release --split-per-abi
# o
./scripts/build.sh optimized
```

### Build con Análisis de Tamaño

```bash
flutter build apk --analyze-size
# o
./scripts/build.sh analyze
```

### Clean Build

```bash
# Limpiar y rebuild
./scripts/build.sh clean
```

---

## 🔍 Análisis de Código

### Análisis Estático

```bash
flutter analyze
# o
make analyze
```

### Formatear Código

```bash
# Formatear todo el código
dart format lib/ test/
# o
make format
```

### Verificar Formato (sin cambiar)

```bash
dart format --set-exit-if-changed lib/ test/
# o
make format-check
```

### Linting Completo

```bash
# Análisis + verificación de formato
make lint
# o
./scripts/dev.sh analyze
```

---

## 🧹 Limpieza

### Limpieza Normal

```bash
flutter clean
# o
make clean
# o
./scripts/dev.sh clean
```

### Limpieza Profunda

```bash
# Elimina .dart_tool, build, y plugins
make clean-all
# o
./scripts/dev.sh clean deep
```

### Reset Completo

```bash
# Limpieza profunda + reinstalación de dependencias
make reset
```

---

## 🔥 Firebase

### Configurar Firebase

```bash
# Instalar FlutterFire CLI (solo primera vez)
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

### Probar Firebase Crashlytics

```bash
# 1. Ejecutar app en modo release
flutter run --release

# 2. Ver logs de Crashlytics
adb logcat | grep -i crashlytics
# o
make crashlytics
# o
./scripts/dev.sh firebase crashlytics
```

### Ver Logs de Firebase

```bash
adb logcat | grep -i firebase
# o
./scripts/dev.sh firebase logs
```

### Ver Analytics

```bash
# Ver eventos de Analytics en consola (logs en tiempo real)
adb logcat | grep -i analytics

# Firebase Console (navegador web)
# https://console.firebase.google.com/project/[tu-proyecto]/analytics
```

**Eventos disponibles:**
- `app_open` - App abierta
- `feed_pet`, `play_pet`, `clean_pet`, `rest_pet` - Acciones de cuidado
- `evolution` - Evolución de mascota
- `customize_pet` - Personalización
- `game_started`, `game_completed` - Mini-juegos
- Y 14 eventos más...

---

## 🎮 Mini-Juegos

### Jugar Mini-Juegos

Los mini-juegos están integrados en la app:
1. Ejecutar la app (`flutter run`)
2. Ir a la pestaña de **Juegos** 🎮
3. Seleccionar un juego:
   - 🧠 **Memory Game**: Encuentra pares de cartas
   - ⚡ **Reaction Game**: Presiona los botones rápido
   - 🎯 **Pattern Game**: Memoriza y repite patrones

### Ver Estadísticas de Juegos

Las estadísticas se guardan automáticamente:
- Ir a **Configuración** → Ver estadísticas
- Información disponible:
  - Partidas jugadas
  - Partidas ganadas
  - Mejor puntuación
  - Tasa de victorias

### Ganar Monedas

- 🥇 Ganar juego: +50 monedas
- 🥈 Perder juego: +10 monedas

Las monedas se usan para comprar accesorios en la tienda.

---

## 🤖 IA Adaptativa

### Ver Sistema de IA

1. Ejecutar la app
2. Ir a **Configuración** → **Sistema de IA**

### Funcionalidades de IA

**Personalidad:**
- 12 traits de personalidad dinámicos
- 5 niveles de vínculo (Desconocido → Mejor amigo)
- Adaptación basada en interacciones

**Estados Emocionales:**
- 8 emociones distintas
- Mensajes personalizados según estado
- Respuestas adaptativas a acciones

**Predicción de Necesidades:**
- Predicción basada en patrones
- Sugerencias inteligentes
- Alertas proactivas

### Exportar Datos de Entrenamiento ML

```bash
# 1. Abrir la app
flutter run

# 2. Ir a Configuración → Sistema de IA → Exportar Datos

# 3. Los datos se guardan como JSON y se pueden compartir
# Ubicación: Directorio de descargas del dispositivo
```

**Datos exportados:**
- Historial de interacciones (timestamp, tipo, métricas)
- Rasgos de personalidad
- Preferencias del usuario
- Estadísticas de uso

**Formato:**
```json
{
  "interactions": [...],
  "personality": {...},
  "preferences": {...},
  "timestamp": "..."
}
```

### Ver Logs de IA

```bash
# Ver predicciones y decisiones de IA en tiempo real
adb logcat | grep -E "AIService|MLService"
```

---

## 📦 Git

### Ver Estado

```bash
git status
# o
make status
```

### Crear Commit

```bash
# Ver estado y ayuda
make commit

# Commit manual
git add .
git commit -m "Mensaje del commit"
```

### Push a Origin

```bash
git push origin main
# o
make push
```

---

## 🛠️ Utilidades Android

### Ver Logs de la App

```bash
# Logs generales
adb logcat

# Filtrar por Flutter
adb logcat | grep -i flutter

# Filtrar por etiqueta específica
adb logcat -s "TamagotchiApp"
```

### Instalar APK Manualmente

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Desinstalar App

```bash
adb uninstall com.example.tamagotchi
```

### Limpiar Datos de la App

```bash
adb shell pm clear com.example.tamagotchi
```

---

## 📊 Información del Proyecto

### Ver Versión de Flutter

```bash
flutter --version
```

### Ver Información del Doctor

```bash
flutter doctor
flutter doctor -v  # Verbose
```

### Ver Dependencias del Proyecto

```bash
flutter pub deps
flutter pub deps --tree
```

### Listar Dispositivos

```bash
flutter devices
flutter emulators  # Solo emuladores
```

---

## 🎯 Flujos de Trabajo Comunes

### Workflow de Desarrollo Diario

```bash
# 1. Actualizar dependencias
make deps

# 2. Ejecutar app
make run

# 3. Hacer cambios...
# (Hot reload con 'r' durante ejecución)

# 4. Ejecutar tests
make test

# 5. Analizar código
make analyze
```

### Workflow de Release

```bash
# 1. Limpiar proyecto
make clean-all

# 2. Ejecutar tests con cobertura
./scripts/test.sh all

# 3. Build release con verificaciones
./scripts/build.sh release

# 4. Verificar APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### Workflow de CI/CD

```bash
# Script completo para CI
flutter pub get
flutter analyze
flutter test --coverage
flutter build apk --release
```

---

## 🐛 Troubleshooting

### Problemas de Build

```bash
# Limpieza profunda
flutter clean
rm -rf .dart_tool/
rm -rf build/
flutter pub get

# Si persiste, eliminar plugins
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
flutter pub get
```

### Problemas con Firebase

```bash
# Verificar configuración
cat lib/firebase_options.dart
cat android/app/google-services.json

# Reconfigurar Firebase
flutterfire configure
```

### Problemas con Dependencias

```bash
# Limpiar cache de pub
flutter pub cache repair

# Actualizar todas las dependencias
flutter pub upgrade --major-versions
```

---

## 📚 Scripts Disponibles

El proyecto incluye los siguientes scripts en `scripts/`:

| Script | Descripción |
|--------|-------------|
| `dev.sh` | Script principal de desarrollo |
| `test.sh` | Runner de tests con opciones |
| `build.sh` | Script de builds automatizados |

### Ejemplos de Uso

```bash
# Script de desarrollo
./scripts/dev.sh setup
./scripts/dev.sh run release
./scripts/dev.sh clean deep

# Script de tests
./scripts/test.sh
./scripts/test.sh coverage
./scripts/test.sh all

# Script de builds
./scripts/build.sh debug
./scripts/build.sh release
./scripts/build.sh bundle
```

---

## 💡 Tips y Mejores Prácticas

### Performance

```bash
# Profile mode (para análisis de performance)
flutter run --profile

# Generar reporte de performance
flutter run --profile --trace-startup
```

### Debugging

```bash
# Ejecutar con verbose logs
flutter run -v

# Habilitar logging de todas las categorías
flutter logs
```

### Análisis de Tamaño

```bash
# Ver qué está ocupando espacio en tu APK
flutter build apk --analyze-size --target-platform android-arm64
```

---

## 🔗 Links Útiles

- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides
- **Firebase Console**: https://console.firebase.google.com
- **Play Console**: https://play.google.com/console

---

## 📝 Notas Importantes

1. **Firebase Crashlytics** solo funciona en modo **release**
2. **Hot reload** solo funciona en modo **debug**
3. **App Bundles** (.aab) son el formato recomendado para Play Store
4. **Split APKs** son más pequeños pero requieren distribución separada por arquitectura

---

**Última actualización:** 2024-12-30
