/// Modelo para las preferencias de personalización del Tamagotchi
library;

import 'package:flutter/material.dart';

class PetPreferences {
  final Color petColor;
  final String accessory;
  final bool soundEnabled;
  final bool notificationsEnabled;

  const PetPreferences({
    this.petColor = Colors.purple,
    this.accessory = 'none',
    this.soundEnabled = true,
    this.notificationsEnabled = true,
  });

  /// Crea una copia con valores modificados
  PetPreferences copyWith({
    Color? petColor,
    String? accessory,
    bool? soundEnabled,
    bool? notificationsEnabled,
  }) {
    return PetPreferences(
      petColor: petColor ?? this.petColor,
      accessory: accessory ?? this.accessory,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'petColorValue': petColor.toARGB32(),
      'accessory': accessory,
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  /// Crea desde JSON
  factory PetPreferences.fromJson(Map<String, dynamic> json) {
    return PetPreferences(
      petColor: Color(json['petColorValue'] as int? ?? Colors.purple.toARGB32()),
      accessory: json['accessory'] as String? ?? 'none',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  /// Colores predefinidos disponibles
  static const List<Color> availableColors = [
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.amber,
  ];

  /// Accesorios disponibles
  static const List<String> availableAccessories = [
    'none',
    'bow',
    'hat',
    'glasses',
    'scarf',
  ];

  /// Obtiene el emoji del accesorio
  String get accessoryEmoji {
    switch (accessory) {
      case 'bow':
        return '🎀';
      case 'hat':
        return '🎩';
      case 'glasses':
        return '🕶️';
      case 'scarf':
        return '🧣';
      default:
        return '';
    }
  }

  /// Obtiene el nombre del accesorio
  String get accessoryName {
    switch (accessory) {
      case 'bow':
        return 'Moño';
      case 'hat':
        return 'Sombrero';
      case 'glasses':
        return 'Lentes';
      case 'scarf':
        return 'Bufanda';
      default:
        return 'Ninguno';
    }
  }
}
