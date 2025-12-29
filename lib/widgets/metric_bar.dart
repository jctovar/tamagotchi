import 'package:flutter/material.dart';

/// Widget para mostrar una barra de progreso de métrica
class MetricBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Asegurar que el valor esté entre 0 y 100
    final clampedValue = value.clamp(0.0, 100.0);

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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${clampedValue.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getValueColor(clampedValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clampedValue / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(clampedValue, color),
              ),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color del texto según el valor
  Color _getValueColor(double value) {
    if (value < 30) return Colors.red;
    if (value < 60) return Colors.orange;
    return Colors.green;
  }

  /// Obtiene el color de la barra según el valor
  Color _getProgressColor(double value, Color baseColor) {
    if (value < 30) {
      return Colors.red;
    } else if (value < 60) {
      return Colors.orange;
    }
    return baseColor;
  }
}
