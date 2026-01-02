import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Widget principal con Bottom Navigation Bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Lista de pantallas
  // NOTA: Con Riverpod, los GlobalKeys no son necesarios
  // El estado se sincroniza automáticamente a través de providers
  late final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const SettingsScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Con Riverpod, no es necesario recargar manualmente
          // El estado se sincroniza automáticamente a través de providers
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mi Mascota',
            tooltip: 'Cuidar a tu Tamagotchi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
            tooltip: 'Ver estadísticas y análisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
            tooltip: 'Personalizar tu mascota',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Acerca de',
            tooltip: 'Información de la aplicación',
          ),
        ],
      ),
    );
  }
}
