// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el estado de preferencias de personalización
///
/// Gestiona las preferencias del usuario:
/// - Color de la mascota
/// - Accesorio equipado
/// - Sonidos habilitados/deshabilitados
/// - Notificaciones habilitadas/deshabilitadas

@ProviderFor(PreferencesState)
final preferencesStateProvider = PreferencesStateProvider._();

/// Provider para el estado de preferencias de personalización
///
/// Gestiona las preferencias del usuario:
/// - Color de la mascota
/// - Accesorio equipado
/// - Sonidos habilitados/deshabilitados
/// - Notificaciones habilitadas/deshabilitadas
final class PreferencesStateProvider
    extends $AsyncNotifierProvider<PreferencesState, PetPreferences> {
  /// Provider para el estado de preferencias de personalización
  ///
  /// Gestiona las preferencias del usuario:
  /// - Color de la mascota
  /// - Accesorio equipado
  /// - Sonidos habilitados/deshabilitados
  /// - Notificaciones habilitadas/deshabilitadas
  PreferencesStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesStateHash();

  @$internal
  @override
  PreferencesState create() => PreferencesState();
}

String _$preferencesStateHash() => r'510f76d8bba796d75195dc57c6e6f1d7c52e0748';

/// Provider para el estado de preferencias de personalización
///
/// Gestiona las preferencias del usuario:
/// - Color de la mascota
/// - Accesorio equipado
/// - Sonidos habilitados/deshabilitados
/// - Notificaciones habilitadas/deshabilitadas

abstract class _$PreferencesState extends $AsyncNotifier<PetPreferences> {
  FutureOr<PetPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PetPreferences>, PetPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PetPreferences>, PetPreferences>,
              AsyncValue<PetPreferences>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
