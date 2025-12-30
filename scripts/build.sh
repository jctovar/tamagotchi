#!/bin/bash

# Script para builds automatizados con verificaciones

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

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
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════${NC}"
}

# Verificar dependencias
check_dependencies() {
    info "Verificando dependencias..."
    flutter pub get
    success "Dependencias actualizadas"
}

# Ejecutar análisis
run_analysis() {
    info "Ejecutando análisis de código..."
    flutter analyze
    success "Análisis completado sin errores"
}

# Ejecutar tests
run_tests() {
    info "Ejecutando tests..."
    flutter test
    success "Todos los tests pasaron"
}

# Build APK Debug
build_apk_debug() {
    header "🔨 Building APK Debug"

    check_dependencies
    info "Building APK..."
    flutter build apk

    success "APK Debug generado exitosamente"
    info "Ubicación: build/app/outputs/flutter-apk/app-debug.apk"

    # Mostrar tamaño del APK
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-debug.apk | cut -f1)
        info "Tamaño del APK: $size"
    fi
}

# Build APK Release
build_apk_release() {
    header "🔨 Building APK Release"

    check_dependencies
    run_analysis
    run_tests

    info "Building APK Release..."
    flutter build apk --release

    success "APK Release generado exitosamente"
    info "Ubicación: build/app/outputs/flutter-apk/app-release.apk"

    # Mostrar tamaño del APK
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        info "Tamaño del APK: $size"
    fi

    warning "Recuerda: Este APK debe ser firmado para distribución en Play Store"
}

# Build App Bundle
build_bundle() {
    header "📦 Building Android App Bundle"

    check_dependencies
    run_analysis
    run_tests

    info "Building App Bundle..."
    flutter build appbundle

    success "App Bundle generado exitosamente"
    info "Ubicación: build/app/outputs/bundle/release/app-release.aab"

    # Mostrar tamaño del Bundle
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        local size=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
        info "Tamaño del Bundle: $size"
    fi

    success "Listo para subir a Google Play Console"
}

# Build con análisis de tamaño
build_with_size_analysis() {
    header "📊 Build con Análisis de Tamaño"

    info "Building APK con análisis de tamaño..."
    flutter build apk --analyze-size

    success "Análisis completado"
}

# Build optimizado
build_optimized() {
    header "⚡ Build Optimizado"

    check_dependencies
    run_analysis
    run_tests

    info "Building APK Release optimizado..."
    flutter build apk --release --shrink --split-per-abi

    success "APKs optimizados generados"
    info "Ubicación: build/app/outputs/flutter-apk/"

    # Listar APKs generados
    if [ -d "build/app/outputs/flutter-apk/" ]; then
        echo ""
        info "APKs generados:"
        ls -lh build/app/outputs/flutter-apk/*.apk | awk '{print "  " $9 " - " $5}'
    fi
}

# Limpiar y rebuild
clean_build() {
    header "🧹 Clean Build"

    warning "Limpiando proyecto..."
    flutter clean

    info "Obteniendo dependencias..."
    flutter pub get

    info "Building APK..."
    flutter build apk --release

    success "Clean build completado"
}

# Mostrar ayuda
show_help() {
    header "🔨 Tamagotchi - Build Script"
    echo ""
    echo "Uso: ./scripts/build.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo ""
    echo "  debug           - Build APK debug (rápido, sin tests)"
    echo "  release         - Build APK release (con análisis y tests)"
    echo "  bundle          - Build Android App Bundle (para Play Store)"
    echo "  optimized       - Build APKs optimizados por ABI"
    echo "  analyze         - Build con análisis de tamaño"
    echo "  clean           - Limpiar y rebuild"
    echo "  help            - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./scripts/build.sh debug"
    echo "  ./scripts/build.sh release"
    echo "  ./scripts/build.sh bundle"
}

# Main
case "$1" in
    debug)
        build_apk_debug
        ;;
    release)
        build_apk_release
        ;;
    bundle)
        build_bundle
        ;;
    optimized)
        build_optimized
        ;;
    analyze)
        build_with_size_analysis
        ;;
    clean)
        clean_build
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        error "Comando no reconocido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
