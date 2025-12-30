/// Modelo para el historial de interacciones del usuario con la mascota
///
/// Este modelo permite trackear todas las acciones del usuario para que
/// la IA pueda aprender patrones y preferencias.
library;

/// Tipos de interacciones disponibles
enum InteractionType {
  feed('feed', 'Alimentar', '🍔'),
  play('play', 'Jugar', '🎮'),
  clean('clean', 'Limpiar', '🧼'),
  rest('rest', 'Descansar', '😴'),
  minigame('minigame', 'Mini-juego', '🎯'),
  customize('customize', 'Personalizar', '🎨'),
  evolve('evolve', 'Evolución', '✨'),
  appOpen('app_open', 'Abrir app', '📱'),
  appClose('app_close', 'Cerrar app', '👋');

  final String id;
  final String displayName;
  final String emoji;

  const InteractionType(this.id, this.displayName, this.emoji);
}

/// Contexto temporal de una interacción
enum TimeOfDay {
  earlyMorning(0, 6, 'Madrugada', '🌙'),     // 00:00 - 05:59
  morning(6, 12, 'Mañana', '🌅'),            // 06:00 - 11:59
  afternoon(12, 18, 'Tarde', '☀️'),          // 12:00 - 17:59
  evening(18, 21, 'Noche', '🌆'),            // 18:00 - 20:59
  night(21, 24, 'Noche tarde', '🌙');        // 21:00 - 23:59

  final int startHour;
  final int endHour;
  final String displayName;
  final String emoji;

  const TimeOfDay(this.startHour, this.endHour, this.displayName, this.emoji);

  /// Obtiene el período del día basado en la hora actual
  static TimeOfDay fromHour(int hour) {
    if (hour >= 0 && hour < 6) return earlyMorning;
    if (hour >= 6 && hour < 12) return morning;
    if (hour >= 12 && hour < 18) return afternoon;
    if (hour >= 18 && hour < 21) return evening;
    return night;
  }

  /// Obtiene el período actual
  static TimeOfDay get current => fromHour(DateTime.now().hour);
}

/// Representa una interacción individual del usuario
class Interaction {
  final InteractionType type;
  final DateTime timestamp;
  final TimeOfDay timeOfDay;
  final int dayOfWeek; // 1 = Lunes, 7 = Domingo

  // Estado de la mascota en el momento de la interacción
  final double hungerBefore;
  final double happinessBefore;
  final double energyBefore;
  final double healthBefore;

  // Metadatos adicionales
  final Map<String, dynamic>? metadata;

  Interaction({
    required this.type,
    required this.timestamp,
    required this.hungerBefore,
    required this.happinessBefore,
    required this.energyBefore,
    required this.healthBefore,
    this.metadata,
  })  : timeOfDay = TimeOfDay.fromHour(timestamp.hour),
        dayOfWeek = timestamp.weekday;

  /// Crea una interacción con el timestamp actual
  factory Interaction.now({
    required InteractionType type,
    required double hungerBefore,
    required double happinessBefore,
    required double energyBefore,
    required double healthBefore,
    Map<String, dynamic>? metadata,
  }) {
    return Interaction(
      type: type,
      timestamp: DateTime.now(),
      hungerBefore: hungerBefore,
      happinessBefore: happinessBefore,
      energyBefore: energyBefore,
      healthBefore: healthBefore,
      metadata: metadata,
    );
  }

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'type': type.id,
      'timestamp': timestamp.toIso8601String(),
      'hungerBefore': hungerBefore,
      'happinessBefore': happinessBefore,
      'energyBefore': energyBefore,
      'healthBefore': healthBefore,
      'metadata': metadata,
    };
  }

  /// Crea desde JSON
  factory Interaction.fromJson(Map<String, dynamic> json) {
    final typeId = json['type'] as String;
    final type = InteractionType.values.firstWhere(
      (t) => t.id == typeId,
      orElse: () => InteractionType.appOpen,
    );

    return Interaction(
      type: type,
      timestamp: DateTime.parse(json['timestamp'] as String),
      hungerBefore: (json['hungerBefore'] as num).toDouble(),
      happinessBefore: (json['happinessBefore'] as num).toDouble(),
      energyBefore: (json['energyBefore'] as num).toDouble(),
      healthBefore: (json['healthBefore'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Verifica si la interacción fue reactiva (mascota en estado crítico)
  bool get wasReactive {
    return hungerBefore > 70 ||
           happinessBefore < 30 ||
           energyBefore < 30 ||
           healthBefore < 40;
  }

  /// Verifica si la interacción fue proactiva (mascota en buen estado)
  bool get wasProactive {
    return hungerBefore < 50 &&
           happinessBefore > 50 &&
           energyBefore > 50 &&
           healthBefore > 60;
  }
}

/// Historial completo de interacciones
class InteractionHistory {
  final List<Interaction> interactions;
  final DateTime? firstInteraction;
  final DateTime? lastInteraction;

  // Contadores por tipo
  final Map<InteractionType, int> interactionCounts;

  // Estadísticas de patrones
  final Map<TimeOfDay, int> timeOfDayDistribution;
  final Map<int, int> dayOfWeekDistribution;

  InteractionHistory({
    List<Interaction>? interactions,
  })  : interactions = interactions ?? [],
        firstInteraction = interactions?.isNotEmpty == true
            ? interactions!.first.timestamp
            : null,
        lastInteraction = interactions?.isNotEmpty == true
            ? interactions!.last.timestamp
            : null,
        interactionCounts = _countByType(interactions ?? []),
        timeOfDayDistribution = _countByTimeOfDay(interactions ?? []),
        dayOfWeekDistribution = _countByDayOfWeek(interactions ?? []);

  /// Cuenta interacciones por tipo
  static Map<InteractionType, int> _countByType(List<Interaction> interactions) {
    final counts = <InteractionType, int>{};
    for (final type in InteractionType.values) {
      counts[type] = 0;
    }
    for (final interaction in interactions) {
      counts[interaction.type] = (counts[interaction.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Cuenta interacciones por período del día
  static Map<TimeOfDay, int> _countByTimeOfDay(List<Interaction> interactions) {
    final counts = <TimeOfDay, int>{};
    for (final time in TimeOfDay.values) {
      counts[time] = 0;
    }
    for (final interaction in interactions) {
      counts[interaction.timeOfDay] = (counts[interaction.timeOfDay] ?? 0) + 1;
    }
    return counts;
  }

  /// Cuenta interacciones por día de la semana
  static Map<int, int> _countByDayOfWeek(List<Interaction> interactions) {
    final counts = <int, int>{};
    for (int i = 1; i <= 7; i++) {
      counts[i] = 0;
    }
    for (final interaction in interactions) {
      counts[interaction.dayOfWeek] = (counts[interaction.dayOfWeek] ?? 0) + 1;
    }
    return counts;
  }

  /// Total de interacciones
  int get totalInteractions => interactions.length;

  /// Días desde la primera interacción
  int get daysActive {
    if (firstInteraction == null) return 0;
    return DateTime.now().difference(firstInteraction!).inDays + 1;
  }

  /// Promedio de interacciones por día
  double get averageInteractionsPerDay {
    if (daysActive == 0) return 0;
    return totalInteractions / daysActive;
  }

  /// Interacción más frecuente
  InteractionType? get mostFrequentInteraction {
    if (interactions.isEmpty) return null;

    InteractionType? most;
    int maxCount = 0;

    for (final entry in interactionCounts.entries) {
      // Excluir appOpen y appClose
      if (entry.key == InteractionType.appOpen ||
          entry.key == InteractionType.appClose) {
        continue;
      }

      if (entry.value > maxCount) {
        maxCount = entry.value;
        most = entry.key;
      }
    }
    return most;
  }

  /// Período del día más activo
  TimeOfDay? get mostActiveTimeOfDay {
    if (interactions.isEmpty) return null;

    TimeOfDay? most;
    int maxCount = 0;

    for (final entry in timeOfDayDistribution.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        most = entry.key;
      }
    }
    return most;
  }

  /// Porcentaje de interacciones proactivas
  double get proactiveRatio {
    if (interactions.isEmpty) return 0;
    final proactive = interactions.where((i) => i.wasProactive).length;
    return proactive / interactions.length;
  }

  /// Porcentaje de interacciones reactivas
  double get reactiveRatio {
    if (interactions.isEmpty) return 0;
    final reactive = interactions.where((i) => i.wasReactive).length;
    return reactive / interactions.length;
  }

  /// Agrega una nueva interacción
  InteractionHistory addInteraction(Interaction interaction) {
    final newList = List<Interaction>.from(interactions)..add(interaction);
    // Mantener solo las últimas 1000 interacciones
    if (newList.length > 1000) {
      newList.removeRange(0, newList.length - 1000);
    }
    return InteractionHistory(interactions: newList);
  }

  /// Obtiene las últimas N interacciones
  List<Interaction> getLastInteractions(int count) {
    if (interactions.isEmpty) return [];
    final start = (interactions.length - count).clamp(0, interactions.length);
    return interactions.sublist(start);
  }

  /// Obtiene interacciones de las últimas N horas
  List<Interaction> getInteractionsLastHours(int hours) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return interactions.where((i) => i.timestamp.isAfter(cutoff)).toList();
  }

  /// Obtiene interacciones de hoy
  List<Interaction> get todayInteractions {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return interactions.where((i) => i.timestamp.isAfter(startOfDay)).toList();
  }

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'interactions': interactions.map((i) => i.toJson()).toList(),
    };
  }

  /// Crea desde JSON
  factory InteractionHistory.fromJson(Map<String, dynamic> json) {
    final interactionsJson = json['interactions'] as List<dynamic>? ?? [];
    final interactions = interactionsJson
        .map((i) => Interaction.fromJson(i as Map<String, dynamic>))
        .toList();
    return InteractionHistory(interactions: interactions);
  }
}
