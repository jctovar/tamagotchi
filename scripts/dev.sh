#!/bin/bash

# Script de desarrollo para Tamagotchi
# Proporciona comandos útiles para el desarrollo diario

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

header() {
    echo -e "${PURPLE}$1${NC}"
}

# Función para verificar si Flutter está instalado
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        error "Flutter no está instalado"
        exit 1
    fi
    success "Flutter encontrado: $(flutter --version | head -n 1)"
}

# Función para setup inicial
setup() {
    header "🚀 Setup Inicial de Tamagotchi"
    check_flutter

    info "Instalando dependencias..."
    flutter pub get

    info "Verificando configuración de Firebase..."
    if [ -f "lib/firebase_options.dart" ]; then
        success "Firebase configurado correctamente"
    else
        warning "Firebase no configurado. Ejecuta: flutterfire configure"
    fi

    info "Verificando dispositivos disponibles..."
    flutter devices

    success "Setup completado!"
}

# Función para ejecutar la app
run() {
    header "▶️  Ejecutando Tamagotchi"
    check_flutter

    if [ "$1" == "release" ]; then
        info "Modo: Release (con Firebase Crashlytics activo)"
        flutter run --release
    else
        info "Modo: Debug"
        flutter run
    fi
}

# Función para ejecutar tests
test_app() {
    header "🧪 Ejecutando Tests"
    check_flutter

    if [ "$1" == "coverage" ]; then
        info "Generando reporte de cobertura..."
        flutter test --coverage
        success "Reporte generado en: coverage/lcov.info"
    else
        flutter test
    fi
}

# Función para build
build() {
    header "🔨 Building Tamagotchi"
    check_flutter

    case "$1" in
        apk)
            info "Building APK debug..."
            flutter build apk
            success "APK generado en: build/app/outputs/flutter-apk/app-debug.apk"
            ;;
        release)
            info "Building APK release..."
            flutter build apk --release
            success "APK generado en: build/app/outputs/flutter-apk/app-release.apk"
            ;;
        bundle)
            info "Building Android App Bundle..."
            flutter build appbundle
            success "Bundle generado en: build/app/outputs/bundle/release/app-release.aab"
            ;;
        *)
            error "Opción no válida. Usa: apk, release, o bundle"
            exit 1
            ;;
    esac
}

# Función para análisis de código
analyze() {
    header "🔍 Análisis de Código"
    check_flutter

    info "Ejecutando flutter analyze..."
    flutter analyze

    info "Verificando formato de código..."
    dart format --set-exit-if-changed lib/ test/ || {
        warning "Código necesita formateo. Ejecuta: dart format lib/ test/"
    }

    success "Análisis completado"
}

# Función para limpieza
clean() {
    header "🧹 Limpiando Proyecto"

    if [ "$1" == "deep" ]; then
        warning "Limpieza profunda..."
        flutter clean
        rm -rf .dart_tool/
        rm -rf build/
        rm -rf .flutter-plugins
        rm -rf .flutter-plugins-dependencies
        success "Limpieza profunda completada"

        info "Reinstalando dependencias..."
        flutter pub get
    else
        info "Limpieza normal..."
        flutter clean
        success "Cache limpiado"
    fi
}

# Función para Firebase
firebase_tools() {
    header "🔥 Firebase Tools"

    case "$1" in
        test)
            info "Para probar Crashlytics, ejecuta la app en release:"
            echo "  flutter run --release"
            echo ""
            info "Luego fuerza un crash para verificar:"
            echo "  Presiona el botón 'Test Crash' en la app"
            ;;
        logs)
            info "Monitoreando logs de Firebase..."
            adb logcat | grep -i firebase
            ;;
        crashlytics)
            info "Monitoreando logs de Crashlytics..."
            adb logcat | grep -i crashlytics
            ;;
        *)
            info "Comandos disponibles:"
            echo "  test        - Instrucciones para probar Firebase"
            echo "  logs        - Ver logs de Firebase"
            echo "  crashlytics - Ver logs de Crashlytics"
            ;;
    esac
}

# Función para git helpers
git_helper() {
    header "📦 Git Helper"

    case "$1" in
        status)
            git status
            ;;
        commit)
            info "Cambios actuales:"
            git status
            echo ""
            warning "Usa: git add <archivos> && git commit -m 'mensaje'"
            ;;
        push)
            info "Pushing to origin..."
            git push origin main
            ;;
        *)
            info "Comandos disponibles:"
            echo "  status - Ver estado de git"
            echo "  commit - Ayuda para commit"
            echo "  push   - Push a origin/main"
            ;;
    esac
}

# Función para mostrar ayuda
show_help() {
    header "📱 Tamagotchi - Script de Desarrollo"
    echo ""
    echo "Uso: ./scripts/dev.sh [comando] [opciones]"
    echo ""
    echo "Comandos disponibles:"
    echo ""
    echo "  setup                 - Setup inicial del proyecto"
    echo "  run [release]         - Ejecutar app (debug o release)"
    echo "  test [coverage]       - Ejecutar tests (con o sin cobertura)"
    echo "  build <tipo>          - Build app (apk, release, bundle)"
    echo "  analyze               - Análisis estático de código"
    echo "  clean [deep]          - Limpiar proyecto (normal o profundo)"
    echo "  firebase <cmd>        - Herramientas de Firebase"
    echo "  git <cmd>             - Helpers de Git"
    echo "  help                  - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./scripts/dev.sh setup"
    echo "  ./scripts/dev.sh run release"
    echo "  ./scripts/dev.sh test coverage"
    echo "  ./scripts/dev.sh build release"
    echo "  ./scripts/dev.sh clean deep"
    echo "  ./scripts/dev.sh firebase crashlytics"
}

# Main - procesar comando
case "$1" in
    setup)
        setup
        ;;
    run)
        run "$2"
        ;;
    test)
        test_app "$2"
        ;;
    build)
        build "$2"
        ;;
    analyze)
        analyze
        ;;
    clean)
        clean "$2"
        ;;
    firebase)
        firebase_tools "$2"
        ;;
    git)
        git_helper "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Comando no reconocido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
