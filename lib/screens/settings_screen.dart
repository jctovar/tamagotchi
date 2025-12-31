import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_preferences.dart';
import '../services/storage_service.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';
import '../services/ml_data_export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PetPreferences _preferences = const PetPreferences();
  Pet? _pet;
  bool _isLoading = true;
  bool _isExporting = false;
  final _storageService = StorageService();
  final _mlExportService = MLDataExportService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await PreferencesService.loadPreferences();
    final pet = await _storageService.loadPetState();

    setState(() {
      _preferences = preferences;
      _pet = pet;
      _isLoading = false;
    });
  }

  Future<void> _showRenameDialog() async {
    if (_pet == null) return;

    final controller = TextEditingController(text: _pet!.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renombrar Mascota'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre',
              hintText: 'Ingresa un nombre',
            ),
            maxLength: 20,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && result != _pet!.name) {
      final oldName = _pet!.name;
      final updatedPet = _pet!.copyWith(name: result);
      await _storageService.saveState(updatedPet);
      setState(() {
        _pet = updatedPet;
      });

      // Registrar evento en Analytics
      await AnalyticsService.logPetRenamed(
        oldName: oldName,
        newName: result,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nombre cambiado a "$result"')),
        );
      }
    }
  }

  Future<void> _updatePetColor(Color color) async {
    await PreferencesService.updatePetColor(color.toARGB32());
    setState(() {
      _preferences = _preferences.copyWith(petColor: color);
    });

    // Registrar evento en Analytics
    await AnalyticsService.logPetColorChanged(
      newColor: color.toString(),
      coinsSpent: 0, // El cambio de color es gratuito
    );
  }

  Future<void> _updateAccessory(String accessory) async {
    final oldAccessory = _preferences.accessory;
    await PreferencesService.updateAccessory(accessory);
    setState(() {
      _preferences = _preferences.copyWith(accessory: accessory);
    });

    // Registrar evento en Analytics
    await AnalyticsService.logAccessoryChanged(
      oldAccessory: oldAccessory.isEmpty ? null : oldAccessory,
      newAccessory: accessory.isEmpty ? null : accessory,
    );
  }

  Future<void> _updateSoundEnabled(bool enabled) async {
    await PreferencesService.updateSoundEnabled(enabled);
    setState(() {
      _preferences = _preferences.copyWith(soundEnabled: enabled);
    });
  }

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    await PreferencesService.updateNotificationsEnabled(enabled);
    setState(() {
      _preferences = _preferences.copyWith(notificationsEnabled: enabled);
    });
  }

  Future<void> _exportMLData() async {
    if (_pet == null || _isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final history = await _storageService.loadInteractionHistory();
      final personality = await _storageService.loadPetPersonality();

      final result = await _mlExportService.exportTrainingData(
        pet: _pet!,
        personality: personality,
        history: history,
      );

      if (!mounted) return;

      if (result.success && result.filePath != null) {
        await _mlExportService.shareExportedData(result.filePath!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exportados ${result.recordCount} registros'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al exportar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _generateSyntheticData() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final result = await _mlExportService.generateSyntheticData(
        recordCount: 500,
      );

      if (!mounted) return;

      if (result.success && result.filePath != null) {
        await _mlExportService.shareExportedData(result.filePath!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generados ${result.recordCount} registros sintéticos'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al generar datos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Sección: Personalización
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Personalización',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Renombrar mascota
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Nombre de la mascota'),
            subtitle: Text(_pet?.name ?? 'Mi Tamagotchi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showRenameDialog,
          ),

          const Divider(),

          // Color de la mascota
          ListTile(
            leading: Icon(Icons.palette, color: _preferences.petColor),
            title: const Text('Color de la mascota'),
            subtitle: const Text('Selecciona un color'),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: PetPreferences.availableColors.length,
              itemBuilder: (context, index) {
                final color = PetPreferences.availableColors[index];
                final isSelected = color == _preferences.petColor;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () => _updatePetColor(color),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Accesorios
          ListTile(
            leading: Text(
              _preferences.accessoryEmoji.isEmpty ? '👕' : _preferences.accessoryEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            title: const Text('Accesorio'),
            subtitle: Text(_preferences.accessoryName),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: PetPreferences.availableAccessories.length,
              itemBuilder: (context, index) {
                final accessory = PetPreferences.availableAccessories[index];
                final isSelected = accessory == _preferences.accessory;
                final tempPrefs = PetPreferences(accessory: accessory);

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () => _updateAccessory(accessory),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tempPrefs.accessoryEmoji.isEmpty ? '🚫' : tempPrefs.accessoryEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tempPrefs.accessoryName,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Sección: Preferencias
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferencias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Sonido
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sonidos'),
            subtitle: const Text('Efectos de sonido al interactuar'),
            value: _preferences.soundEnabled,
            onChanged: _updateSoundEnabled,
          ),

          // Notificaciones
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            subtitle: const Text('Alertas cuando la mascota necesita atención'),
            value: _preferences.notificationsEnabled,
            onChanged: _updateNotificationsEnabled,
          ),

          const Divider(),

          // Información
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Información',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
          ),

          if (_pet != null) ...[
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Creado el'),
              subtitle: Text(
                '${_pet!.lastFed.day}/${_pet!.lastFed.month}/${_pet!.lastFed.year}',
              ),
            ),
          ],

          const Divider(),

          // Sección: Datos ML (Desarrollador)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Datos ML (Desarrollador)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            title: const Text('Exportar datos reales'),
            subtitle: const Text('Exporta tu historial de interacciones'),
            trailing: const Icon(Icons.chevron_right),
            enabled: !_isExporting,
            onTap: _exportMLData,
          ),

          ListTile(
            leading: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.science),
            title: const Text('Generar datos sintéticos'),
            subtitle: const Text('Genera 500 registros para entrenamiento'),
            trailing: const Icon(Icons.chevron_right),
            enabled: !_isExporting,
            onTap: _generateSyntheticData,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
