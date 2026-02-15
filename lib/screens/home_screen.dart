import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../models/pet_preferences.dart';
import '../models/life_stage.dart';
import '../models/interaction_history.dart';
import '../widgets/pet_display.dart';
import '../widgets/metric_bar.dart';
import '../widgets/animated_action_button.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/coins_display.dart';
import '../config/theme.dart';
import '../services/feedback_service.dart';
import '../services/ai_service.dart';
import '../providers/pet_state_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/ai_state_provider.dart';
import '../providers/metrics_update_provider.dart';
import 'games/minigames_menu_screen.dart';

/// Pantalla principal de la aplicación (Refactorizada con Riverpod)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();

    // Inicializar providers de timer y lifecycle
    Future.microtask(() {
      // Inicializar el timer de actualización automática
      ref.read(metricsUpdateProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petStateProvider);
    final prefsAsync = ref.watch(preferencesStateProvider);

    // Escuchar evolución para mostrar diálogo
    ref.listen(showEvolutionDialogProvider, (previous, next) {
      if (next && petAsync.value != null) {
        _showEvolutionDialog(petAsync.value!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamagotchi'),
        actions: petAsync.maybeWhen(
          data: (pet) => [CoinsDisplay(coins: pet.coins)],
          orElse: () => [],
        ),
      ),
      body: petAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(petStateProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (pet) => prefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (prefs) => _buildContent(pet, prefs),
        ),
      ),
    );
  }

  Widget _buildContent(Pet pet, PetPreferences prefs) {
    final isCritical = ref.watch(petIsCriticalProvider);

    // Obtener mensaje y sugerencia de IA
    final petMessage = ref.watch(petMessageProvider);
    final suggestion = ref.watch(petSuggestionProvider);

    // Obtener personality e history para AIInsightCard
    final personalityAsync = ref.watch(personalityStateProvider);
    final historyAsync = ref.watch(interactionHistoryStateProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Visualización de la mascota
            PetDisplay(pet: pet, preferences: prefs),
            const SizedBox(height: 16),

            // Card de IA
            if (personalityAsync.value != null && historyAsync.value != null)
              AIInsightCard(
                pet: pet,
                personality: personalityAsync.value!,
                history: historyAsync.value!,
                petMessage: petMessage,
                suggestion: suggestion,
              ),
            const SizedBox(height: 16),

            // Alerta de estado crítico
            if (isCritical) _buildCriticalAlert(pet),
            if (isCritical) const SizedBox(height: 16),

            // Métricas
            _buildMetricsSection(),
            const SizedBox(height: 24),

            // Botones de acción
            _buildActionButtons(),
            const SizedBox(height: 16),

            // Botón de mini-juegos
            _buildMiniGamesButton(),
          ],
        ),
      ),
    );
  }

  /// Construye la alerta de estado crítico
  Widget _buildCriticalAlert(Pet pet) {
    String message = '¡Tu mascota necesita atención urgente!';

    if (pet.health < 30) {
      message = '⚠️ ¡Salud crítica! Tu mascota está muy enferma.';
    } else if (pet.hunger > 80) {
      message = '⚠️ ¡Hambre extrema! Alimenta a tu mascota ahora.';
    } else if (pet.energy < 20) {
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

  /// Construye la sección de métricas usando providers derivados
  Widget _buildMetricsSection() {
    // Usar providers granulares para rebuilds optimizados
    final hunger = ref.watch(petHungerProvider);
    final happiness = ref.watch(petHappinessProvider);
    final energy = ref.watch(petEnergyProvider);
    final health = ref.watch(petHealthProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            MetricBar(
              label: 'Hambre',
              value: hunger,
              color: AppTheme.hungerColor,
              icon: Icons.restaurant,
            ),
            MetricBar(
              label: 'Felicidad',
              value: happiness,
              color: AppTheme.happinessColor,
              icon: Icons.sentiment_satisfied,
            ),
            MetricBar(
              label: 'Energía',
              value: energy,
              color: AppTheme.energyColor,
              icon: Icons.battery_charging_full,
            ),
            MetricBar(
              label: 'Salud',
              value: health,
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

  /// Construye el botón de mini-juegos
  Widget _buildMiniGamesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _navigateToMiniGames,
        icon: const Text('🎮', style: TextStyle(fontSize: 24)),
        label: const Text(
          'Mini-Juegos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple[400],
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ACCIONES - Delegadas al PetStateProvider
  // ============================================================================

  /// Acción: Alimentar a la mascota
  void _feedPet() async {
    await ref.read(petStateProvider.notifier).feed();

    // Mostrar respuesta inteligente de IA
    final pet = ref.read(petStateProvider).value;
    final personality = ref.read(personalityStateProvider).value;

    if (pet != null && personality != null) {
      final response = _aiService.generateActionResponse(
        action: InteractionType.feed,
        pet: pet,
        personality: personality,
      );
      _showActionFeedback(response);
    }
  }

  /// Acción: Jugar con la mascota
  void _playWithPet() async {
    await ref.read(petStateProvider.notifier).play();

    final pet = ref.read(petStateProvider).value;
    final personality = ref.read(personalityStateProvider).value;

    if (pet != null && personality != null) {
      final response = _aiService.generateActionResponse(
        action: InteractionType.play,
        pet: pet,
        personality: personality,
      );
      _showActionFeedback(response);
    }
  }

  /// Acción: Limpiar a la mascota
  void _cleanPet() async {
    await ref.read(petStateProvider.notifier).clean();

    final pet = ref.read(petStateProvider).value;
    final personality = ref.read(personalityStateProvider).value;

    if (pet != null && personality != null) {
      final response = _aiService.generateActionResponse(
        action: InteractionType.clean,
        pet: pet,
        personality: personality,
      );
      _showActionFeedback(response);
    }
  }

  /// Acción: Descansar
  void _restPet() async {
    await ref.read(petStateProvider.notifier).rest();

    final pet = ref.read(petStateProvider).value;
    final personality = ref.read(personalityStateProvider).value;

    if (pet != null && personality != null) {
      final response = _aiService.generateActionResponse(
        action: InteractionType.rest,
        pet: pet,
        personality: personality,
      );
      _showActionFeedback(response);
    }
  }

  /// Navega a la pantalla de mini-juegos
  void _navigateToMiniGames() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MiniGamesMenuScreen()),
    );
  }

  /// Muestra el diálogo de evolución
  void _showEvolutionDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
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
              '¡${pet.name} ha evolucionado!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(pet.lifeStage.baseEmoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 8),
            Text(
              'Ahora es un ${pet.lifeStage.displayName}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(pet.lifeStage.colorValue),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              ref.read(showEvolutionDialogProvider.notifier).hide();
              Navigator.pop(context);
            },
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  /// Muestra un mensaje de feedback
  void _showActionFeedback(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
