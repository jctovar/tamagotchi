import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../models/pet_preferences.dart';
import '../../models/life_stage.dart';
import '../pet_name_display.dart';
import '../../config/retro_theme.dart';

class RetroPetDisplay extends StatefulWidget {
  final Pet pet;
  final PetPreferences? preferences;

  const RetroPetDisplay({super.key, required this.pet, this.preferences});

  @override
  State<RetroPetDisplay> createState() => _RetroPetDisplayState();
}

class _RetroPetDisplayState extends State<RetroPetDisplay> {
  int _frame = 0;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => setState(() => _frame = (_frame + 1) % 3),
    );
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  String _getEmojiForCurrentState() {
    if (widget.pet.mood == PetMood.critical) {
      return '😵';
    }

    if (widget.pet.lifeStage == LifeStage.adult) {
      return widget.pet.variant.modifier;
    }

    return widget.pet.lifeStage.baseEmoji;
  }

  Color _getMoodColor() {
    switch (widget.pet.mood) {
      case PetMood.happy:
        return RetroColors.green;
      case PetMood.sad:
        return RetroColors.blue;
      case PetMood.hungry:
        return RetroColors.orange;
      case PetMood.tired:
        return RetroColors.purple;
      case PetMood.critical:
        return RetroColors.red;
      default:
        return Colors.grey;
    }
  }

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
        return 'Critico!';
      default:
        return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final petColor = widget.preferences?.petColor ?? _getMoodColor();
    final accessory = widget.preferences?.accessoryEmoji ?? '';

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetNameDisplay(
              editable: true,
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'VT323',
                color: RetroColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            _buildLevelIndicator(),
            const SizedBox(height: 16),
            _buildPetAvatar(petColor, accessory),
            const SizedBox(height: 16),
            _buildMoodIndicator(),
            const SizedBox(height: 8),
            _buildLifeStageIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, size: 18, color: RetroColors.yellow),
            const SizedBox(width: 4),
            Text(
              'Nivel ${widget.pet.level}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'VT323',
                color: RetroColors.dark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.pet.experience} XP',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'VT323',
                color: RetroColors.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 200,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(color: RetroColors.black, width: 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widget.pet.levelProgress,
            child: Container(
              decoration: BoxDecoration(
                color: RetroColors.yellow,
                border: Border(
                  right: BorderSide(color: RetroColors.black, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetAvatar(Color petColor, String accessory) {
    final isCritical = widget.pet.mood == PetMood.critical;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: petColor.withValues(alpha: 0.2),
            border: Border.all(color: petColor, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: Text(
                _getEmojiForCurrentState(),
                key: ValueKey(_frame),
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
        ),
        if (isCritical)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: RetroColors.red,
                border: Border.all(color: RetroColors.black, width: 2),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  fontSize: 20,
                  color: RetroColors.light,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (accessory.isNotEmpty)
          Positioned(
            top: 0,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: RetroColors.light,
                border: Border.all(color: RetroColors.black, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(accessory, style: const TextStyle(fontSize: 28)),
            ),
          ),
      ],
    );
  }

  Widget _buildMoodIndicator() {
    final moodColor = _getMoodColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.2),
        border: Border.all(color: moodColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getMoodIcon(), color: moodColor, size: 20),
          const SizedBox(width: 8),
          Text(
            _getMoodText(),
            style: TextStyle(
              color: moodColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'VT323',
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildLifeStageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(widget.pet.lifeStage.colorValue).withValues(alpha: 0.2),
        border: Border.all(
          color: Color(widget.pet.lifeStage.colorValue),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.pet.lifeStage.baseEmoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            widget.pet.lifeStage.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(widget.pet.lifeStage.colorValue),
              fontFamily: 'VT323',
            ),
          ),
        ],
      ),
    );
  }
}
