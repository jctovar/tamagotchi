/// Modelo para manejar etapas de vida y evolución de la mascota
library;

/// Etapa de vida de la mascota
enum LifeStage {
  egg,      // Huevo (0-5 min)
  baby,     // Bebé (5-30 min)
  child,    // Niño (30 min - 2 horas)
  teen,     // Adolescente (2-6 horas)
  adult,    // Adulto (6+ horas)
}

/// Extensión para obtener propiedades de cada etapa
extension LifeStageExtension on LifeStage {
  /// Nombre en español de la etapa
  String get displayName {
    switch (this) {
      case LifeStage.egg:
        return 'Huevo';
      case LifeStage.baby:
        return 'Bebé';
      case LifeStage.child:
        return 'Niño';
      case LifeStage.teen:
        return 'Adolescente';
      case LifeStage.adult:
        return 'Adulto';
    }
  }

  /// Emoji base de la etapa
  String get baseEmoji {
    switch (this) {
      case LifeStage.egg:
        return '🥚';
      case LifeStage.baby:
        return '🐣';
      case LifeStage.child:
        return '🐥';
      case LifeStage.teen:
        return '🐤';
      case LifeStage.adult:
        return '🐦';
    }
  }

  /// Tiempo mínimo en segundos para esta etapa
  int get minTimeSeconds {
    switch (this) {
      case LifeStage.egg:
        return 0;
      case LifeStage.baby:
        return 300; // 5 minutos
      case LifeStage.child:
        return 1800; // 30 minutos
      case LifeStage.teen:
        return 7200; // 2 horas
      case LifeStage.adult:
        return 21600; // 6 horas
    }
  }

  /// Experiencia necesaria para alcanzar esta etapa
  int get requiredExperience {
    switch (this) {
      case LifeStage.egg:
        return 0;
      case LifeStage.baby:
        return 100;
      case LifeStage.child:
        return 500;
      case LifeStage.teen:
        return 1500;
      case LifeStage.adult:
        return 3000;
    }
  }

  /// Siguiente etapa
  LifeStage? get nextStage {
    switch (this) {
      case LifeStage.egg:
        return LifeStage.baby;
      case LifeStage.baby:
        return LifeStage.child;
      case LifeStage.child:
        return LifeStage.teen;
      case LifeStage.teen:
        return LifeStage.adult;
      case LifeStage.adult:
        return null; // Ya es adulto
    }
  }

  /// Color asociado a la etapa
  int get colorValue {
    switch (this) {
      case LifeStage.egg:
        return 0xFFE0E0E0; // Gris claro
      case LifeStage.baby:
        return 0xFFFFE0B2; // Naranja pastel
      case LifeStage.child:
        return 0xFFFFF9C4; // Amarillo pastel
      case LifeStage.teen:
        return 0xFFB3E5FC; // Azul pastel
      case LifeStage.adult:
        return 0xFFC5E1A5; // Verde pastel
    }
  }
}

/// Variante de la mascota según calidad de cuidado
enum PetVariant {
  neglected,  // Descuidado (mal cuidado)
  normal,     // Normal (cuidado promedio)
  excellent,  // Excelente (muy buen cuidado)
}

extension PetVariantExtension on PetVariant {
  String get displayName {
    switch (this) {
      case PetVariant.neglected:
        return 'Descuidado';
      case PetVariant.normal:
        return 'Normal';
      case PetVariant.excellent:
        return 'Excelente';
    }
  }

  /// Emoji modificador según variante (para adultos)
  String get modifier {
    switch (this) {
      case PetVariant.neglected:
        return '💀'; // Mal cuidado
      case PetVariant.normal:
        return '🐦'; // Normal
      case PetVariant.excellent:
        return '🦅'; // Excelente cuidado
    }
  }
}

/// Utilidades para calcular evolución
class EvolutionUtils {
  /// Calcula la etapa de vida basada en tiempo y experiencia
  static LifeStage calculateLifeStage({
    required int totalTimeAlive,
    required int experience,
  }) {
    // Priorizar experiencia sobre tiempo
    if (experience >= LifeStage.adult.requiredExperience) {
      return LifeStage.adult;
    } else if (experience >= LifeStage.teen.requiredExperience) {
      return LifeStage.teen;
    } else if (experience >= LifeStage.child.requiredExperience) {
      return LifeStage.child;
    } else if (experience >= LifeStage.baby.requiredExperience) {
      return LifeStage.baby;
    }

    // Si no hay suficiente experiencia, usar tiempo
    if (totalTimeAlive >= LifeStage.adult.minTimeSeconds) {
      return LifeStage.adult;
    } else if (totalTimeAlive >= LifeStage.teen.minTimeSeconds) {
      return LifeStage.teen;
    } else if (totalTimeAlive >= LifeStage.child.minTimeSeconds) {
      return LifeStage.child;
    } else if (totalTimeAlive >= LifeStage.baby.minTimeSeconds) {
      return LifeStage.baby;
    }

    return LifeStage.egg;
  }

  /// Calcula variante basada en promedio de métricas
  static PetVariant calculateVariant({
    required double avgHealth,
    required double avgHappiness,
    required double avgEnergy,
  }) {
    final avgScore = (avgHealth + avgHappiness + avgEnergy) / 3;

    if (avgScore >= 70) {
      return PetVariant.excellent;
    } else if (avgScore >= 40) {
      return PetVariant.normal;
    } else {
      return PetVariant.neglected;
    }
  }

  /// Calcula experiencia ganada por acción
  static int getExperienceForAction(String action) {
    switch (action) {
      case 'feed':
        return 10;
      case 'play':
        return 15;
      case 'clean':
        return 10;
      case 'rest':
        return 5;
      default:
        return 0;
    }
  }

  /// Calcula nivel basado en experiencia
  static int calculateLevel(int experience) {
    // Nivel = sqrt(experiencia / 100)
    return (experience / 100).floor() + 1;
  }

  /// Experiencia necesaria para siguiente nivel
  static int experienceForNextLevel(int currentLevel) {
    return currentLevel * currentLevel * 100;
  }

  /// Progreso hacia siguiente nivel (0-1)
  static double levelProgress(int experience, int currentLevel) {
    final currentLevelXp = (currentLevel - 1) * (currentLevel - 1) * 100;
    final nextLevelXp = experienceForNextLevel(currentLevel);
    final xpInLevel = experience - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;

    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }
}
