/// Modelo de personalidad adaptativa de la mascota
///
/// La mascota desarrolla una personalidad única basada en cómo es cuidada.
/// Este sistema permite que la mascota "aprenda" y responda de manera
/// diferente según el historial de interacciones.
library;

import 'interaction_history.dart';

/// Traits de personalidad que la mascota puede desarrollar
enum PersonalityTrait {
  // Traits positivos
  playful('Juguetón', '🎮', 'Le encanta jugar y es muy activo'),
  cuddly('Cariñoso', '🥰', 'Busca atención y mimos constantemente'),
  curious('Curioso', '🔍', 'Siempre explorando y descubriendo'),
  calm('Tranquilo', '😌', 'Relajado y fácil de cuidar'),
  energetic('Energético', '⚡', 'Siempre lleno de energía'),
  foodie('Glotón', '🍕', 'Le encanta la comida'),

  // Traits neutros
  independent('Independiente', '🦁', 'No necesita tanta atención'),
  nocturnal('Nocturno', '🦉', 'Más activo por las noches'),
  earlyBird('Madrugador', '🐓', 'Más activo por las mañanas'),

  // Traits que pueden indicar descuido
  anxious('Ansioso', '😰', 'Se preocupa cuando no recibe atención'),
  shy('Tímido', '🙈', 'Se esconde y es reservado'),
  grumpy('Gruñón', '😤', 'A veces de mal humor');

  final String displayName;
  final String emoji;
  final String description;

  const PersonalityTrait(this.displayName, this.emoji, this.description);
}

/// Estado emocional actual de la mascota
enum EmotionalState {
  ecstatic('Extasiado', '🤩', 1.0),
  happy('Feliz', '😊', 0.8),
  content('Contento', '🙂', 0.6),
  neutral('Neutral', '😐', 0.5),
  bored('Aburrido', '😑', 0.4),
  sad('Triste', '😢', 0.3),
  lonely('Solitario', '😔', 0.2),
  anxious('Ansioso', '😰', 0.1);

  final String displayName;
  final String emoji;
  final double value; // 0-1, usado para cálculos

  const EmotionalState(this.displayName, this.emoji, this.value);
}

/// Nivel de vínculo con el usuario
enum BondLevel {
  stranger('Desconocido', 0, 'Tu mascota aún no te conoce'),
  acquaintance('Conocido', 50, 'Tu mascota te está conociendo'),
  friend('Amigo', 150, 'Tu mascota te considera su amigo'),
  bestFriend('Mejor amigo', 300, 'Tu mascota te adora'),
  soulmate('Alma gemela', 500, 'Vínculo inquebrantable');

  final String displayName;
  final int requiredInteractions;
  final String description;

  const BondLevel(
    this.displayName,
    this.requiredInteractions,
    this.description,
  );

  /// Obtiene el nivel de vínculo basado en interacciones
  static BondLevel fromInteractions(int count) {
    if (count >= 500) return soulmate;
    if (count >= 300) return bestFriend;
    if (count >= 150) return friend;
    if (count >= 50) return acquaintance;
    return stranger;
  }
}

/// Personalidad completa de la mascota
class PetPersonality {
  /// Traits de personalidad con su intensidad (0-100)
  final Map<PersonalityTrait, double> traits;

  /// Estado emocional actual
  final EmotionalState emotionalState;

  /// Nivel de vínculo con el usuario
  final BondLevel bondLevel;

  /// Puntos de vínculo acumulados
  final int bondPoints;

  /// Preferencias aprendidas del usuario
  final UserPreferences userPreferences;

  /// Timestamp de última actualización
  final DateTime lastUpdated;

  PetPersonality({
    Map<PersonalityTrait, double>? traits,
    this.emotionalState = EmotionalState.neutral,
    this.bondLevel = BondLevel.stranger,
    this.bondPoints = 0,
    UserPreferences? userPreferences,
    DateTime? lastUpdated,
  }) : traits = traits ?? _defaultTraits(),
       userPreferences = userPreferences ?? UserPreferences(),
       lastUpdated = lastUpdated ?? DateTime.now();

  /// Traits por defecto
  static Map<PersonalityTrait, double> _defaultTraits() {
    return {for (final trait in PersonalityTrait.values) trait: 50.0};
  }

  /// Obtiene los 3 traits más dominantes
  List<PersonalityTrait> get dominantTraits {
    final sorted = traits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Obtiene la intensidad de un trait específico
  double getTraitIntensity(PersonalityTrait trait) {
    return traits[trait] ?? 50.0;
  }

  /// Descripción textual de la personalidad
  String get personalityDescription {
    final dominant = dominantTraits;
    if (dominant.isEmpty)
      return 'Tu mascota aún está desarrollando su personalidad.';

    final traitNames = dominant
        .map((t) => t.displayName.toLowerCase())
        .toList();

    if (traitNames.length == 1) {
      return 'Tu mascota es muy ${traitNames[0]}.';
    } else if (traitNames.length == 2) {
      return 'Tu mascota es ${traitNames[0]} y ${traitNames[1]}.';
    } else {
      return 'Tu mascota es ${traitNames[0]}, ${traitNames[1]} y ${traitNames[2]}.';
    }
  }

  /// Actualiza la personalidad basándose en una nueva interacción
  PetPersonality updateFromInteraction(Interaction interaction) {
    final newTraits = Map<PersonalityTrait, double>.from(traits);
    var newBondPoints = bondPoints;

    // Incrementar puntos de vínculo por interacción
    if (interaction.type != InteractionType.appOpen &&
        interaction.type != InteractionType.appClose) {
      newBondPoints += 1;

      // Bonus por cuidado proactivo
      if (interaction.wasProactive) {
        newBondPoints += 2;
      }
    }

    // Ajustar traits según el tipo de interacción
    switch (interaction.type) {
      case InteractionType.play:
        newTraits[PersonalityTrait.playful] =
            (newTraits[PersonalityTrait.playful]! + 0.5).clamp(0, 100);
        newTraits[PersonalityTrait.energetic] =
            (newTraits[PersonalityTrait.energetic]! + 0.3).clamp(0, 100);
        break;

      case InteractionType.feed:
        newTraits[PersonalityTrait.foodie] =
            (newTraits[PersonalityTrait.foodie]! + 0.3).clamp(0, 100);
        break;

      case InteractionType.rest:
        newTraits[PersonalityTrait.calm] =
            (newTraits[PersonalityTrait.calm]! + 0.3).clamp(0, 100);
        break;

      case InteractionType.clean:
        // Limpiar frecuentemente -> mascota más tranquila
        newTraits[PersonalityTrait.calm] =
            (newTraits[PersonalityTrait.calm]! + 0.2).clamp(0, 100);
        break;

      case InteractionType.minigame:
        newTraits[PersonalityTrait.playful] =
            (newTraits[PersonalityTrait.playful]! + 0.8).clamp(0, 100);
        newTraits[PersonalityTrait.curious] =
            (newTraits[PersonalityTrait.curious]! + 0.4).clamp(0, 100);
        newBondPoints += 3; // Mini-juegos dan más puntos de vínculo
        break;

      case InteractionType.customize:
        newTraits[PersonalityTrait.cuddly] =
            (newTraits[PersonalityTrait.cuddly]! + 0.3).clamp(0, 100);
        break;

      default:
        break;
    }

    // Ajustar según hora del día
    switch (interaction.timeOfDay) {
      case TimeOfDay.earlyMorning:
      case TimeOfDay.morning:
        newTraits[PersonalityTrait.earlyBird] =
            (newTraits[PersonalityTrait.earlyBird]! + 0.2).clamp(0, 100);
        break;
      case TimeOfDay.night:
        newTraits[PersonalityTrait.nocturnal] =
            (newTraits[PersonalityTrait.nocturnal]! + 0.2).clamp(0, 100);
        break;
      default:
        break;
    }

    // Si la interacción fue reactiva, puede aumentar ansiedad
    if (interaction.wasReactive) {
      newTraits[PersonalityTrait.anxious] =
          (newTraits[PersonalityTrait.anxious]! + 0.2).clamp(0, 100);
    } else if (interaction.wasProactive) {
      // Cuidado proactivo reduce ansiedad
      newTraits[PersonalityTrait.anxious] =
          (newTraits[PersonalityTrait.anxious]! - 0.1).clamp(0, 100);
    }

    return copyWith(
      traits: newTraits,
      bondPoints: newBondPoints,
      bondLevel: BondLevel.fromInteractions(newBondPoints),
      lastUpdated: DateTime.now(),
    );
  }

  /// Calcula el estado emocional basado en métricas y personalidad
  PetPersonality updateEmotionalState({
    required double hunger,
    required double happiness,
    required double energy,
    required double health,
    required int minutesSinceLastInteraction,
  }) {
    // Base score calculado de las métricas
    double emotionScore = 0.0;

    // Felicidad es el factor principal
    emotionScore += (happiness / 100) * 0.4;

    // Salud afecta el estado emocional
    emotionScore += (health / 100) * 0.25;

    // Hambre inversa (menos hambre = mejor)
    emotionScore += ((100 - hunger) / 100) * 0.2;

    // Energía
    emotionScore += (energy / 100) * 0.15;

    // Ajustar por tiempo sin interacción
    if (minutesSinceLastInteraction > 60) {
      emotionScore -= 0.1;
    }
    if (minutesSinceLastInteraction > 180) {
      emotionScore -= 0.15;
    }
    if (minutesSinceLastInteraction > 360) {
      emotionScore -= 0.2;
    }

    // Ajustar por nivel de vínculo (mascota más vinculada es más estable)
    emotionScore += bondLevel.index * 0.02;

    // Ajustar por personalidad
    if (traits[PersonalityTrait.anxious]! > 70) {
      emotionScore -= 0.1;
    }
    if (traits[PersonalityTrait.calm]! > 70) {
      emotionScore += 0.05;
    }

    emotionScore = emotionScore.clamp(0, 1);

    // Determinar estado emocional
    EmotionalState newState;
    if (emotionScore >= 0.9) {
      newState = EmotionalState.ecstatic;
    } else if (emotionScore >= 0.75) {
      newState = EmotionalState.happy;
    } else if (emotionScore >= 0.6) {
      newState = EmotionalState.content;
    } else if (emotionScore >= 0.45) {
      newState = EmotionalState.neutral;
    } else if (emotionScore >= 0.35) {
      newState = EmotionalState.bored;
    } else if (emotionScore >= 0.25) {
      newState = EmotionalState.sad;
    } else if (emotionScore >= 0.15) {
      newState = EmotionalState.lonely;
    } else {
      newState = EmotionalState.anxious;
    }

    return copyWith(emotionalState: newState);
  }

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'traits': traits.map((k, v) => MapEntry(k.name, v)),
      'emotionalState': emotionalState.name,
      'bondLevel': bondLevel.name,
      'bondPoints': bondPoints,
      'userPreferences': userPreferences.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Crea desde JSON
  factory PetPersonality.fromJson(Map<String, dynamic> json) {
    final traitsJson = json['traits'] as Map<String, dynamic>? ?? {};
    final traits = <PersonalityTrait, double>{};

    for (final trait in PersonalityTrait.values) {
      traits[trait] = (traitsJson[trait.name] as num?)?.toDouble() ?? 50.0;
    }

    return PetPersonality(
      traits: traits,
      emotionalState: EmotionalState.values.firstWhere(
        (e) => e.name == json['emotionalState'],
        orElse: () => EmotionalState.neutral,
      ),
      bondLevel: BondLevel.values.firstWhere(
        (b) => b.name == json['bondLevel'],
        orElse: () => BondLevel.stranger,
      ),
      bondPoints: json['bondPoints'] as int? ?? 0,
      userPreferences: json['userPreferences'] != null
          ? UserPreferences.fromJson(
              json['userPreferences'] as Map<String, dynamic>,
            )
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Crea una copia con campos actualizados
  PetPersonality copyWith({
    Map<PersonalityTrait, double>? traits,
    EmotionalState? emotionalState,
    BondLevel? bondLevel,
    int? bondPoints,
    UserPreferences? userPreferences,
    DateTime? lastUpdated,
  }) {
    return PetPersonality(
      traits: traits ?? this.traits,
      emotionalState: emotionalState ?? this.emotionalState,
      bondLevel: bondLevel ?? this.bondLevel,
      bondPoints: bondPoints ?? this.bondPoints,
      userPreferences: userPreferences ?? this.userPreferences,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Preferencias del usuario aprendidas por la IA
class UserPreferences {
  /// Hora más frecuente de interacción (0-23)
  final int? preferredHour;

  /// Período del día más activo
  final TimeOfDay? preferredTimeOfDay;

  /// Día de la semana más activo (1-7)
  final int? preferredDayOfWeek;

  /// Tipo de interacción favorita
  final InteractionType? favoriteInteraction;

  /// Tiempo promedio entre sesiones (minutos)
  final int? averageSessionGap;

  /// Duración promedio de sesión (minutos)
  final int? averageSessionDuration;

  /// Nivel de consistencia del usuario (0-100)
  final double consistencyScore;

  UserPreferences({
    this.preferredHour,
    this.preferredTimeOfDay,
    this.preferredDayOfWeek,
    this.favoriteInteraction,
    this.averageSessionGap,
    this.averageSessionDuration,
    this.consistencyScore = 50.0,
  });

  /// Calcula si el usuario es consistente
  bool get isConsistent => consistencyScore > 70;

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'preferredHour': preferredHour,
      'preferredTimeOfDay': preferredTimeOfDay?.name,
      'preferredDayOfWeek': preferredDayOfWeek,
      'favoriteInteraction': favoriteInteraction?.id,
      'averageSessionGap': averageSessionGap,
      'averageSessionDuration': averageSessionDuration,
      'consistencyScore': consistencyScore,
    };
  }

  /// Crea desde JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredHour: json['preferredHour'] as int?,
      preferredTimeOfDay: json['preferredTimeOfDay'] != null
          ? TimeOfDay.values.firstWhere(
              (t) => t.name == json['preferredTimeOfDay'],
              orElse: () => TimeOfDay.morning,
            )
          : null,
      preferredDayOfWeek: json['preferredDayOfWeek'] as int?,
      favoriteInteraction: json['favoriteInteraction'] != null
          ? InteractionType.values.firstWhere(
              (i) => i.id == json['favoriteInteraction'],
              orElse: () => InteractionType.feed,
            )
          : null,
      averageSessionGap: json['averageSessionGap'] as int?,
      averageSessionDuration: json['averageSessionDuration'] as int?,
      consistencyScore: (json['consistencyScore'] as num?)?.toDouble() ?? 50.0,
    );
  }

  /// Crea una copia con campos actualizados
  UserPreferences copyWith({
    int? preferredHour,
    TimeOfDay? preferredTimeOfDay,
    int? preferredDayOfWeek,
    InteractionType? favoriteInteraction,
    int? averageSessionGap,
    int? averageSessionDuration,
    double? consistencyScore,
  }) {
    return UserPreferences(
      preferredHour: preferredHour ?? this.preferredHour,
      preferredTimeOfDay: preferredTimeOfDay ?? this.preferredTimeOfDay,
      preferredDayOfWeek: preferredDayOfWeek ?? this.preferredDayOfWeek,
      favoriteInteraction: favoriteInteraction ?? this.favoriteInteraction,
      averageSessionGap: averageSessionGap ?? this.averageSessionGap,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      consistencyScore: consistencyScore ?? this.consistencyScore,
    );
  }
}
