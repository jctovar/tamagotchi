// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minigames_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameStatsHash() => r'9bd78daacdf69b7d32eea1a35a17774ab44fc7ae';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider derivado para obtener estadísticas de un juego específico
///
/// Copied from [gameStats].
@ProviderFor(gameStats)
const gameStatsProvider = GameStatsFamily();

/// Provider derivado para obtener estadísticas de un juego específico
///
/// Copied from [gameStats].
class GameStatsFamily extends Family<GameStats?> {
  /// Provider derivado para obtener estadísticas de un juego específico
  ///
  /// Copied from [gameStats].
  const GameStatsFamily();

  /// Provider derivado para obtener estadísticas de un juego específico
  ///
  /// Copied from [gameStats].
  GameStatsProvider call(MiniGameType gameType) {
    return GameStatsProvider(gameType);
  }

  @override
  GameStatsProvider getProviderOverride(covariant GameStatsProvider provider) {
    return call(provider.gameType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameStatsProvider';
}

/// Provider derivado para obtener estadísticas de un juego específico
///
/// Copied from [gameStats].
class GameStatsProvider extends AutoDisposeProvider<GameStats?> {
  /// Provider derivado para obtener estadísticas de un juego específico
  ///
  /// Copied from [gameStats].
  GameStatsProvider(MiniGameType gameType)
    : this._internal(
        (ref) => gameStats(ref as GameStatsRef, gameType),
        from: gameStatsProvider,
        name: r'gameStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameStatsHash,
        dependencies: GameStatsFamily._dependencies,
        allTransitiveDependencies: GameStatsFamily._allTransitiveDependencies,
        gameType: gameType,
      );

  GameStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameType,
  }) : super.internal();

  final MiniGameType gameType;

  @override
  Override overrideWith(GameStats? Function(GameStatsRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: GameStatsProvider._internal(
        (ref) => create(ref as GameStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameType: gameType,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<GameStats?> createElement() {
    return _GameStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameStatsProvider && other.gameType == gameType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameStatsRef on AutoDisposeProviderRef<GameStats?> {
  /// The parameter `gameType` of this provider.
  MiniGameType get gameType;
}

class _GameStatsProviderElement extends AutoDisposeProviderElement<GameStats?>
    with GameStatsRef {
  _GameStatsProviderElement(super.provider);

  @override
  MiniGameType get gameType => (origin as GameStatsProvider).gameType;
}

String _$miniGameStatsStateHash() =>
    r'950d4ce3421c9bfdfe994d97a46f038b0cf1e5cb';

/// Provider para el estado de estadísticas de mini-juegos
///
/// Gestiona las estadísticas de todos los mini-juegos y coordina
/// las recompensas (XP y monedas) con el PetStateProvider.
///
/// Copied from [MiniGameStatsState].
@ProviderFor(MiniGameStatsState)
final miniGameStatsStateProvider =
    AutoDisposeAsyncNotifierProvider<
      MiniGameStatsState,
      MiniGameStats
    >.internal(
      MiniGameStatsState.new,
      name: r'miniGameStatsStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$miniGameStatsStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MiniGameStatsState = AutoDisposeAsyncNotifier<MiniGameStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
