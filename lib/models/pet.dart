import 'life_stage.dart';

/// Modelo de datos para la mascota virtual Tamagotchi
class Pet {
  String name;
  double hunger; // 0-100: 0 = lleno, 100 = hambriento
  double happiness; // 0-100: 0 = triste, 100 = feliz
  double energy; // 0-100: 0 = cansado, 100 = energizado
  double health; // 0-100: 0 = enfermo, 100 = saludable
  DateTime lastFed;
  DateTime lastPlayed;
  DateTime lastCleaned;
  DateTime lastRested;

  // Sistema de evolución
  int experience; // Experiencia acumulada
  int totalTimeAlive; // Tiempo total vivo en segundos
  DateTime birthDate; // Fecha de nacimiento
  LifeStage lifeStage; // Etapa de vida actual
  PetVariant variant; // Variante según cuidado

  Pet({
    required this.name,
    this.hunger = 0,
    this.happiness = 100,
    this.energy = 100,
    this.health = 100,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastCleaned,
    DateTime? lastRested,
    this.experience = 0,
    this.totalTimeAlive = 0,
    DateTime? birthDate,
    this.lifeStage = LifeStage.egg,
    this.variant = PetVariant.normal,
  })  : lastFed = lastFed ?? DateTime.now(),
        lastPlayed = lastPlayed ?? DateTime.now(),
        lastCleaned = lastCleaned ?? DateTime.now(),
        lastRested = lastRested ?? DateTime.now(),
        birthDate = birthDate ?? DateTime.now();

  /// Estado de ánimo basado en las métricas
  PetMood get mood {
    if (health < 30 || hunger > 80 || energy < 20) {
      return PetMood.critical;
    } else if (happiness < 30) {
      return PetMood.sad;
    } else if (hunger > 60) {
      return PetMood.hungry;
    } else if (energy < 40) {
      return PetMood.tired;
    } else if (happiness > 70 && health > 70) {
      return PetMood.happy;
    }
    return PetMood.neutral;
  }

  /// Verifica si la mascota está en estado crítico
  bool get isCritical => mood == PetMood.critical;

  /// Verifica si la mascota está viva
  bool get isAlive => health > 0;

  /// Nivel actual basado en experiencia
  int get level => EvolutionUtils.calculateLevel(experience);

  /// Progreso hacia siguiente nivel (0-1)
  double get levelProgress => EvolutionUtils.levelProgress(experience, level);

  /// Experiencia necesaria para siguiente nivel
  int get experienceForNextLevel => EvolutionUtils.experienceForNextLevel(level);

  /// Actualiza tiempo vivo
  void updateTimeAlive() {
    totalTimeAlive = DateTime.now().difference(birthDate).inSeconds;
  }

  /// Gana experiencia por acción
  Pet gainExperience(String action) {
    final xp = EvolutionUtils.getExperienceForAction(action);
    return copyWith(experience: experience + xp);
  }

  /// Actualiza etapa de vida
  Pet updateLifeStage() {
    updateTimeAlive();
    final newStage = EvolutionUtils.calculateLifeStage(
      totalTimeAlive: totalTimeAlive,
      experience: experience,
    );
    return copyWith(lifeStage: newStage);
  }

  /// Actualiza variante según cuidado
  Pet updateVariant() {
    final newVariant = EvolutionUtils.calculateVariant(
      avgHealth: health,
      avgHappiness: happiness,
      avgEnergy: energy,
    );
    return copyWith(variant: newVariant);
  }

  /// Convierte el objeto Pet a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'health': health,
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'lastCleaned': lastCleaned.toIso8601String(),
      'lastRested': lastRested.toIso8601String(),
      'experience': experience,
      'totalTimeAlive': totalTimeAlive,
      'birthDate': birthDate.toIso8601String(),
      'lifeStage': lifeStage.index,
      'variant': variant.index,
    };
  }

  /// Crea un objeto Pet desde Map
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'] as String,
      hunger: (json['hunger'] as num).toDouble(),
      happiness: (json['happiness'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      health: (json['health'] as num).toDouble(),
      lastFed: DateTime.parse(json['lastFed'] as String),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      lastCleaned: DateTime.parse(json['lastCleaned'] as String),
      lastRested: DateTime.parse(json['lastRested'] as String),
      experience: json['experience'] as int? ?? 0,
      totalTimeAlive: json['totalTimeAlive'] as int? ?? 0,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      lifeStage: json['lifeStage'] != null
          ? LifeStage.values[json['lifeStage'] as int]
          : LifeStage.egg,
      variant: json['variant'] != null
          ? PetVariant.values[json['variant'] as int]
          : PetVariant.normal,
    );
  }

  /// Crea una copia del Pet con campos actualizados
  Pet copyWith({
    String? name,
    double? hunger,
    double? happiness,
    double? energy,
    double? health,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastCleaned,
    DateTime? lastRested,
    int? experience,
    int? totalTimeAlive,
    DateTime? birthDate,
    LifeStage? lifeStage,
    PetVariant? variant,
  }) {
    return Pet(
      name: name ?? this.name,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      health: health ?? this.health,
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      lastRested: lastRested ?? this.lastRested,
      experience: experience ?? this.experience,
      totalTimeAlive: totalTimeAlive ?? this.totalTimeAlive,
      birthDate: birthDate ?? this.birthDate,
      lifeStage: lifeStage ?? this.lifeStage,
      variant: variant ?? this.variant,
    );
  }
}

/// Estados de ánimo de la mascota
enum PetMood {
  happy,
  neutral,
  sad,
  hungry,
  tired,
  critical,
}
