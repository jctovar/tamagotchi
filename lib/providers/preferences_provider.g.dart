// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$preferencesStateHash() => r'510f76d8bba796d75195dc57c6e6f1d7c52e0748';

/// Provider para el estado de preferencias de personalización
///
/// Gestiona las preferencias del usuario:
/// - Color de la mascota
/// - Accesorio equipado
/// - Sonidos habilitados/deshabilitados
/// - Notificaciones habilitadas/deshabilitadas
///
/// Copied from [PreferencesState].
@ProviderFor(PreferencesState)
final preferencesStateProvider =
    AutoDisposeAsyncNotifierProvider<PreferencesState, PetPreferences>.internal(
      PreferencesState.new,
      name: r'preferencesStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$preferencesStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PreferencesState = AutoDisposeAsyncNotifier<PetPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
