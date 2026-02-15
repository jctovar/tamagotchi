// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el timer de actualización automática de métricas
///
/// Gestiona un Timer periódico que actualiza las métricas de la mascota
/// cada N segundos (definido en AppConstants.foregroundUpdateInterval).
/// Se pausa cuando la app está en background y se reanuda al volver.

@ProviderFor(MetricsUpdateNotifier)
final metricsUpdateProvider = MetricsUpdateNotifierProvider._();

/// Provider para el timer de actualización automática de métricas
///
/// Gestiona un Timer periódico que actualiza las métricas de la mascota
/// cada N segundos (definido en AppConstants.foregroundUpdateInterval).
/// Se pausa cuando la app está en background y se reanuda al volver.
final class MetricsUpdateNotifierProvider
    extends $NotifierProvider<MetricsUpdateNotifier, void> {
  /// Provider para el timer de actualización automática de métricas
  ///
  /// Gestiona un Timer periódico que actualiza las métricas de la mascota
  /// cada N segundos (definido en AppConstants.foregroundUpdateInterval).
  /// Se pausa cuando la app está en background y se reanuda al volver.
  MetricsUpdateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metricsUpdateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metricsUpdateNotifierHash();

  @$internal
  @override
  MetricsUpdateNotifier create() => MetricsUpdateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$metricsUpdateNotifierHash() =>
    r'38f76b6afe77f32900f355cc2d980262e7383b29';

/// Provider para el timer de actualización automática de métricas
///
/// Gestiona un Timer periódico que actualiza las métricas de la mascota
/// cada N segundos (definido en AppConstants.foregroundUpdateInterval).
/// Se pausa cuando la app está en background y se reanuda al volver.

abstract class _$MetricsUpdateNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
