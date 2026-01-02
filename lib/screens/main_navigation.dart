import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

/// Widget principal con Bottom Navigation Bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey();
  final GlobalKey<SettingsScreenState> _settingsScreenKey = GlobalKey();

  // Lista de pantallas
  late final List<Widget> _screens = [
    HomeScreen(key: _homeScreenKey),
    SettingsScreen(key: _settingsScreenKey),
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

          // Recargar estado según el tab seleccionado
          // NOTA: NO recargar automáticamente en tab 0 para evitar
          // sobrescribir cambios recientes (ej. monedas de mini-juegos)
          if (index == 1) {
            _settingsScreenKey.currentState?.loadSettings();
          }
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
