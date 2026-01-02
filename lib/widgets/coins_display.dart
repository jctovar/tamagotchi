import 'package:flutter/material.dart';

/// Widget que muestra la cantidad de monedas del usuario
///
/// Muestra un badge dorado con el emoji de moneda y la cantidad actual.
/// Diseñado para usarse en el AppBar.
class CoinsDisplay extends StatelessWidget {
  /// Cantidad de monedas a mostrar
  final int coins;

  const CoinsDisplay({
    super.key,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade700, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🪙',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Text(
                coins.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
