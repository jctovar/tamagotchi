import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'services/background_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicio de notificaciones
  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  // Inicializar servicio de background
  await BackgroundService.initialize();
  await BackgroundService.registerPeriodicTask();

  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
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
