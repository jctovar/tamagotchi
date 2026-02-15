// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el estado principal del Pet
///
/// Gestiona todo el estado de la mascota incluyendo:
/// - Métricas (hambre, felicidad, energía, salud)
/// - Acciones del usuario (feed, play, clean, rest)
/// - Sistema de experiencia y niveles
/// - Evolución y variantes
/// - Integración con Analytics
/// - Registro de interacciones para IA

@ProviderFor(PetState)
final petStateProvider = PetStateProvider._();

/// Provider para el estado principal del Pet
///
/// Gestiona todo el estado de la mascota incluyendo:
/// - Métricas (hambre, felicidad, energía, salud)
/// - Acciones del usuario (feed, play, clean, rest)
/// - Sistema de experiencia y niveles
/// - Evolución y variantes
/// - Integración con Analytics
/// - Registro de interacciones para IA
final class PetStateProvider extends $AsyncNotifierProvider<PetState, Pet> {
  /// Provider para el estado principal del Pet
  ///
  /// Gestiona todo el estado de la mascota incluyendo:
  /// - Métricas (hambre, felicidad, energía, salud)
  /// - Acciones del usuario (feed, play, clean, rest)
  /// - Sistema de experiencia y niveles
  /// - Evolución y variantes
  /// - Integración con Analytics
  /// - Registro de interacciones para IA
  PetStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petStateHash();

  @$internal
  @override
  PetState create() => PetState();
}

String _$petStateHash() => r'49302135d346b8492f99d0bfa952ecd90f32204b';

/// Provider para el estado principal del Pet
///
/// Gestiona todo el estado de la mascota incluyendo:
/// - Métricas (hambre, felicidad, energía, salud)
/// - Acciones del usuario (feed, play, clean, rest)
/// - Sistema de experiencia y niveles
/// - Evolución y variantes
/// - Integración con Analytics
/// - Registro de interacciones para IA

abstract class _$PetState extends $AsyncNotifier<Pet> {
  FutureOr<Pet> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Pet>, Pet>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Pet>, Pet>,
              AsyncValue<Pet>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider que solo emite cuando el hambre cambia

@ProviderFor(petHunger)
final petHungerProvider = PetHungerProvider._();

/// Provider que solo emite cuando el hambre cambia

final class PetHungerProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider que solo emite cuando el hambre cambia
  PetHungerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petHungerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petHungerHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return petHunger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$petHungerHash() => r'079df5ca1bed3513b53f3684a73279fff3eb4879';

/// Provider que solo emite cuando la felicidad cambia

@ProviderFor(petHappiness)
final petHappinessProvider = PetHappinessProvider._();

/// Provider que solo emite cuando la felicidad cambia

final class PetHappinessProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider que solo emite cuando la felicidad cambia
  PetHappinessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petHappinessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petHappinessHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return petHappiness(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$petHappinessHash() => r'aff50beab70bab719d0c978836ac2da17ad4c5ab';

/// Provider que solo emite cuando la energía cambia

@ProviderFor(petEnergy)
final petEnergyProvider = PetEnergyProvider._();

/// Provider que solo emite cuando la energía cambia

final class PetEnergyProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider que solo emite cuando la energía cambia
  PetEnergyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petEnergyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petEnergyHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return petEnergy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$petEnergyHash() => r'3bef138133a55af497639368c3e6b62bb433049f';

/// Provider que solo emite cuando la salud cambia

@ProviderFor(petHealth)
final petHealthProvider = PetHealthProvider._();

/// Provider que solo emite cuando la salud cambia

final class PetHealthProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider que solo emite cuando la salud cambia
  PetHealthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petHealthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petHealthHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return petHealth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$petHealthHash() => r'8904c38859f90146dc75de75b868b3ad10c533a4';

/// Provider que solo emite cuando las monedas cambian

@ProviderFor(petCoins)
final petCoinsProvider = PetCoinsProvider._();

/// Provider que solo emite cuando las monedas cambian

final class PetCoinsProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider que solo emite cuando las monedas cambian
  PetCoinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petCoinsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petCoinsHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return petCoins(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$petCoinsHash() => r'67dc1365adc02ef6048621cadd3c831be3be8938';

/// Provider que solo emite cuando el nivel cambia

@ProviderFor(petLevel)
final petLevelProvider = PetLevelProvider._();

/// Provider que solo emite cuando el nivel cambia

final class PetLevelProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider que solo emite cuando el nivel cambia
  PetLevelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petLevelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petLevelHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return petLevel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$petLevelHash() => r'3e3e2e54d2c5265b8256cd0e2aed266941945b8c';

/// Provider que solo emite cuando el estado crítico cambia

@ProviderFor(petIsCritical)
final petIsCriticalProvider = PetIsCriticalProvider._();

/// Provider que solo emite cuando el estado crítico cambia

final class PetIsCriticalProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider que solo emite cuando el estado crítico cambia
  PetIsCriticalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petIsCriticalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petIsCriticalHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return petIsCritical(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$petIsCriticalHash() => r'2631525f317406b6e70a2b0749e0d25324c911f0';

/// Provider que solo emite cuando el nombre cambia

@ProviderFor(petName)
final petNameProvider = PetNameProvider._();

/// Provider que solo emite cuando el nombre cambia

final class PetNameProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider que solo emite cuando el nombre cambia
  PetNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petNameHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return petName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$petNameHash() => r'0b69b2763b3c0b64d91a102d95d89eac38144b65';

/// Provider para controlar si se debe mostrar el diálogo de evolución

@ProviderFor(ShowEvolutionDialog)
final showEvolutionDialogProvider = ShowEvolutionDialogProvider._();

/// Provider para controlar si se debe mostrar el diálogo de evolución
final class ShowEvolutionDialogProvider
    extends $NotifierProvider<ShowEvolutionDialog, bool> {
  /// Provider para controlar si se debe mostrar el diálogo de evolución
  ShowEvolutionDialogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showEvolutionDialogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showEvolutionDialogHash();

  @$internal
  @override
  ShowEvolutionDialog create() => ShowEvolutionDialog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showEvolutionDialogHash() =>
    r'30edcadbe1cc15e4f53666fe9fdba0031714c00a';

/// Provider para controlar si se debe mostrar el diálogo de evolución

abstract class _$ShowEvolutionDialog extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
