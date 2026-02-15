import 'package:flutter/material.dart';

class RetroColors {
  static const pink = Color(0xFFFFB5C0);
  static const green = Color(0xFF8BC34A);
  static const blue = Color(0xFF81D4FA);
  static const orange = Color(0xFFFFB74D);
  static const dark = Color(0xFF4A3728);
  static const light = Color(0xFFFFF9C4);
  static const black = Color(0xFF2C2424);
  static const red = Color(0xFFEF5350);
  static const purple = Color(0xFFBA68C8);
  static const yellow = Color(0xFFFFEE58);
}

class RetroTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'VT323',
      scaffoldBackgroundColor: RetroColors.pink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: RetroColors.pink,
        primary: RetroColors.pink,
        secondary: RetroColors.blue,
        tertiary: RetroColors.green,
        surface: RetroColors.light,
        error: RetroColors.red,
        onPrimary: RetroColors.dark,
        onSecondary: RetroColors.dark,
        onSurface: RetroColors.dark,
        onError: RetroColors.light,
      ),
      cardTheme: CardThemeData(
        color: RetroColors.light,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: RetroColors.black, width: 2),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RetroColors.green,
          foregroundColor: RetroColors.dark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: const BorderSide(color: RetroColors.black, width: 2),
          ),
          elevation: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RetroColors.pink,
        foregroundColor: RetroColors.dark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'VT323',
          fontSize: 28,
          color: RetroColors.dark,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: RetroColors.dark),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RetroColors.pink,
        selectedItemColor: RetroColors.dark,
        unselectedItemColor: RetroColors.dark.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontFamily: 'VT323', fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'VT323',
          fontSize: 16,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'VT323',
          fontSize: 36,
          color: RetroColors.dark,
        ),
        displayMedium: TextStyle(
          fontFamily: 'VT323',
          fontSize: 30,
          color: RetroColors.dark,
        ),
        displaySmall: TextStyle(
          fontFamily: 'VT323',
          fontSize: 26,
          color: RetroColors.dark,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'VT323',
          fontSize: 24,
          color: RetroColors.dark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'VT323',
          fontSize: 22,
          color: RetroColors.dark,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'VT323',
          fontSize: 20,
          color: RetroColors.dark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'VT323',
          fontSize: 22,
          color: RetroColors.dark,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: 'VT323',
          fontSize: 20,
          color: RetroColors.dark,
        ),
        titleSmall: TextStyle(
          fontFamily: 'VT323',
          fontSize: 18,
          color: RetroColors.dark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'VT323',
          fontSize: 18,
          color: RetroColors.dark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'VT323',
          fontSize: 16,
          color: RetroColors.dark,
        ),
        bodySmall: TextStyle(
          fontFamily: 'VT323',
          fontSize: 14,
          color: RetroColors.dark,
        ),
        labelLarge: TextStyle(
          fontFamily: 'VT323',
          fontSize: 16,
          color: RetroColors.dark,
        ),
        labelMedium: TextStyle(
          fontFamily: 'VT323',
          fontSize: 14,
          color: RetroColors.dark,
        ),
        labelSmall: TextStyle(
          fontFamily: 'VT323',
          fontSize: 12,
          color: RetroColors.dark,
        ),
      ),
      iconTheme: const IconThemeData(color: RetroColors.dark, size: 24),
      dividerTheme: const DividerThemeData(
        color: RetroColors.black,
        thickness: 2,
        space: 16,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: RetroColors.green,
        linearTrackColor: RetroColors.light,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RetroColors.green,
        foregroundColor: RetroColors.dark,
        elevation: 4,
      ),
    );
  }
}
