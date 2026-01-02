// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petHungerHash() => r'079df5ca1bed3513b53f3684a73279fff3eb4879';

/// Provider que solo emite cuando el hambre cambia
///
/// Copied from [petHunger].
@ProviderFor(petHunger)
final petHungerProvider = AutoDisposeProvider<double>.internal(
  petHunger,
  name: r'petHungerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petHungerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetHungerRef = AutoDisposeProviderRef<double>;
String _$petHappinessHash() => r'aff50beab70bab719d0c978836ac2da17ad4c5ab';

/// Provider que solo emite cuando la felicidad cambia
///
/// Copied from [petHappiness].
@ProviderFor(petHappiness)
final petHappinessProvider = AutoDisposeProvider<double>.internal(
  petHappiness,
  name: r'petHappinessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petHappinessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetHappinessRef = AutoDisposeProviderRef<double>;
String _$petEnergyHash() => r'3bef138133a55af497639368c3e6b62bb433049f';

/// Provider que solo emite cuando la energía cambia
///
/// Copied from [petEnergy].
@ProviderFor(petEnergy)
final petEnergyProvider = AutoDisposeProvider<double>.internal(
  petEnergy,
  name: r'petEnergyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petEnergyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetEnergyRef = AutoDisposeProviderRef<double>;
String _$petHealthHash() => r'8904c38859f90146dc75de75b868b3ad10c533a4';

/// Provider que solo emite cuando la salud cambia
///
/// Copied from [petHealth].
@ProviderFor(petHealth)
final petHealthProvider = AutoDisposeProvider<double>.internal(
  petHealth,
  name: r'petHealthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petHealthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetHealthRef = AutoDisposeProviderRef<double>;
String _$petCoinsHash() => r'67dc1365adc02ef6048621cadd3c831be3be8938';

/// Provider que solo emite cuando las monedas cambian
///
/// Copied from [petCoins].
@ProviderFor(petCoins)
final petCoinsProvider = AutoDisposeProvider<int>.internal(
  petCoins,
  name: r'petCoinsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petCoinsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetCoinsRef = AutoDisposeProviderRef<int>;
String _$petLevelHash() => r'3e3e2e54d2c5265b8256cd0e2aed266941945b8c';

/// Provider que solo emite cuando el nivel cambia
///
/// Copied from [petLevel].
@ProviderFor(petLevel)
final petLevelProvider = AutoDisposeProvider<int>.internal(
  petLevel,
  name: r'petLevelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petLevelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetLevelRef = AutoDisposeProviderRef<int>;
String _$petIsCriticalHash() => r'2631525f317406b6e70a2b0749e0d25324c911f0';

/// Provider que solo emite cuando el estado crítico cambia
///
/// Copied from [petIsCritical].
@ProviderFor(petIsCritical)
final petIsCriticalProvider = AutoDisposeProvider<bool>.internal(
  petIsCritical,
  name: r'petIsCriticalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petIsCriticalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetIsCriticalRef = AutoDisposeProviderRef<bool>;
String _$petNameHash() => r'0b69b2763b3c0b64d91a102d95d89eac38144b65';

/// Provider que solo emite cuando el nombre cambia
///
/// Copied from [petName].
@ProviderFor(petName)
final petNameProvider = AutoDisposeProvider<String>.internal(
  petName,
  name: r'petNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetNameRef = AutoDisposeProviderRef<String>;
String _$petStateHash() => r'b1f4e739cdb96b5a0f38172f62de4e3c1f17294d';

/// Provider para el estado principal del Pet
///
/// Gestiona todo el estado de la mascota incluyendo:
/// - Métricas (hambre, felicidad, energía, salud)
/// - Acciones del usuario (feed, play, clean, rest)
/// - Sistema de experiencia y niveles
/// - Evolución y variantes
/// - Integración con Analytics
/// - Registro de interacciones para IA
///
/// Copied from [PetState].
@ProviderFor(PetState)
final petStateProvider =
    AutoDisposeAsyncNotifierProvider<PetState, Pet>.internal(
      PetState.new,
      name: r'petStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$petStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PetState = AutoDisposeAsyncNotifier<Pet>;
String _$showEvolutionDialogHash() =>
    r'30edcadbe1cc15e4f53666fe9fdba0031714c00a';

/// Provider para controlar si se debe mostrar el diálogo de evolución
///
/// Copied from [ShowEvolutionDialog].
@ProviderFor(ShowEvolutionDialog)
final showEvolutionDialogProvider =
    AutoDisposeNotifierProvider<ShowEvolutionDialog, bool>.internal(
      ShowEvolutionDialog.new,
      name: r'showEvolutionDialogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$showEvolutionDialogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowEvolutionDialog = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
