# Fase 10: Sistema de Mini-Juegos

## 📋 Descripción

La Fase 10 implementa un sistema completo de mini-juegos que permite al usuario ganar experiencia (XP) y monedas jugando diferentes juegos casuales. Este sistema mejora la experiencia del usuario y proporciona una forma alternativa de progresar además del cuidado básico de la mascota.

## ✨ Características Implementadas

### 🎮 Mini-Juegos Disponibles

#### 1. Memory Game (Parejas de Memoria) 🧠
- **Objetivo**: Encontrar todas las parejas de emojis volteando cartas
- **Mecánica**: Grid de 4x4 (16 cartas, 8 parejas)
- **Emojis**: Mascotas temáticas (🐶, 🐱, 🐭, 🐹, 🐰, 🦊, 🐻, 🐼)
- **Sistema de puntuación**:
  - Puntuación base: 1000 puntos
  - Penalización por movimientos: -10 puntos por movimiento
  - Penalización por tiempo: -2 puntos por segundo
- **Recompensas**:
  - XP base: 50
  - Monedas base: 10
  - Bonus por velocidad:
    - ≤12 movimientos: +30 XP, +15 monedas
    - ≤16 movimientos: +20 XP, +10 monedas
    - ≤20 movimientos: +10 XP, +5 monedas
  - Bonus por tiempo (≤60s): +20 XP, +10 monedas
- **Temporizador**: Tiempo real en segundos
- **Contador de movimientos**: Rastreo completo de intentos

#### 2. Sliding Puzzle (Rompecabezas Deslizante) 🧩
- **Objetivo**: Ordenar números del 1 al 8 deslizando piezas
- **Mecánica**: Grid de 3x3 con una casilla vacía
- **Generación**: 100 movimientos aleatorios para asegurar resolubilidad
- **Sistema de puntuación**:
  - Puntuación base: 1000 puntos
  - Penalización por movimientos: -5 puntos por movimiento
  - Penalización por tiempo: -3 puntos por segundo
- **Recompensas**:
  - XP base: 60
  - Monedas base: 15
  - Bonus por movimientos:
    - ≤50 movimientos: +40 XP, +20 monedas
    - ≤100 movimientos: +25 XP, +12 monedas
    - ≤150 movimientos: +15 XP, +8 monedas
  - Bonus por tiempo (≤120s): +25 XP, +10 monedas
- **Indicador visual**: Piezas adyacentes al espacio vacío se destacan
- **Temporizador**: Contador en tiempo real

#### 3. Reaction Race (Carrera de Reacción) ⚡
- **Objetivo**: Presionar cuando el círculo cambie a verde
- **Mecánica**: 10 rondas con tiempos de espera aleatorios
- **Tiempo de espera**: 1-4 segundos antes de cambiar a verde
- **Penalización**: Si presionas muy temprano, pierdes la ronda
- **Sistema de puntuación**:
  - Puntuación base: 1000 puntos
  - Penalización por tiempo promedio: -0.5 puntos por ms
- **Recompensas**:
  - XP base: 40
  - Monedas base: 12
  - Bonus por velocidad promedio:
    - <300ms: +50 XP, +25 monedas
    - <400ms: +35 XP, +18 monedas
    - <500ms: +20 XP, +10 monedas
  - Bonus por ronda perfecta (10/10): +30 XP, +15 monedas
- **Tracking**: Historial de todos los tiempos de reacción
- **Feedback visual**: Colores dinámicos (naranja=espera, verde=¡ahora!, rojo=muy temprano)

### 💰 Sistema de Monedas

#### Nueva Métrica: Coins
- Campo `coins` agregado al modelo `Pet`
- Persistencia automática con SharedPreferences
- Display en AppBar de la pantalla principal
- Visual: Badge con emoji 🪙 y contador
- Preparado para futuras tiendas/mejoras

#### Ganancia de Monedas
- Cada mini-juego otorga monedas según rendimiento
- Bonus por velocidad y eficiencia
- Acumulativo sin límite superior

### 📊 Sistema de Estadísticas

#### MiniGameStats
Rastreo completo de estadísticas por juego:
- **Partidas jugadas**: Contador total de veces jugado
- **Partidas ganadas**: Victorias registradas
- **Mejor puntuación**: Récord histórico
- **XP total ganado**: Experiencia acumulada en ese juego
- **Monedas totales**: Monedas ganadas en ese juego
- **Tasa de victoria**: Porcentaje calculado automáticamente

#### Estadísticas Globales
- Total de partidas de todos los juegos
- Total de victorias
- XP total ganado en mini-juegos
- Monedas totales ganadas
- Display en pantalla de selección

### 🎯 Pantalla de Selección

#### Características
- **Lista de juegos**: Cards interactivas para cada mini-juego
- **Información visual**:
  - Icono temático (emoji grande)
  - Color distintivo por juego
  - Descripción breve
- **Estadísticas por juego**:
  - Número de partidas
  - Porcentaje de victorias
  - Mejor puntuación
  - Badge "¡Nuevo!" para juegos sin jugar
- **Resumen general**:
  - Estadísticas agregadas en card superior
  - Iconos representativos
  - Diseño limpio y organizado

### 🔄 Integración con Sistema Existente

#### Actualización del Modelo Pet
```dart
// Nuevo campo
int coins; // Monedas ganadas en mini-juegos

// Actualización en toJson(), fromJson() y copyWith()
```

#### Actualización de StorageService
```dart
// Nuevos métodos
Future<void> saveMiniGameStats(MiniGameStats stats)
Future<MiniGameStats> loadMiniGameStats()
Future<void> updateGameStats(GameResult result)
```

#### Actualización de HomeScreen
- Display de monedas en AppBar
- Botón grande "Mini-Juegos" 🎮
- Navegación a pantalla de selección
- Callback para actualizar mascota después de jugar

### 🎨 Diseño y UX

#### Elementos de Diseño
- **Colores temáticos**:
  - Memory: Púrpura (#9C27B0)
  - Sliding Puzzle: Azul (#2196F3)
  - Reaction Race: Naranja (#FF9800)
- **Animaciones**:
  - Transiciones suaves entre estados
  - Feedback visual inmediato
  - Colores dinámicos en Reaction Race
- **Haptic Feedback**:
  - Tap en cartas/piezas
  - Aciertos y errores
  - Celebración de victoria

#### Diálogos de Victoria
Todos los juegos incluyen:
- Título celebratorio 🎉
- Resumen de estadísticas del juego
- Puntuación final
- XP y monedas ganadas (destacadas)
- Opciones: "Jugar de nuevo" y "Finalizar"

## 📁 Estructura de Archivos

```
lib/
├── models/
│   ├── pet.dart                    # ✏️ Actualizado (+ coins)
│   └── minigame_stats.dart         # ✨ Nuevo
├── screens/
│   ├── home_screen.dart            # ✏️ Actualizado (+ botón mini-juegos, display monedas)
│   └── games/                      # ✨ Nuevo directorio
│       ├── minigames_menu_screen.dart    # Pantalla de selección
│       ├── memory_game_screen.dart       # Memory Game
│       ├── sliding_puzzle_screen.dart    # Sliding Puzzle
│       └── reaction_race_screen.dart     # Reaction Race
└── services/
    └── storage_service.dart        # ✏️ Actualizado (+ métodos para stats)
```

## 🔧 Detalles Técnicos

### Modelos de Datos

#### MiniGameType (Enum)
```dart
enum MiniGameType {
  memory,
  slidingPuzzle,
  reactionRace,
}
```

Con extensiones para:
- `displayName`: Nombre legible
- `description`: Descripción corta
- `icon`: Emoji representativo
- `colorValue`: Color temático

#### GameStats
```dart
class GameStats {
  final MiniGameType gameType;
  int timesPlayed;
  int timesWon;
  int bestScore;
  int totalXpEarned;
  int totalCoinsEarned;

  double get winRate; // Calculado
}
```

#### MiniGameStats
```dart
class MiniGameStats {
  final Map<MiniGameType, GameStats> stats;

  // Getters agregados
  int get totalGamesPlayed;
  int get totalWins;
  int get totalXpEarned;
  int get totalCoinsEarned;
}
```

#### GameResult
```dart
class GameResult {
  final MiniGameType gameType;
  final bool won;
  final int score;
  final int xpEarned;
  final int coinsEarned;
  final Duration duration;
}
```

### Persistencia

#### Claves de SharedPreferences
- `pet_state`: Estado de la mascota (incluye coins)
- `minigame_stats`: Estadísticas de todos los mini-juegos

#### Flujo de Guardado
1. Usuario completa mini-juego
2. Se genera `GameResult`
3. Se actualiza mascota (XP y coins)
4. Se guardan estadísticas del juego
5. Se guarda estado de la mascota
6. Se notifica al HomeScreen

### Timers y Performance

#### Memory Game
- `Timer.periodic(1s)`: Actualización de reloj
- Cancelación en `dispose()`
- Delay de 1s para mostrar cartas incorrectas

#### Sliding Puzzle
- `Timer.periodic(1s)`: Actualización de reloj
- Validación de movimientos adyacentes
- Sin delay entre movimientos

#### Reaction Race
- Timer dinámico con Random(1-4s)
- Cancelación en cambio de estado
- Delay de 1.5s entre rondas

## 🎯 Balance de Recompensas

### Comparativa por Juego

| Juego | XP Base | XP Máximo | Monedas Base | Monedas Máx | Dificultad |
|-------|---------|-----------|--------------|-------------|------------|
| Memory | 50 | 100 | 10 | 35 | Media |
| Sliding Puzzle | 60 | 125 | 15 | 45 | Alta |
| Reaction Race | 40 | 120 | 12 | 47 | Baja-Media |

### Relación XP Mini-Juegos vs Acciones
- **Alimentar**: 10 XP (sin bonus)
- **Jugar**: 15 XP (sin bonus)
- **Limpiar**: 10 XP (sin bonus)
- **Descansar**: 5 XP (sin bonus)

Los mini-juegos ofrecen 3-8x más XP que acciones regulares, pero requieren tiempo y habilidad.

## 🚀 Cómo Usar

### Como Usuario

1. **Acceder a Mini-Juegos**:
   - Desde la pantalla principal, presiona el botón "🎮 Mini-Juegos"

2. **Seleccionar Juego**:
   - Revisa estadísticas generales en el card superior
   - Elige uno de los 3 mini-juegos disponibles
   - Observa tus récords y estadísticas

3. **Jugar**:
   - Lee las instrucciones en pantalla
   - Usa el botón "Reiniciar" para empezar de nuevo
   - Completa el objetivo del juego

4. **Recibir Recompensas**:
   - Al finalizar, verás tu puntuación y estadísticas
   - Recibirás XP y monedas según tu rendimiento
   - Elige "Jugar de nuevo" o "Finalizar"

5. **Ver Progreso**:
   - Tus monedas aparecen en el AppBar principal (🪙)
   - El XP se suma a tu experiencia total
   - Las estadísticas se guardan automáticamente

### Como Desarrollador

#### Agregar Nuevo Mini-Juego

1. **Actualizar MiniGameType**:
```dart
enum MiniGameType {
  memory,
  slidingPuzzle,
  reactionRace,
  nuevoJuego, // ✨ Agregar aquí
}
```

2. **Actualizar Extensión**:
```dart
extension MiniGameTypeExtension on MiniGameType {
  String get displayName {
    // ... casos existentes
    case MiniGameType.nuevoJuego:
      return 'Nombre del Juego';
  }
  // ... otros getters
}
```

3. **Crear Pantalla del Juego**:
```dart
class NuevoJuegoScreen extends StatefulWidget {
  final Pet pet;
  final Function(Pet updatedPet, GameResult result) onGameComplete;

  // ... implementación
}
```

4. **Agregar a Menu**:
```dart
// En minigames_menu_screen.dart
void _navigateToGame(MiniGameType gameType) {
  // ... casos existentes
  case MiniGameType.nuevoJuego:
    gameScreen = NuevoJuegoScreen(...);
    break;
}
```

## 🧪 Pruebas Realizadas

### Casos de Prueba

#### Memory Game
- ✅ Mezcla aleatoria de cartas
- ✅ Detección correcta de parejas
- ✅ Animación de volteo
- ✅ Contador de movimientos preciso
- ✅ Temporizador funcional
- ✅ Cálculo correcto de recompensas

#### Sliding Puzzle
- ✅ Generación de puzzle resoluble
- ✅ Validación de movimientos adyacentes
- ✅ Detección de victoria correcta
- ✅ Indicadores visuales de piezas movibles
- ✅ Reset correcto del estado

#### Reaction Race
- ✅ Tiempos de espera aleatorios
- ✅ Detección de presión temprana
- ✅ Medición precisa de tiempo de reacción
- ✅ Tracking de 10 rondas
- ✅ Cálculo de promedios

#### Integración
- ✅ Navegación fluida entre pantallas
- ✅ Persistencia de estadísticas
- ✅ Actualización de mascota (XP y monedas)
- ✅ Display correcto en HomeScreen
- ✅ Callbacks funcionan correctamente

## 📈 Mejoras Futuras (Opcionales)

### Corto Plazo
- [ ] Más niveles de dificultad por juego
- [ ] Leaderboards locales
- [ ] Logros y trofeos
- [ ] Efectos de sonido

### Medio Plazo
- [ ] Más mini-juegos (Puzzle de líneas, Simon dice, etc.)
- [ ] Tienda para gastar monedas
- [ ] Items especiales desbloqueables
- [ ] Modo multijugador local

### Largo Plazo
- [ ] Torneos semanales
- [ ] Ranking en línea
- [ ] Compartir puntuaciones
- [ ] Desafíos diarios

## 🐛 Problemas Conocidos

### Advertencias (No críticas)
- Uso de `.withOpacity()` deprecado en algunas partes (Flutter recomienda `.withValues()`)
- Campo `_reactionTimes` podría ser final en ReactionRaceScreen

### Soluciones
Estas advertencias son menores y no afectan la funcionalidad. Se pueden corregir en una futura refactorización.

## 📝 Notas de Implementación

### Decisiones de Diseño

1. **Temporizadores Locales**: Cada juego maneja su propio timer para evitar conflictos
2. **Inmutabilidad**: Los resultados se pasan mediante callbacks para mantener el flujo de datos unidireccional
3. **Persistencia Inmediata**: Las estadísticas se guardan después de cada partida
4. **Balance de Recompensas**: Ajustado para que los mini-juegos sean atractivos pero no trivialicen el cuidado básico

### Patrones Utilizados
- **Callback Pattern**: Para comunicación entre pantallas
- **State Management**: StatefulWidget con setState
- **Factory Pattern**: Para creación de GameStats desde JSON
- **Extension Methods**: Para agregar funcionalidad a enums

## ✅ Checklist de Implementación

- [x] Modelo de datos para mini-juegos
- [x] Sistema de monedas en Pet
- [x] Persistencia de estadísticas
- [x] Memory Game completo
- [x] Sliding Puzzle completo
- [x] Reaction Race completo
- [x] Pantalla de selección
- [x] Integración con HomeScreen
- [x] Display de monedas
- [x] Sistema de recompensas
- [x] Haptic feedback
- [x] Documentación completa

## 🎓 Conclusión

La Fase 10 agrega una dimensión completamente nueva al juego, proporcionando:
- **Variedad**: 3 mini-juegos diferentes con mecánicas únicas
- **Progresión**: Forma alternativa de ganar XP
- **Economía**: Sistema de monedas para futuras expansiones
- **Engagement**: Contenido adicional para mantener interés
- **Polish**: UX pulida con feedback visual y háptico

El sistema está diseñado para ser extensible, permitiendo agregar fácilmente nuevos mini-juegos en el futuro.

---

**Fase 10 Completada** ✅
Fecha: 2024-12-30
Versión: 1.0.0
