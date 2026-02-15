import 'package:flutter/material.dart';
import '../../config/retro_theme.dart';

class RetroProgressBar extends StatelessWidget {
  final int value;
  final int max;
  final Color color;
  final double height;

  const RetroProgressBar({
    super.key,
    required this.value,
    this.max = 10,
    required this.color,
    this.height = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0, max);
    final percentage = (clampedValue / max * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(max, (index) {
            final isActive = index < clampedValue;
            return Container(
              width: 18,
              height: height,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey[300],
                border: Border.all(color: RetroColors.black, width: 1.5),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 14,
            color: RetroColors.dark,
          ),
        ),
      ],
    );
  }
}

class RetroMetricBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const RetroMetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 100.0).toInt();
    final blocks = (clampedValue / 10).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 16,
                  color: RetroColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(10, (index) {
              final isActive = index < blocks;
              return Container(
                width: 20,
                height: 10,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey[300],
                  border: Border.all(color: RetroColors.black, width: 1.5),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            '$clampedValue%',
            style: TextStyle(
              fontFamily: 'VT323',
              fontSize: 14,
              color: _getValueColor(clampedValue),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(int value) {
    if (value < 30) return RetroColors.red;
    if (value < 60) return RetroColors.orange;
    return RetroColors.green;
  }
}
