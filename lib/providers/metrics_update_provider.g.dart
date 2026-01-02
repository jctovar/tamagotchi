// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$metricsUpdateNotifierHash() =>
    r'38f76b6afe77f32900f355cc2d980262e7383b29';

/// Provider para el timer de actualización automática de métricas
///
/// Gestiona un Timer periódico que actualiza las métricas de la mascota
/// cada N segundos (definido en AppConstants.foregroundUpdateInterval).
/// Se pausa cuando la app está en background y se reanuda al volver.
///
/// Copied from [MetricsUpdateNotifier].
@ProviderFor(MetricsUpdateNotifier)
final metricsUpdateNotifierProvider =
    AutoDisposeNotifierProvider<MetricsUpdateNotifier, void>.internal(
      MetricsUpdateNotifier.new,
      name: r'metricsUpdateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$metricsUpdateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MetricsUpdateNotifier = AutoDisposeNotifier<void>;
String _$appLifecycleNotifierHash() =>
    r'cffddb317a857b5605961053f952ef40321297fc';

/// Provider para el estado del lifecycle de la aplicación
///
/// Observa cambios en el lifecycle de la app (paused, resumed, etc.)
/// y pausa/reanuda el timer de métricas según corresponda.
///
/// Copied from [AppLifecycleNotifier].
@ProviderFor(AppLifecycleNotifier)
final appLifecycleNotifierProvider =
    AutoDisposeNotifierProvider<
      AppLifecycleNotifier,
      AppLifecycleState
    >.internal(
      AppLifecycleNotifier.new,
      name: r'appLifecycleNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appLifecycleNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppLifecycleNotifier = AutoDisposeNotifier<AppLifecycleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
