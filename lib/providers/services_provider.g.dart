// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageServiceHash() => r'a6d23bc030486b6d1106efa40d3a7733b6bf906f';

/// Provider para StorageService (singleton)
///
/// Proporciona acceso a SharedPreferences para persistencia de datos.
///
/// Copied from [storageService].
@ProviderFor(storageService)
final storageServiceProvider = AutoDisposeProvider<StorageService>.internal(
  storageService,
  name: r'storageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageServiceRef = AutoDisposeProviderRef<StorageService>;
String _$aiServiceHash() => r'c5ca77fbbebcbe821b863ad2f3cf2f523ac3a779';

/// Provider para AIService (singleton)
///
/// Servicio de inteligencia artificial para generar mensajes y sugerencias.
///
/// Copied from [aiService].
@ProviderFor(aiService)
final aiServiceProvider = AutoDisposeProvider<AIService>.internal(
  aiService,
  name: r'aiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiServiceRef = AutoDisposeProviderRef<AIService>;
String _$notificationServiceHash() =>
    r'cda5ea9d196dce85bee56839a4a0f035021752e3';

/// Provider para NotificationService (singleton)
///
/// Servicio de notificaciones locales.
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider =
    AutoDisposeProvider<NotificationService>.internal(
      notificationService,
      name: r'notificationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = AutoDisposeProviderRef<NotificationService>;
String _$analyticsServiceHash() => r'a78e9020e79b5e99632cc4cee7e5f7156c672acd';

/// Provider para AnalyticsService (singleton)
///
/// Servicio de analytics con Firebase.
///
/// Copied from [analyticsService].
@ProviderFor(analyticsService)
final analyticsServiceProvider = AutoDisposeProvider<AnalyticsService>.internal(
  analyticsService,
  name: r'analyticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsServiceRef = AutoDisposeProviderRef<AnalyticsService>;
String _$feedbackServiceHash() => r'a93cb8ffb2be4a96e708cf3efd8a85d47cd527e6';

/// Provider para FeedbackService (singleton)
///
/// Servicio de feedback háptico y de audio.
///
/// Copied from [feedbackService].
@ProviderFor(feedbackService)
final feedbackServiceProvider = AutoDisposeProvider<FeedbackService>.internal(
  feedbackService,
  name: r'feedbackServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedbackServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedbackServiceRef = AutoDisposeProviderRef<FeedbackService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
