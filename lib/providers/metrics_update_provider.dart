import 'dart:async';
import 'package:flutter/widgets.dart';
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
        'Timer iniciado - actualizando cada ${AppConstants.foregroundUpdateInterval}s');
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

/// Provider para el estado del lifecycle de la aplicación
///
/// Observa cambios en el lifecycle de la app (paused, resumed, etc.)
/// y pausa/reanuda el timer de métricas según corresponda.
@riverpod
class AppLifecycleNotifier extends _$AppLifecycleNotifier
    with WidgetsBindingObserver {
  @override
  AppLifecycleState build() {
    // Registrar observer
    WidgetsBinding.instance.addObserver(this);

    // Auto-cleanup: remover observer cuando el provider se destruye
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      appLogger.d('AppLifecycleNotifier disposed - observer removido');
    });

    // Estado inicial
    return AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLogger.d('Lifecycle cambió a: $state');

    // Actualizar estado
    this.state = state;

    // Manejar cambios de lifecycle
    if (state == AppLifecycleState.paused) {
      appLogger.d('App pausada - guardando estado y pausando timer');
      ref.read(metricsUpdateNotifierProvider.notifier).pause();
    } else if (state == AppLifecycleState.resumed) {
      appLogger.d('App resumida - reiniciando timer');
      ref.read(metricsUpdateNotifierProvider.notifier).resume();
    }
  }
}
