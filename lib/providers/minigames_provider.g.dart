// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minigames_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para el estado de estadísticas de mini-juegos
///
/// Gestiona las estadísticas de todos los mini-juegos y coordina
/// las recompensas (XP y monedas) con el PetStateProvider.

@ProviderFor(MiniGameStatsState)
final miniGameStatsStateProvider = MiniGameStatsStateProvider._();

/// Provider para el estado de estadísticas de mini-juegos
///
/// Gestiona las estadísticas de todos los mini-juegos y coordina
/// las recompensas (XP y monedas) con el PetStateProvider.
final class MiniGameStatsStateProvider
    extends $AsyncNotifierProvider<MiniGameStatsState, MiniGameStats> {
  /// Provider para el estado de estadísticas de mini-juegos
  ///
  /// Gestiona las estadísticas de todos los mini-juegos y coordina
  /// las recompensas (XP y monedas) con el PetStateProvider.
  MiniGameStatsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'miniGameStatsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$miniGameStatsStateHash();

  @$internal
  @override
  MiniGameStatsState create() => MiniGameStatsState();
}

String _$miniGameStatsStateHash() =>
    r'950d4ce3421c9bfdfe994d97a46f038b0cf1e5cb';

/// Provider para el estado de estadísticas de mini-juegos
///
/// Gestiona las estadísticas de todos los mini-juegos y coordina
/// las recompensas (XP y monedas) con el PetStateProvider.

abstract class _$MiniGameStatsState extends $AsyncNotifier<MiniGameStats> {
  FutureOr<MiniGameStats> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MiniGameStats>, MiniGameStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MiniGameStats>, MiniGameStats>,
              AsyncValue<MiniGameStats>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider derivado para obtener estadísticas de un juego específico

@ProviderFor(gameStats)
final gameStatsProvider = GameStatsFamily._();

/// Provider derivado para obtener estadísticas de un juego específico

final class GameStatsProvider
    extends $FunctionalProvider<GameStats?, GameStats?, GameStats?>
    with $Provider<GameStats?> {
  /// Provider derivado para obtener estadísticas de un juego específico
  GameStatsProvider._({
    required GameStatsFamily super.from,
    required MiniGameType super.argument,
  }) : super(
         retry: null,
         name: r'gameStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameStatsHash();

  @override
  String toString() {
    return r'gameStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GameStats?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameStats? create(Ref ref) {
    final argument = this.argument as MiniGameType;
    return gameStats(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameStats? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameStats?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GameStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameStatsHash() => r'5c4e580113a16f9eff3fb8568cbcbe7b98de33a0';

/// Provider derivado para obtener estadísticas de un juego específico

final class GameStatsFamily extends $Family
    with $FunctionalFamilyOverride<GameStats?, MiniGameType> {
  GameStatsFamily._()
    : super(
        retry: null,
        name: r'gameStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider derivado para obtener estadísticas de un juego específico

  GameStatsProvider call(MiniGameType gameType) =>
      GameStatsProvider._(argument: gameType, from: this);

  @override
  String toString() => r'gameStatsProvider';
}
