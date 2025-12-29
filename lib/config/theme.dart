import 'package:flutter/material.dart';

/// Configuración de tema para la aplicación Tamagotchi
class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF6B4CE6);
  static const Color secondaryColor = Color(0xFFFF6B9D);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // Colores para métricas
  static const Color hungerColor = Color(0xFFFF6B6B);
  static const Color happinessColor = Color(0xFFFFD93D);
  static const Color energyColor = Color(0xFF6BCF7F);
  static const Color healthColor = Color(0xFF4ECDC4);

  // Colores para estados de ánimo
  static const Color happyColor = Color(0xFFFFD93D);
  static const Color sadColor = Color(0xFF95A5A6);
  static const Color criticalColor = Color(0xFFFF6B6B);

  /// Tema claro de la aplicación
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  /// Obtener color según el estado de ánimo
  static Color getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return happyColor;
      case 'sad':
        return sadColor;
      case 'critical':
      case 'hungry':
      case 'tired':
        return criticalColor;
      default:
        return Colors.grey;
    }
  }
}
