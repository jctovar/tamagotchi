import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_preferences.dart';
import '../models/life_stage.dart';

/// Widget para mostrar la visualización de la mascota
class PetDisplay extends StatefulWidget {
  final Pet pet;
  final PetPreferences? preferences;

  const PetDisplay({
    super.key,
    required this.pet,
    this.preferences,
  });

  @override
  State<PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<PetDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildLevelIndicator(),
            const SizedBox(height: 16),
            _buildPetAvatar(),
            const SizedBox(height: 16),
            _buildMoodIndicator(),
            const SizedBox(height: 8),
            _buildLifeStageIndicator(),
          ],
        ),
      ),
    );
  }

  /// Construye el avatar de la mascota
  Widget _buildPetAvatar() {
    final petColor = widget.preferences?.petColor ?? _getMoodColor();
    final accessory = widget.preferences?.accessoryEmoji ?? '';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: petColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: petColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _getMoodEmoji(),
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          if (accessory.isNotEmpty)
            Positioned(
              top: 0,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  accessory,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye el indicador de estado de ánimo
  Widget _buildMoodIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getMoodColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getMoodColor(),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMoodIcon(),
            color: _getMoodColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getMoodText(),
            style: TextStyle(
              color: _getMoodColor(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el emoji según el estado de ánimo y etapa de vida
  String _getMoodEmoji() {
    // Si es adulto, mostrar variante
    if (widget.pet.lifeStage == LifeStage.adult) {
      return widget.pet.variant.modifier;
    }

    // Para otras etapas, mostrar emoji de la etapa
    String baseEmoji = widget.pet.lifeStage.baseEmoji;

    // Modificar según mood solo si es crítico
    if (widget.pet.mood == PetMood.critical) {
      return '😵'; // Estado crítico siempre se muestra
    }

    return baseEmoji;
  }

  /// Obtiene el texto según el estado de ánimo
  String _getMoodText() {
    switch (widget.pet.mood) {
      case PetMood.happy:
        return 'Feliz';
      case PetMood.sad:
        return 'Triste';
      case PetMood.hungry:
        return 'Hambriento';
      case PetMood.tired:
        return 'Cansado';
      case PetMood.critical:
        return '¡Crítico!';
      default:
        return 'Normal';
    }
  }

  /// Obtiene el color según el estado de ánimo
  Color _getMoodColor() {
    switch (widget.pet.mood) {
      case PetMood.happy:
        return Colors.green;
      case PetMood.sad:
        return Colors.blue;
      case PetMood.hungry:
        return Colors.orange;
      case PetMood.tired:
        return Colors.purple;
      case PetMood.critical:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el icono según el estado de ánimo
  IconData _getMoodIcon() {
    switch (widget.pet.mood) {
      case PetMood.happy:
        return Icons.sentiment_very_satisfied;
      case PetMood.sad:
        return Icons.sentiment_dissatisfied;
      case PetMood.hungry:
        return Icons.restaurant;
      case PetMood.tired:
        return Icons.bedtime;
      case PetMood.critical:
        return Icons.warning;
      default:
        return Icons.sentiment_neutral;
    }
  }

  /// Construye el indicador de nivel y experiencia
  Widget _buildLevelIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              'Nivel ${widget.pet.level}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.pet.experience} XP',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.pet.levelProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el indicador de etapa de vida
  Widget _buildLifeStageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(widget.pet.lifeStage.colorValue).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(widget.pet.lifeStage.colorValue),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.pet.lifeStage.baseEmoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            widget.pet.lifeStage.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(widget.pet.lifeStage.colorValue),
            ),
          ),
        ],
      ),
    );
  }
}
