import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/feedback_service.dart';

part 'services_provider.g.dart';

/// Provider para StorageService (singleton)
///
/// Proporciona acceso a SharedPreferences para persistencia de datos.
@riverpod
StorageService storageService(Ref ref) {
  return StorageService();
}

/// Provider para AIService (singleton)
///
/// Servicio de inteligencia artificial para generar mensajes y sugerencias.
@riverpod
AIService aiService(Ref ref) {
  return AIService();
}

/// Provider para NotificationService (singleton)
///
/// Servicio de notificaciones locales.
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

/// Provider para AnalyticsService (singleton)
///
/// Servicio de analytics con Firebase.
@riverpod
AnalyticsService analyticsService(Ref ref) {
  return AnalyticsService();
}

/// Provider para FeedbackService (singleton)
///
/// Servicio de feedback háptico y de audio.
@riverpod
FeedbackService feedbackService(Ref ref) {
  return FeedbackService();
}
