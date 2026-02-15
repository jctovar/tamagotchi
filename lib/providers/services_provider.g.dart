// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para StorageService (singleton)
///
/// Proporciona acceso a SharedPreferences para persistencia de datos.

@ProviderFor(storageService)
final storageServiceProvider = StorageServiceProvider._();

/// Provider para StorageService (singleton)
///
/// Proporciona acceso a SharedPreferences para persistencia de datos.

final class StorageServiceProvider
    extends $FunctionalProvider<StorageService, StorageService, StorageService>
    with $Provider<StorageService> {
  /// Provider para StorageService (singleton)
  ///
  /// Proporciona acceso a SharedPreferences para persistencia de datos.
  StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  $ProviderElement<StorageService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StorageService create(Ref ref) {
    return storageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageService>(value),
    );
  }
}

String _$storageServiceHash() => r'a6d23bc030486b6d1106efa40d3a7733b6bf906f';

/// Provider para AIService (singleton)
///
/// Servicio de inteligencia artificial para generar mensajes y sugerencias.

@ProviderFor(aiService)
final aiServiceProvider = AiServiceProvider._();

/// Provider para AIService (singleton)
///
/// Servicio de inteligencia artificial para generar mensajes y sugerencias.

final class AiServiceProvider
    extends $FunctionalProvider<AIService, AIService, AIService>
    with $Provider<AIService> {
  /// Provider para AIService (singleton)
  ///
  /// Servicio de inteligencia artificial para generar mensajes y sugerencias.
  AiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiServiceHash();

  @$internal
  @override
  $ProviderElement<AIService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AIService create(Ref ref) {
    return aiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIService>(value),
    );
  }
}

String _$aiServiceHash() => r'c5ca77fbbebcbe821b863ad2f3cf2f523ac3a779';

/// Provider para NotificationService (singleton)
///
/// Servicio de notificaciones locales.

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// Provider para NotificationService (singleton)
///
/// Servicio de notificaciones locales.

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// Provider para NotificationService (singleton)
  ///
  /// Servicio de notificaciones locales.
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'cda5ea9d196dce85bee56839a4a0f035021752e3';

/// Provider para AnalyticsService (singleton)
///
/// Servicio de analytics con Firebase.

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

/// Provider para AnalyticsService (singleton)
///
/// Servicio de analytics con Firebase.

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  /// Provider para AnalyticsService (singleton)
  ///
  /// Servicio de analytics con Firebase.
  AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'a78e9020e79b5e99632cc4cee7e5f7156c672acd';

/// Provider para FeedbackService (singleton)
///
/// Servicio de feedback háptico y de audio.

@ProviderFor(feedbackService)
final feedbackServiceProvider = FeedbackServiceProvider._();

/// Provider para FeedbackService (singleton)
///
/// Servicio de feedback háptico y de audio.

final class FeedbackServiceProvider
    extends
        $FunctionalProvider<FeedbackService, FeedbackService, FeedbackService>
    with $Provider<FeedbackService> {
  /// Provider para FeedbackService (singleton)
  ///
  /// Servicio de feedback háptico y de audio.
  FeedbackServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackServiceHash();

  @$internal
  @override
  $ProviderElement<FeedbackService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedbackService create(Ref ref) {
    return feedbackService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedbackService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedbackService>(value),
    );
  }
}

String _$feedbackServiceHash() => r'a93cb8ffb2be4a96e708cf3efd8a85d47cd527e6';
