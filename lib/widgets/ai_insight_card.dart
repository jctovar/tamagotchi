import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_personality.dart';
import '../models/interaction_history.dart';
import '../services/ai_service.dart';

/// Widget que muestra información inteligente de la IA sobre la mascota
class AIInsightCard extends StatelessWidget {
  final Pet pet;
  final PetPersonality personality;
  final InteractionHistory history;
  final String petMessage;
  final AISuggestion? suggestion;

  const AIInsightCard({
    super.key,
    required this.pet,
    required this.personality,
    required this.history,
    required this.petMessage,
    this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado emocional
            _buildHeader(context),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Mensaje de la mascota
            _buildPetMessage(context),
            const SizedBox(height: 12),

            // Sugerencia de la IA
            if (suggestion != null) ...[
              _buildSuggestion(context),
              const SizedBox(height: 12),
            ],

            // Info de personalidad
            _buildPersonalityInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Emoji del estado emocional
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getEmotionColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            personality.emotionalState.emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: _getBondColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    personality.bondLevel.displayName,
                    style: TextStyle(
                      color: _getBondColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Badge de puntos de vínculo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💜', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${personality.bondPoints}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Text('💬', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              petMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestion(BuildContext context) {
    if (suggestion == null) return const SizedBox.shrink();

    Color bgColor;
    Color borderColor;

    switch (suggestion!.type) {
      case SuggestionType.urgent:
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        break;
      case SuggestionType.important:
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        break;
      case SuggestionType.tip:
        bgColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade300;
        break;
      case SuggestionType.friendly:
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Text(suggestion!.type.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion!.type.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion!.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityInfo(BuildContext context) {
    final dominantTraits = personality.dominantTraits.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalidad',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dominantTraits.map((trait) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trait.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    trait.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Barra de progreso del vínculo
        _buildBondProgress(context),
      ],
    );
  }

  Widget _buildBondProgress(BuildContext context) {
    final currentIndex = personality.bondLevel.index;
    final nextLevel = currentIndex < BondLevel.values.length - 1
        ? BondLevel.values[currentIndex + 1]
        : null;

    if (nextLevel == null) {
      // Ya es nivel máximo
      return Text(
        '✨ ¡Vínculo máximo alcanzado!',
        style: TextStyle(
          fontSize: 12,
          color: Colors.purple.shade700,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final pointsNeeded = nextLevel.requiredInteractions;
    final currentPoints = personality.bondPoints;
    final previousRequired = personality.bondLevel.requiredInteractions;
    final progress = (currentPoints - previousRequired) /
        (pointsNeeded - previousRequired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Siguiente: ${nextLevel.displayName}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '$currentPoints/$pointsNeeded',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Color _getEmotionColor() {
    switch (personality.emotionalState) {
      case EmotionalState.ecstatic:
      case EmotionalState.happy:
        return Colors.green;
      case EmotionalState.content:
        return Colors.lightGreen;
      case EmotionalState.neutral:
        return Colors.grey;
      case EmotionalState.bored:
        return Colors.amber;
      case EmotionalState.sad:
        return Colors.blue;
      case EmotionalState.lonely:
        return Colors.indigo;
      case EmotionalState.anxious:
        return Colors.red;
    }
  }

  Color _getBondColor() {
    switch (personality.bondLevel) {
      case BondLevel.stranger:
        return Colors.grey;
      case BondLevel.acquaintance:
        return Colors.blue;
      case BondLevel.friend:
        return Colors.green;
      case BondLevel.bestFriend:
        return Colors.purple;
      case BondLevel.soulmate:
        return Colors.pink;
    }
  }
}

/// Widget compacto para mostrar solo el estado emocional y mensaje
class AICompactInsight extends StatelessWidget {
  final Pet pet;
  final PetPersonality personality;
  final String petMessage;

  const AICompactInsight({
    super.key,
    required this.pet,
    required this.personality,
    required this.petMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            personality.emotionalState.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              petMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
