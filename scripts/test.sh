#!/bin/bash

# Script para ejecutar tests con diferentes configuraciones

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Tamagotchi - Test Runner${NC}"
echo ""

# Función para ejecutar tests básicos
run_basic_tests() {
    echo -e "${BLUE}▶️  Ejecutando tests básicos...${NC}"
    flutter test
    echo -e "${GREEN}✅ Tests completados${NC}"
}

# Función para ejecutar tests con cobertura
run_coverage_tests() {
    echo -e "${BLUE}▶️  Ejecutando tests con cobertura...${NC}"
    flutter test --coverage

    if [ -f "coverage/lcov.info" ]; then
        echo -e "${GREEN}✅ Reporte de cobertura generado${NC}"
        echo -e "${YELLOW}📊 Archivo: coverage/lcov.info${NC}"

        # Generar reporte HTML si lcov está instalado
        if command -v genhtml &> /dev/null; then
            echo -e "${BLUE}Generando reporte HTML...${NC}"
            genhtml coverage/lcov.info -o coverage/html
            echo -e "${GREEN}✅ Reporte HTML: coverage/html/index.html${NC}"
        else
            echo -e "${YELLOW}💡 Instala lcov para generar reportes HTML:${NC}"
            echo -e "${YELLOW}   brew install lcov  (macOS)${NC}"
            echo -e "${YELLOW}   apt-get install lcov  (Linux)${NC}"
        fi
    fi
}

# Función para ejecutar tests específicos
run_specific_test() {
    local test_file=$1
    echo -e "${BLUE}▶️  Ejecutando test: $test_file${NC}"
    flutter test "$test_file"
    echo -e "${GREEN}✅ Test completado${NC}"
}

# Función para verificar formato antes de tests
check_format() {
    echo -e "${BLUE}🔍 Verificando formato de código...${NC}"
    if dart format --set-exit-if-changed lib/ test/; then
        echo -e "${GREEN}✅ Formato correcto${NC}"
    else
        echo -e "${YELLOW}⚠️  Código necesita formateo${NC}"
        echo -e "${YELLOW}Ejecuta: dart format lib/ test/${NC}"
        return 1
    fi
}

# Función para análisis antes de tests
check_analyze() {
    echo -e "${BLUE}🔍 Analizando código...${NC}"
    flutter analyze
    echo -e "${GREEN}✅ Análisis completado${NC}"
}

# Función para ejecutar todo (análisis + tests + cobertura)
run_all() {
    echo -e "${BLUE}🚀 Ejecutando suite completa de tests${NC}"
    echo ""

    check_format || exit 1
    echo ""

    check_analyze
    echo ""

    run_coverage_tests
    echo ""

    echo -e "${GREEN}✅ Suite completa ejecutada exitosamente${NC}"
}

# Main
case "$1" in
    "")
        run_basic_tests
        ;;
    coverage)
        run_coverage_tests
        ;;
    all)
        run_all
        ;;
    *)
        if [ -f "$1" ]; then
            run_specific_test "$1"
        else
            echo -e "${YELLOW}Uso: $0 [coverage|all|<archivo_de_test>]${NC}"
            echo ""
            echo "Ejemplos:"
            echo "  $0                    - Ejecutar tests básicos"
            echo "  $0 coverage           - Tests con cobertura"
            echo "  $0 all                - Suite completa (formato + análisis + cobertura)"
            echo "  $0 test/widget_test.dart - Test específico"
            exit 1
        fi
        ;;
esac
