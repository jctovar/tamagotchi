# Makefile para Tamagotchi Flutter Project
# Comandos rápidos para desarrollo

.PHONY: help setup run test build clean analyze firebase git

# Mostrar ayuda por defecto
help:
	@echo "📱 Tamagotchi - Comandos Disponibles"
	@echo ""
	@echo "🚀 Setup y Dependencias:"
	@echo "  make setup          - Configuración inicial completa"
	@echo "  make deps           - Instalar dependencias"
	@echo "  make upgrade        - Actualizar dependencias"
	@echo "  make outdated       - Ver paquetes desactualizados"
	@echo ""
	@echo "▶️  Ejecución:"
	@echo "  make run            - Ejecutar en modo debug"
	@echo "  make run-release    - Ejecutar en modo release"
	@echo "  make devices        - Listar dispositivos disponibles"
	@echo "  make hot-reload     - Info sobre hot reload"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  make test           - Ejecutar todos los tests"
	@echo "  make test-coverage  - Tests con reporte de cobertura"
	@echo "  make test-watch     - Tests en modo watch"
	@echo ""
	@echo "🔨 Build:"
	@echo "  make build-apk      - Build APK debug"
	@echo "  make build-release  - Build APK release"
	@echo "  make build-bundle   - Build Android App Bundle"
	@echo ""
	@echo "🧹 Limpieza:"
	@echo "  make clean          - Limpiar build cache"
	@echo "  make clean-all      - Limpieza profunda"
	@echo "  make reset          - Reset completo del proyecto"
	@echo ""
	@echo "🔍 Análisis:"
	@echo "  make analyze        - Análisis estático de código"
	@echo "  make format         - Formatear código Dart"
	@echo "  make format-check   - Verificar formato"
	@echo "  make lint           - Verificar linting"
	@echo ""
	@echo "🔥 Firebase:"
	@echo "  make firebase-test  - Probar integración de Firebase"
	@echo "  make crashlytics    - Ver logs de Crashlytics"
	@echo ""
	@echo "📦 Git:"
	@echo "  make commit         - Commit interactivo"
	@echo "  make status         - Ver estado de git"
	@echo "  make push           - Push a origin"

# Setup inicial completo
setup:
	@echo "🚀 Configurando proyecto Tamagotchi..."
	flutter pub get
	@echo "✅ Dependencias instaladas"
	@echo "🔥 Verificando Firebase..."
	@test -f lib/firebase_options.dart && echo "✅ Firebase configurado" || echo "⚠️  Ejecuta 'flutterfire configure' para setup de Firebase"
	@echo "✅ Setup completado!"

# Dependencias
deps:
	@echo "📦 Instalando dependencias..."
	flutter pub get

upgrade:
	@echo "⬆️  Actualizando dependencias..."
	flutter pub upgrade

outdated:
	@echo "📊 Verificando paquetes desactualizados..."
	flutter pub outdated

# Ejecución
run:
	@echo "▶️  Ejecutando app en modo debug..."
	flutter run

run-release:
	@echo "▶️  Ejecutando app en modo release..."
	flutter run --release

devices:
	@echo "📱 Dispositivos disponibles:"
	flutter devices

hot-reload:
	@echo "🔥 Hot Reload Commands:"
	@echo "  r  - Hot reload (mantiene estado)"
	@echo "  R  - Hot restart (reinicia app)"
	@echo "  q  - Quit"

# Testing
test:
	@echo "🧪 Ejecutando tests..."
	flutter test

test-coverage:
	@echo "📊 Ejecutando tests con cobertura..."
	flutter test --coverage
	@echo "✅ Reporte generado en: coverage/lcov.info"

test-watch:
	@echo "👀 Ejecutando tests en modo watch..."
	@echo "⚠️  Este comando requiere 'flutter_test' en modo watch"
	flutter test --watch

# Build
build-apk:
	@echo "🔨 Building APK debug..."
	flutter build apk

build-release:
	@echo "🔨 Building APK release..."
	flutter build apk --release
	@echo "✅ APK generado en: build/app/outputs/flutter-apk/app-release.apk"

build-bundle:
	@echo "📦 Building Android App Bundle..."
	flutter build appbundle
	@echo "✅ Bundle generado en: build/app/outputs/bundle/release/app-release.aab"

# Limpieza
clean:
	@echo "🧹 Limpiando build cache..."
	flutter clean
	@echo "✅ Cache limpiado"

clean-all: clean
	@echo "🧹 Limpieza profunda..."
	rm -rf .dart_tool/
	rm -rf build/
	rm -rf .flutter-plugins
	rm -rf .flutter-plugins-dependencies
	@echo "✅ Limpieza profunda completada"

reset: clean-all
	@echo "🔄 Reseteando proyecto..."
	flutter pub get
	@echo "✅ Proyecto reseteado"

# Análisis de código
analyze:
	@echo "🔍 Analizando código..."
	flutter analyze

format:
	@echo "✨ Formateando código..."
	dart format lib/ test/

format-check:
	@echo "✅ Verificando formato..."
	dart format --set-exit-if-changed lib/ test/

lint: analyze format-check
	@echo "✅ Linting completado"

# Firebase
firebase-test:
	@echo "🔥 Probando integración de Firebase..."
	@echo "⚠️  Ejecuta la app en modo release para probar Crashlytics"
	@echo "   flutter run --release"

crashlytics:
	@echo "📊 Monitoreando logs de Crashlytics..."
	adb logcat | grep -i crashlytics

# Git helpers
commit:
	@echo "📝 Estado actual:"
	git status
	@echo ""
	@echo "💡 Usa: git add <archivos> && git commit -m 'mensaje'"

status:
	git status

push:
	@echo "📤 Pushing to origin..."
	git push origin main
