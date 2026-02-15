// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el estado de la personalidad de la mascota
///
/// Gestiona la personalidad adaptativa que evoluciona basada en interacciones.

@ProviderFor(PersonalityState)
final personalityStateProvider = PersonalityStateProvider._();

/// Provider para el estado de la personalidad de la mascota
///
/// Gestiona la personalidad adaptativa que evoluciona basada en interacciones.
final class PersonalityStateProvider
    extends $AsyncNotifierProvider<PersonalityState, PetPersonality> {
  /// Provider para el estado de la personalidad de la mascota
  ///
  /// Gestiona la personalidad adaptativa que evoluciona basada en interacciones.
  PersonalityStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalityStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalityStateHash();

  @$internal
  @override
  PersonalityState create() => PersonalityState();
}

String _$personalityStateHash() => r'4f190fc3dd9eee1c1a02db5a892615d51cea5e8b';

/// Provider para el estado de la personalidad de la mascota
///
/// Gestiona la personalidad adaptativa que evoluciona basada en interacciones.

abstract class _$PersonalityState extends $AsyncNotifier<PetPersonality> {
  FutureOr<PetPersonality> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PetPersonality>, PetPersonality>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PetPersonality>, PetPersonality>,
              AsyncValue<PetPersonality>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider para el historial de interacciones

@ProviderFor(InteractionHistoryState)
final interactionHistoryStateProvider = InteractionHistoryStateProvider._();

/// Provider para el historial de interacciones
final class InteractionHistoryStateProvider
    extends
        $AsyncNotifierProvider<InteractionHistoryState, InteractionHistory> {
  /// Provider para el historial de interacciones
  InteractionHistoryStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interactionHistoryStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interactionHistoryStateHash();

  @$internal
  @override
  InteractionHistoryState create() => InteractionHistoryState();
}

String _$interactionHistoryStateHash() =>
    r'5ed0ea234da16b76ebafad397f51c9a821c5e888';

/// Provider para el historial de interacciones

abstract class _$InteractionHistoryState
    extends $AsyncNotifier<InteractionHistory> {
  FutureOr<InteractionHistory> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<InteractionHistory>, InteractionHistory>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InteractionHistory>, InteractionHistory>,
              AsyncValue<InteractionHistory>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider que genera el mensaje de la mascota reactivamente
///
/// Observa cambios en Pet, Personality e History y regenera el mensaje.

@ProviderFor(petMessage)
final petMessageProvider = PetMessageProvider._();

/// Provider que genera el mensaje de la mascota reactivamente
///
/// Observa cambios en Pet, Personality e History y regenera el mensaje.

final class PetMessageProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider que genera el mensaje de la mascota reactivamente
  ///
  /// Observa cambios en Pet, Personality e History y regenera el mensaje.
  PetMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petMessageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petMessageHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return petMessage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$petMessageHash() => r'b893b669a29b908b7e58f6d1627728c976b1bf53';

/// Provider que genera la sugerencia de acción reactivamente

@ProviderFor(petSuggestion)
final petSuggestionProvider = PetSuggestionProvider._();

/// Provider que genera la sugerencia de acción reactivamente

final class PetSuggestionProvider
    extends $FunctionalProvider<AISuggestion?, AISuggestion?, AISuggestion?>
    with $Provider<AISuggestion?> {
  /// Provider que genera la sugerencia de acción reactivamente
  PetSuggestionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petSuggestionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petSuggestionHash();

  @$internal
  @override
  $ProviderElement<AISuggestion?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AISuggestion? create(Ref ref) {
    return petSuggestion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AISuggestion? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AISuggestion?>(value),
    );
  }
}

String _$petSuggestionHash() => r'af7784f881e45002629daf90a3ab3877eecb5a5a';
