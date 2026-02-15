import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'pet_state_provider.dart';

part 'metrics_update_provider.g.dart';

/// Provider para el timer de actualización automática de métricas
///
/// Gestiona un Timer periódico que actualiza las métricas de la mascota
/// cada N segundos (definido en AppConstants.foregroundUpdateInterval).
/// Se pausa cuando la app está en background y se reanuda al volver.
@riverpod
class MetricsUpdateNotifier extends _$MetricsUpdateNotifier {
  Timer? _timer;
  DateTime _lastUpdate = DateTime.now();

  @override
  void build() {
    // Auto-cleanup: cancelar timer cuando el provider se destruye
    ref.onDispose(() {
      _timer?.cancel();
      appLogger.d('MetricsUpdateNotifier disposed - timer cancelado');
    });

    // Iniciar el timer automáticamente
    _startTimer();
  }

  /// Inicia el timer de actualización periódica
  void _startTimer() {
    _timer?.cancel();
    _lastUpdate = DateTime.now();

    _timer = Timer.periodic(
      Duration(seconds: AppConstants.foregroundUpdateInterval),
      (timer) => _updateMetrics(),
    );

    appLogger.d(
      'Timer iniciado - actualizando cada ${AppConstants.foregroundUpdateInterval}s',
    );
  }

  /// Actualiza las métricas de la mascota
  ///
  /// Llama a PetState.updateMetrics() con el tiempo transcurrido desde
  /// la última actualización.
  void _updateMetrics() {
    final now = DateTime.now();

    // Llamar a PetState.updateMetrics() con el timestamp de última actualización
    ref.read(petStateProvider.notifier).updateMetrics(_lastUpdate);

    _lastUpdate = now;
  }

  /// Pausa el timer (útil cuando la app va a background)
  void pause() {
    _timer?.cancel();
    appLogger.d('Timer pausado');
  }

  /// Reanuda el timer (útil cuando la app vuelve a foreground)
  void resume() {
    appLogger.d('Timer resumido');
    _startTimer();
  }
}
