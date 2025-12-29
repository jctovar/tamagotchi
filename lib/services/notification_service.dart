import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/pet.dart';

/// Servicio para manejar notificaciones locales
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'tamagotchi_critical';
  static const String _channelName = 'Estado Crítico';
  static const String _channelDescription =
      'Notificaciones cuando tu mascota necesita atención urgente';

  /// Inicializa el servicio de notificaciones
  static Future<void> initialize() async {
    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS (opcional)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificación para Android
    await _createNotificationChannel();

    debugPrint('🔔 Servicio de notificaciones inicializado');
  }

  /// Crea el canal de notificación para Android
  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Callback cuando se toca una notificación
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notificación tocada: ${response.payload}');
    // Aquí podrías navegar a una pantalla específica
  }

  /// Solicita permisos de notificación (principalmente para Android 13+)
  static Future<bool> requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      debugPrint('🔔 Permisos de notificación: ${granted == true ? "Concedidos" : "Denegados"}');
      return granted ?? false;
    }

    return true; // Por defecto true para versiones antiguas
  }

  /// Envía una notificación de estado crítico
  static Future<void> showCriticalNotification(Pet pet) async {
    if (!pet.isCritical) return;

    String title = '⚠️ ¡Tu Tamagotchi necesita ayuda!';
    String body = _getCriticalMessage(pet);
    String payload = 'critical_state';

    await _showNotification(
      id: 1,
      title: title,
      body: body,
      payload: payload,
    );

    debugPrint('🔔 Notificación crítica enviada: $body');
  }

  /// Obtiene el mensaje apropiado según el estado crítico
  static String _getCriticalMessage(Pet pet) {
    if (pet.health < 30) {
      return '${pet.name} está muy enfermo. ¡Necesita cuidados ahora!';
    } else if (pet.hunger > 80) {
      return '${pet.name} tiene mucha hambre. ¡Aliméntalo pronto!';
    } else if (pet.energy < 20) {
      return '${pet.name} está agotado. ¡Deja que descanse!';
    } else if (pet.happiness < 30) {
      return '${pet.name} está muy triste. ¡Juega con él!';
    }
    return '${pet.name} necesita tu atención urgente.';
  }

  /// Envía una notificación recordatorio general
  static Future<void> showReminderNotification() async {
    await _showNotification(
      id: 2,
      title: '🐾 No olvides a tu Tamagotchi',
      body: 'Hace tiempo que no juegas con tu mascota. ¡Visítala!',
      payload: 'reminder',
    );

    debugPrint('🔔 Notificación recordatorio enviada');
  }

  /// Método interno para mostrar notificaciones
  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancela todas las notificaciones
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🔕 Todas las notificaciones canceladas');
  }

  /// Cancela una notificación específica
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔕 Notificación $id cancelada');
  }
}
