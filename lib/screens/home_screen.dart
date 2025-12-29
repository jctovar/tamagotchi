import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_preferences.dart';
import '../models/life_stage.dart';
import '../widgets/pet_display.dart';
import '../widgets/metric_bar.dart';
import '../widgets/animated_action_button.dart';
import '../config/theme.dart';
import '../services/storage_service.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
import '../services/feedback_service.dart';
import '../utils/constants.dart';

/// Pantalla principal de la aplicación
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Pet _pet;
  PetPreferences _preferences = const PetPreferences();
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  Timer? _updateTimer;
  DateTime? _lastUpdate;
  bool _wasCritical = false; // Para evitar notificaciones repetidas

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPetState();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      debugPrint('⏸️ App pausada - guardando estado');
      _saveState();
      _updateTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('▶️ App resumida - reiniciando timer');
      _startUpdateTimer();
    }
  }

  /// Carga el estado de la mascota del almacenamiento
  Future<void> _loadPetState() async {
    debugPrint('🔄 Cargando estado de la mascota...');

    // Cargar preferencias y estado en paralelo
    final results = await Future.wait([
      _storageService.loadPetState(),
      PreferencesService.loadPreferences(),
    ]);

    final savedPet = results[0] as Pet?;
    final preferences = results[1] as PetPreferences;

    if (savedPet != null) {
      debugPrint('📊 Estado anterior - Hambre: ${savedPet.hunger}, Felicidad: ${savedPet.happiness}');
      // Actualizar métricas basado en tiempo transcurrido
      _pet = _storageService.updatePetMetrics(savedPet);
      debugPrint('📊 Estado actualizado - Hambre: ${_pet.hunger}, Felicidad: ${_pet.happiness}');
    } else {
      // Crear una mascota nueva
      debugPrint('🆕 Creando mascota nueva');
      _pet = Pet(name: 'Mi Tamagotchi');
    }

    _lastUpdate = DateTime.now();

    setState(() {
      _preferences = preferences;
      _isLoading = false;
    });

    // Guardar el estado actualizado
    await _storageService.saveState(_pet);

    // Iniciar el timer de actualización
    _startUpdateTimer();
  }

  /// Inicia el timer de actualización periódica
  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _lastUpdate = DateTime.now();

    _updateTimer = Timer.periodic(
      Duration(seconds: AppConstants.foregroundUpdateInterval),
      (timer) => _updateMetrics(),
    );
    debugPrint('⏱️ Timer iniciado - actualizando cada ${AppConstants.foregroundUpdateInterval}s');
  }

  /// Actualiza las métricas de la mascota
  void _updateMetrics() {
    if (_lastUpdate == null) return;

    final now = DateTime.now();
    final secondsElapsed = now.difference(_lastUpdate!).inSeconds;

    if (secondsElapsed < 1) return; // Evitar actualizaciones muy frecuentes

    setState(() {
      // Calcular nuevos valores
      double newHunger = _pet.hunger + (secondsElapsed * AppConstants.hungerDecayRate);
      double newHappiness = _pet.happiness - (secondsElapsed * AppConstants.happinessDecayRate);
      double newEnergy = _pet.energy - (secondsElapsed * AppConstants.energyDecayRate);
      double newHealth = _pet.health;

      // Reducir salud si las métricas están críticas
      if (newHunger > 80) {
        newHealth -= (secondsElapsed * 0.01);
      }
      if (newHappiness < 20) {
        newHealth -= (secondsElapsed * 0.01);
      }
      if (newEnergy < 20) {
        newHealth -= (secondsElapsed * 0.01);
      }

      // Aplicar límites
      newHunger = newHunger.clamp(0, 100);
      newHappiness = newHappiness.clamp(0, 100);
      newEnergy = newEnergy.clamp(0, 100);
      newHealth = newHealth.clamp(0, 100);

      _pet = _pet.copyWith(
        hunger: newHunger,
        happiness: newHappiness,
        energy: newEnergy,
        health: newHealth,
      );

      // Actualizar tiempo vivo y etapa de vida
      final oldStage = _pet.lifeStage;
      _pet = _pet.updateLifeStage();
      _pet = _pet.updateVariant();

      _lastUpdate = now;

      // Verificar evolución
      if (_pet.lifeStage != oldStage) {
        _checkEvolution(oldStage);
      }
    });

    // Detectar cambio a estado crítico y mostrar notificación
    if (_pet.isCritical && !_wasCritical) {
      _wasCritical = true;
      NotificationService.showCriticalNotification(_pet);
    } else if (!_pet.isCritical) {
      _wasCritical = false;
    }

    // Guardar estado periódicamente (cada 10 segundos)
    if (now.second % 10 == 0) {
      _saveState();
    }
  }

  /// Guarda el estado actual
  Future<void> _saveState() async {
    await _storageService.saveState(_pet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamagotchi'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Visualización de la mascota
                    PetDisplay(pet: _pet, preferences: _preferences),
                    const SizedBox(height: 16),

                    // Alerta de estado crítico
                    if (_pet.isCritical) _buildCriticalAlert(),
                    if (_pet.isCritical) const SizedBox(height: 16),

                    // Métricas
                    _buildMetricsSection(),
                    const SizedBox(height: 24),

                    // Botones de acción
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  /// Construye la alerta de estado crítico
  Widget _buildCriticalAlert() {
    String message = '¡Tu mascota necesita atención urgente!';

    if (_pet.health < 30) {
      message = '⚠️ ¡Salud crítica! Tu mascota está muy enferma.';
    } else if (_pet.hunger > 80) {
      message = '⚠️ ¡Hambre extrema! Alimenta a tu mascota ahora.';
    } else if (_pet.energy < 20) {
      message = '⚠️ ¡Sin energía! Tu mascota necesita descansar.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de métricas
  Widget _buildMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            MetricBar(
              label: 'Hambre',
              value: _pet.hunger,
              color: AppTheme.hungerColor,
              icon: Icons.restaurant,
            ),
            MetricBar(
              label: 'Felicidad',
              value: _pet.happiness,
              color: AppTheme.happinessColor,
              icon: Icons.sentiment_satisfied,
            ),
            MetricBar(
              label: 'Energía',
              value: _pet.energy,
              color: AppTheme.energyColor,
              icon: Icons.battery_charging_full,
            ),
            MetricBar(
              label: 'Salud',
              value: _pet.health,
              color: AppTheme.healthColor,
              icon: Icons.favorite,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedActionButton(
                label: 'Alimentar',
                icon: Icons.restaurant,
                color: AppTheme.hungerColor,
                onPressed: _feedPet,
                feedbackType: FeedbackType.feed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedActionButton(
                label: 'Jugar',
                icon: Icons.sports_esports,
                color: AppTheme.happinessColor,
                onPressed: _playWithPet,
                feedbackType: FeedbackType.play,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedActionButton(
                label: 'Limpiar',
                icon: Icons.cleaning_services,
                color: AppTheme.healthColor,
                onPressed: _cleanPet,
                feedbackType: FeedbackType.clean,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedActionButton(
                label: 'Descansar',
                icon: Icons.bedtime,
                color: AppTheme.energyColor,
                onPressed: _restPet,
                feedbackType: FeedbackType.rest,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Acción: Alimentar a la mascota
  void _feedPet() {
    final oldStage = _pet.lifeStage;
    setState(() {
      _pet = _pet.copyWith(
        hunger: (_pet.hunger - 30).clamp(0, 100),
        lastFed: DateTime.now(),
      );
      _pet = _pet.gainExperience('feed');
      _pet = _pet.updateLifeStage();
      _pet = _pet.updateVariant();
    });
    _saveState(); // Guardar estado
    _checkEvolution(oldStage);
    _showActionFeedback('¡Ñam ñam! 🍔 (+10 XP)');
  }

  /// Acción: Jugar con la mascota
  void _playWithPet() {
    final oldStage = _pet.lifeStage;
    setState(() {
      _pet = _pet.copyWith(
        happiness: (_pet.happiness + 25).clamp(0, 100),
        energy: (_pet.energy - 15).clamp(0, 100),
        lastPlayed: DateTime.now(),
      );
      _pet = _pet.gainExperience('play');
      _pet = _pet.updateLifeStage();
      _pet = _pet.updateVariant();
    });
    _saveState(); // Guardar estado
    _checkEvolution(oldStage);
    _showActionFeedback('¡Qué divertido! 🎮 (+15 XP)');
  }

  /// Acción: Limpiar a la mascota
  void _cleanPet() {
    final oldStage = _pet.lifeStage;
    setState(() {
      _pet = _pet.copyWith(
        health: (_pet.health + 20).clamp(0, 100),
        lastCleaned: DateTime.now(),
      );
      _pet = _pet.gainExperience('clean');
      _pet = _pet.updateLifeStage();
      _pet = _pet.updateVariant();
    });
    _saveState(); // Guardar estado
    _checkEvolution(oldStage);
    _showActionFeedback('¡Qué limpio! 🧼 (+10 XP)');
  }

  /// Acción: Descansar
  void _restPet() {
    final oldStage = _pet.lifeStage;
    setState(() {
      _pet = _pet.copyWith(
        energy: (_pet.energy + 40).clamp(0, 100),
        lastRested: DateTime.now(),
      );
      _pet = _pet.gainExperience('rest');
      _pet = _pet.updateLifeStage();
      _pet = _pet.updateVariant();
    });
    _saveState(); // Guardar estado
    _checkEvolution(oldStage);
    _showActionFeedback('¡Zzz... 😴 (+5 XP)');
  }

  /// Verifica si hubo evolución y muestra celebración
  void _checkEvolution(LifeStage oldStage) {
    if (_pet.lifeStage != oldStage) {
      _showEvolutionCelebration();
    }
  }

  /// Muestra celebración de evolución
  void _showEvolutionCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 32)),
            SizedBox(width: 8),
            Text('¡Evolución!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡${_pet.name} ha evolucionado!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              _pet.lifeStage.baseEmoji,
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 8),
            Text(
              'Ahora es un ${_pet.lifeStage.displayName}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(_pet.lifeStage.colorValue),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de feedback
  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
