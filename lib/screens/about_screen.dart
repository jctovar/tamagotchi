import 'package:flutter/material.dart';
import 'credits_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const String routeName = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acerca de la aplicación")),

      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                Icons.pets,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 15),
              Text(
                'Aplicación desarrollada por la Facultad de Estudios Superiores Iztacala. '
                'Hecho en México, Universidad Nacional Autónoma de México (UNAM), '
                'todos los derechos reservados 2021.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'apps@iztacala.unam.mx',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return const CreditsScreen(title: 'Créditos');
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Créditos'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
