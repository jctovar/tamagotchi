import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import '../utils/constants.dart';

/// Servicio para manejar tareas en background
class BackgroundService {
  static const String _updateTaskName = 'petUpdateTask';
  static const String _uniqueName = 'tamagotchiBackgroundUpdate';

  /// Inicializa WorkManager
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    debugPrint('🔧 WorkManager inicializado');
  }

  /// Registra la tarea periódica de actualización
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _updateTaskName,
      frequency: Duration(minutes: AppConstants.backgroundUpdateInterval),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
    debugPrint(
      '📅 Tarea periódica registrada: cada ${AppConstants.backgroundUpdateInterval} minutos',
    );
  }

  /// Cancela todas las tareas
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    debugPrint('❌ Todas las tareas canceladas');
  }

  /// Cancela la tarea periódica específica
  static Future<void> cancelPeriodicTask() async {
    await Workmanager().cancelByUniqueName(_uniqueName);
    debugPrint('❌ Tarea periódica cancelada');
  }
}

/// Callback que se ejecuta en background
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔄 Ejecutando tarea en background: $task');

    try {
      final storageService = StorageService();

      // Cargar estado actual
      final savedPet = await storageService.loadPetState();

      if (savedPet == null) {
        debugPrint('ℹ️ No hay mascota guardada, saltando actualización');
        return Future.value(true);
      }

      debugPrint(
        '📊 Estado antes de actualizar - Hambre: ${savedPet.hunger}, Felicidad: ${savedPet.happiness}',
      );

      // Actualizar métricas basado en tiempo transcurrido
      final updatedPet = storageService.updatePetMetrics(savedPet);

      debugPrint(
        '📊 Estado después de actualizar - Hambre: ${updatedPet.hunger}, Felicidad: ${updatedPet.happiness}',
      );

      // Guardar estado actualizado
      await storageService.saveState(updatedPet);

      // Enviar notificación si el estado es crítico
      if (updatedPet.isCritical) {
        debugPrint('⚠️ Estado crítico detectado en background!');
        await NotificationService.showCriticalNotification(updatedPet);
      }

      debugPrint('✅ Tarea completada exitosamente');
      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Error en tarea de background: $e');
      return Future.value(false);
    }
  });
}
