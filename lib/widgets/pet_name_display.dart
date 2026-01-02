import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_state_provider.dart';
import '../services/analytics_service.dart';

/// Widget reutilizable para mostrar el nombre del Tamagotchi
///
/// Muestra el nombre actual y permite editarlo al hacer tap (si está habilitado).
/// Se sincroniza automáticamente con Riverpod providers.
class PetNameDisplay extends ConsumerWidget {
  /// Estilo del texto
  final TextStyle? textStyle;

  /// Permite editar el nombre al hacer tap
  final bool editable;

  /// Alineación del texto
  final TextAlign textAlign;

  const PetNameDisplay({
    super.key,
    this.textStyle,
    this.editable = false,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petStateProvider);

    return petAsync.when(
      loading: () => Text(
        'Cargando...',
        style: textStyle,
        textAlign: textAlign,
      ),
      error: (err, stack) => Text(
        'Error',
        style: textStyle,
        textAlign: textAlign,
      ),
      data: (pet) {
        final petName = pet.name;

        if (!editable) {
          return Text(
            petName,
            style: textStyle,
            textAlign: textAlign,
          );
        }

        return InkWell(
          onTap: () => _showRenameDialog(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    petName,
                    style: textStyle,
                    textAlign: textAlign,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit,
                  size: (textStyle?.fontSize ?? 14) * 0.8,
                  color: textStyle?.color?.withValues(alpha: 0.6) ??
                      Colors.grey[600],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Muestra el diálogo para renombrar la mascota
  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref) async {
    final pet = ref.read(petStateProvider).value;
    if (pet == null) return;

    final currentName = pet.name;
    final controller = TextEditingController(text: currentName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renombrar Mascota'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre',
              hintText: 'Ingresa un nombre',
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    // Procesar resultado ANTES de dispose
    if (result != null && result.isNotEmpty && result != currentName) {
      // Actualizar nombre en el provider
      await ref.read(petStateProvider.notifier).updateName(result);

      // Registrar evento en Analytics
      await AnalyticsService.logPetRenamed(
        oldName: currentName,
        newName: result,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nombre cambiado a "$result"'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // Dispose al FINAL, después de todas las operaciones
    controller.dispose();
  }
}
