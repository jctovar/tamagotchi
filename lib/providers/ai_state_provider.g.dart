// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petMessageHash() => r'b893b669a29b908b7e58f6d1627728c976b1bf53';

/// Provider que genera el mensaje de la mascota reactivamente
///
/// Observa cambios en Pet, Personality e History y regenera el mensaje.
///
/// Copied from [petMessage].
@ProviderFor(petMessage)
final petMessageProvider = AutoDisposeProvider<String>.internal(
  petMessage,
  name: r'petMessageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petMessageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetMessageRef = AutoDisposeProviderRef<String>;
String _$petSuggestionHash() => r'af7784f881e45002629daf90a3ab3877eecb5a5a';

/// Provider que genera la sugerencia de acción reactivamente
///
/// Copied from [petSuggestion].
@ProviderFor(petSuggestion)
final petSuggestionProvider = AutoDisposeProvider<AISuggestion?>.internal(
  petSuggestion,
  name: r'petSuggestionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petSuggestionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetSuggestionRef = AutoDisposeProviderRef<AISuggestion?>;
String _$personalityStateHash() => r'4f190fc3dd9eee1c1a02db5a892615d51cea5e8b';

/// Provider para el estado de la personalidad de la mascota
///
/// Gestiona la personalidad adaptativa que evoluciona basada en interacciones.
///
/// Copied from [PersonalityState].
@ProviderFor(PersonalityState)
final personalityStateProvider =
    AutoDisposeAsyncNotifierProvider<PersonalityState, PetPersonality>.internal(
      PersonalityState.new,
      name: r'personalityStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$personalityStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PersonalityState = AutoDisposeAsyncNotifier<PetPersonality>;
String _$interactionHistoryStateHash() =>
    r'5ed0ea234da16b76ebafad397f51c9a821c5e888';

/// Provider para el historial de interacciones
///
/// Copied from [InteractionHistoryState].
@ProviderFor(InteractionHistoryState)
final interactionHistoryStateProvider =
    AutoDisposeAsyncNotifierProvider<
      InteractionHistoryState,
      InteractionHistory
    >.internal(
      InteractionHistoryState.new,
      name: r'interactionHistoryStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$interactionHistoryStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InteractionHistoryState =
    AutoDisposeAsyncNotifier<InteractionHistory>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
