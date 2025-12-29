/// Constantes globales para la aplicación Tamagotchi
library;

class AppConstants {
  // Límites de métricas
  static const double maxMetricValue = 100.0;
  static const double minMetricValue = 0.0;

  // Tasas de decaimiento (por segundo)
  static const double hungerDecayRate = 0.05; // hambre aumenta
  static const double happinessDecayRate = 0.03; // felicidad disminuye
  static const double energyDecayRate = 0.02; // energía disminuye

  // Efectos de acciones
  static const double feedEffect = -30.0; // reduce hambre
  static const double playHappinessEffect = 25.0; // aumenta felicidad
  static const double playEnergyEffect = -15.0; // reduce energía
  static const double cleanEffect = 20.0; // aumenta salud
  static const double restEffect = 40.0; // aumenta energía

  // Intervalos de actualización
  static const int foregroundUpdateInterval = 1; // segundos
  static const int backgroundUpdateInterval = 15; // minutos

  // Umbrales de estado
  static const double criticalThreshold = 30.0;
  static const double warningThreshold = 60.0;

  // Persistencia
  static const String petStateKey = 'pet_state';
  static const String defaultPetName = 'Mi Tamagotchi';
}
