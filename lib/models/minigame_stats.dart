/// Tipos de mini-juegos disponibles
enum MiniGameType {
  memory,
  slidingPuzzle,
  reactionRace,
}

/// Extensión para obtener información de cada mini-juego
extension MiniGameTypeExtension on MiniGameType {
  String get displayName {
    switch (this) {
      case MiniGameType.memory:
        return 'Memory';
      case MiniGameType.slidingPuzzle:
        return 'Puzzle Deslizante';
      case MiniGameType.reactionRace:
        return 'Carrera de Reacción';
    }
  }

  String get description {
    switch (this) {
      case MiniGameType.memory:
        return 'Encuentra las parejas de emojis';
      case MiniGameType.slidingPuzzle:
        return 'Ordena los números del 1 al 8';
      case MiniGameType.reactionRace:
        return 'Presiona cuando cambie el color';
    }
  }

  String get icon {
    switch (this) {
      case MiniGameType.memory:
        return '🧠';
      case MiniGameType.slidingPuzzle:
        return '🧩';
      case MiniGameType.reactionRace:
        return '⚡';
    }
  }

  int get colorValue {
    switch (this) {
      case MiniGameType.memory:
        return 0xFF9C27B0; // Púrpura
      case MiniGameType.slidingPuzzle:
        return 0xFF2196F3; // Azul
      case MiniGameType.reactionRace:
        return 0xFFFF9800; // Naranja
    }
  }
}

/// Estadísticas de un mini-juego específico
///
/// Almacena métricas de rendimiento de un jugador en un tipo de mini-juego,
/// incluyendo victorias, récords y recompensas acumuladas.
class GameStats {
  /// Tipo de mini-juego al que pertenecen estas estadísticas
  final MiniGameType gameType;

  /// Número total de partidas jugadas
  int timesPlayed;

  /// Número de partidas ganadas
  int timesWon;

  /// Mejor puntuación obtenida
  int bestScore;

  /// Experiencia total acumulada en este juego
  int totalXpEarned;

  /// Monedas totales ganadas en este juego
  int totalCoinsEarned;

  GameStats({
    required this.gameType,
    this.timesPlayed = 0,
    this.timesWon = 0,
    this.bestScore = 0,
    this.totalXpEarned = 0,
    this.totalCoinsEarned = 0,
  });

  /// Calcula el porcentaje de victorias
  ///
  /// Retorna un valor entre 0 y 100 representando el porcentaje de victorias.
  /// Si no se han jugado partidas, retorna 0.
  double get winRate {
    if (timesPlayed == 0) return 0;
    return (timesWon / timesPlayed) * 100;
  }

  /// Serializa las estadísticas del juego a formato JSON para persistencia
  ///
  /// Retorna un mapa con todos los campos serializados, usando el índice
  /// del enum para el tipo de juego.
  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType.index,
      'timesPlayed': timesPlayed,
      'timesWon': timesWon,
      'bestScore': bestScore,
      'totalXpEarned': totalXpEarned,
      'totalCoinsEarned': totalCoinsEarned,
    };
  }

  /// Deserializa estadísticas desde formato JSON
  ///
  /// [json] Mapa con los datos serializados
  /// Retorna una instancia de GameStats con valores por defecto si algún campo falta
  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gameType: MiniGameType.values[json['gameType'] as int],
      timesPlayed: json['timesPlayed'] as int? ?? 0,
      timesWon: json['timesWon'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] as int? ?? 0,
    );
  }

  /// Crea una copia inmutable con campos específicos actualizados
  ///
  /// Permite actualizar campos individuales sin modificar la instancia original.
  /// Los parámetros opcionales que se omitan mantendrán sus valores actuales.
  GameStats copyWith({
    int? timesPlayed,
    int? timesWon,
    int? bestScore,
    int? totalXpEarned,
    int? totalCoinsEarned,
  }) {
    return GameStats(
      gameType: gameType,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      timesWon: timesWon ?? this.timesWon,
      bestScore: bestScore ?? this.bestScore,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
    );
  }
}

/// Contenedor de estadísticas para todos los mini-juegos disponibles
///
/// Mantiene un mapa de estadísticas individuales por cada tipo de mini-juego,
/// proporcionando métodos de agregación y acceso conveniente.
class MiniGameStats {
  /// Mapa de estadísticas por tipo de mini-juego
  final Map<MiniGameType, GameStats> stats;

  MiniGameStats({Map<MiniGameType, GameStats>? stats})
      : stats = stats ??
            {
              MiniGameType.memory: GameStats(gameType: MiniGameType.memory),
              MiniGameType.slidingPuzzle:
                  GameStats(gameType: MiniGameType.slidingPuzzle),
              MiniGameType.reactionRace:
                  GameStats(gameType: MiniGameType.reactionRace),
            };

  /// Total de partidas jugadas
  int get totalGamesPlayed =>
      stats.values.fold(0, (sum, stat) => sum + stat.timesPlayed);

  /// Total de victorias
  int get totalWins =>
      stats.values.fold(0, (sum, stat) => sum + stat.timesWon);

  /// Total de XP ganado en mini-juegos
  int get totalXpEarned =>
      stats.values.fold(0, (sum, stat) => sum + stat.totalXpEarned);

  /// Total de monedas ganadas en mini-juegos
  int get totalCoinsEarned =>
      stats.values.fold(0, (sum, stat) => sum + stat.totalCoinsEarned);

  /// Obtiene estadísticas de un juego específico
  ///
  /// [gameType] Tipo de mini-juego del que se quieren obtener estadísticas
  /// Retorna las estadísticas existentes o un objeto nuevo si no existen
  GameStats getStats(MiniGameType gameType) {
    return stats[gameType] ?? GameStats(gameType: gameType);
  }

  /// Actualiza estadísticas de un juego específico
  ///
  /// [gameType] Tipo de mini-juego a actualizar
  /// [newStats] Nuevas estadísticas para el juego
  /// Retorna una nueva instancia de MiniGameStats con las estadísticas actualizadas
  MiniGameStats updateGameStats(MiniGameType gameType, GameStats newStats) {
    final newStatsMap = Map<MiniGameType, GameStats>.from(stats);
    newStatsMap[gameType] = newStats;
    return MiniGameStats(stats: newStatsMap);
  }

  /// Serializa todas las estadísticas a formato JSON
  ///
  /// Retorna un mapa con las estadísticas de todos los juegos, usando
  /// el índice del enum como clave en formato string.
  Map<String, dynamic> toJson() {
    return {
      'stats': stats.map((key, value) => MapEntry(key.index.toString(), value.toJson())),
    };
  }

  /// Deserializa estadísticas completas desde formato JSON
  ///
  /// [json] Mapa con los datos serializados de todas las estadísticas
  /// Asegura que todos los tipos de juego tengan estadísticas, creando
  /// objetos vacíos para aquellos que falten.
  factory MiniGameStats.fromJson(Map<String, dynamic> json) {
    final statsMap = <MiniGameType, GameStats>{};

    if (json['stats'] != null) {
      final statsJson = json['stats'] as Map<String, dynamic>;
      statsJson.forEach((key, value) {
        final gameType = MiniGameType.values[int.parse(key)];
        statsMap[gameType] = GameStats.fromJson(value as Map<String, dynamic>);
      });
    }

    // Asegurar que todos los juegos tengan estadísticas
    for (final gameType in MiniGameType.values) {
      statsMap.putIfAbsent(gameType, () => GameStats(gameType: gameType));
    }

    return MiniGameStats(stats: statsMap);
  }
}

/// Resultado de una partida de mini-juego completada
///
/// Encapsula los resultados y recompensas obtenidas al finalizar
/// una partida de cualquier tipo de mini-juego.
class GameResult {
  /// Tipo de mini-juego jugado
  final MiniGameType gameType;

  /// Indica si el jugador ganó la partida
  final bool won;

  /// Puntuación obtenida (mayor es mejor)
  final int score;

  /// Experiencia ganada como recompensa
  final int xpEarned;

  /// Monedas ganadas como recompensa
  final int coinsEarned;

  /// Duración total de la partida
  final Duration duration;

  GameResult({
    required this.gameType,
    required this.won,
    required this.score,
    required this.xpEarned,
    required this.coinsEarned,
    required this.duration,
  });
}
