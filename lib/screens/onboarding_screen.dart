import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingKey = 'has_seen_onboarding';

  /// Verifica si el usuario ya vio el onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Marca el onboarding como completado
  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  void _onDone(BuildContext context) async {
    await setOnboardingComplete();
    await AnalyticsService.logOnboardingCompleted();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "¡Bienvenido a Tamagotchi!",
          body:
              "Cuida de tu mascota virtual y mantenla feliz y saludable. Tu Tamagotchi necesita tu atención constante para prosperar.",
          image: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('😊', style: TextStyle(fontSize: 100))),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Cuida a Tu Mascota",
          body:
              "Alimenta, juega, limpia y deja descansar a tu mascota. Cada acción afecta su hambre, felicidad, energía y salud.",
          image: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionIcon(context, Icons.restaurant, Colors.orange),
                    SizedBox(width: 16),
                    _buildActionIcon(
                      context,
                      Icons.sports_esports,
                      Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionIcon(
                      context,
                      Icons.cleaning_services,
                      Colors.green,
                    ),
                    SizedBox(width: 16),
                    _buildActionIcon(context, Icons.bedtime, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 60),
          ),
        ),
        PageViewModel(
          title: "Personaliza Tu Mascota",
          body:
              "Elige entre 8 colores y 5 accesorios. Dale un nombre único y hazla verdaderamente tuya.",
          image: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink, width: 3),
                  ),
                  child: Center(
                    child: Text('😊', style: TextStyle(fontSize: 100)),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 30,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text('🎀', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ],
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "Notificaciones",
          body:
              "Recibirás alertas cuando tu mascota necesite atención urgente. ¡No dejes que entre en estado crítico!",
          image: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: Center(
                    child: Text('😵', style: TextStyle(fontSize: 100)),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '¡Tu mascota necesita\natención!',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
        PageViewModel(
          title: "¡Comienza la Aventura!",
          body:
              "Tu Tamagotchi vivirá 24/7, incluso cuando la app esté cerrada. ¡Cuídala bien y crecerán juntos!",
          image: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.pets, size: 100, color: Colors.white),
              ),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
      ],
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context),
      showSkipButton: true,
      skip: const Text('Saltar', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text(
        'Comenzar',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.primary,
        color: Colors.grey,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }
}
