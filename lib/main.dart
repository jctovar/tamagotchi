import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'screens/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'services/background_service.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar Crashlytics para capturar errores de Flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Capturar errores asíncronos no manejados
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Inicializar servicio de notificaciones
  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  // Inicializar servicio de background
  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicTask();

  // Registrar apertura de la app
  await AnalyticsService.logAppOpened();

  // Ejecutar app dentro de zona de errores
  runZonedGuarded(
    () => runApp(const TamagotchiApp()),
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        AnalyticsService.observer,
      ],
      home: const AppInitializer(),
      routes: {
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

/// Widget que decide si mostrar onboarding o la pantalla principal
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingScreen.hasSeenOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final hasSeenOnboarding = snapshot.data ?? false;
        if (hasSeenOnboarding) {
          return const MainNavigation();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
