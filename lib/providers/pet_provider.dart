import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_preferences.dart';
import '../services/storage_service.dart';
import '../services/preferences_service.dart';
import '../utils/logger.dart';

/// Provider para gestionar el estado global de la mascota
///
/// Maneja la sincronización del estado del Pet entre todas las pantallas
/// y asegura que los cambios se persistan y se reflejen en tiempo real.
class PetProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  Pet? _pet;
  PetPreferences _preferences = const PetPreferences();
  bool _isLoading = true;

  /// Mascota actual (puede ser null si aún no se ha cargado)
  Pet? get pet => _pet;

  /// Preferencias de personalización
  PetPreferences get preferences => _preferences;

  /// Indica si está cargando
  bool get isLoading => _isLoading;

  /// Carga el estado inicial de la mascota
  Future<void> loadPet() async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _storageService.loadPetState(),
        PreferencesService.loadPreferences(),
      ]);

      final savedPet = results[0] as Pet?;
      final preferences = results[1] as PetPreferences;

      if (savedPet != null) {
        _pet = _storageService.updatePetMetrics(savedPet);
        appLogger.d('Pet cargado: ${_pet!.name}');
      } else {
        _pet = Pet(name: 'Mi Tamagotchi');
        await _storageService.saveState(_pet!);
        appLogger.i('Pet nuevo creado: ${_pet!.name}');
      }

      _preferences = preferences;
    } catch (e, stackTrace) {
      appLogger.e('Error cargando pet', error: e, stackTrace: stackTrace);
      _pet = Pet(name: 'Mi Tamagotchi');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el estado completo de la mascota
  Future<void> updatePet(Pet pet, {bool notify = true}) async {
    _pet = pet;
    await _storageService.saveState(pet);

    if (notify) {
      notifyListeners();
    }
  }

  /// Actualiza solo el nombre de la mascota
  Future<void> updatePetName(String name) async {
    if (_pet == null || name.isEmpty || name == _pet!.name) return;

    appLogger.d('Actualizando nombre: ${_pet!.name} -> $name');

    final updatedPet = _pet!.copyWith(name: name);
    await updatePet(updatedPet);
  }

  /// Actualiza las preferencias de personalización
  Future<void> updatePreferences(PetPreferences preferences) async {
    _preferences = preferences;
    notifyListeners();
  }

  /// Actualiza el color de la mascota
  Future<void> updatePetColor(int colorValue) async {
    await PreferencesService.updatePetColor(colorValue);
    _preferences = _preferences.copyWith(petColor: Color(colorValue));
    notifyListeners();
  }

  /// Actualiza el accesorio de la mascota
  Future<void> updateAccessory(String accessory) async {
    await PreferencesService.updateAccessory(accessory);
    _preferences = _preferences.copyWith(accessory: accessory);
    notifyListeners();
  }

  /// Reinicia todo el estado (para reset de Tamagotchi)
  Future<void> reset() async {
    await _storageService.clearAllData();
    await PreferencesService.clearPreferences();

    _pet = Pet(name: 'Mi Tamagotchi');
    _preferences = const PetPreferences();

    await _storageService.saveState(_pet!);

    notifyListeners();
  }
}
