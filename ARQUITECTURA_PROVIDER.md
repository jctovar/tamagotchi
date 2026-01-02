# Arquitectura de Gestión de Estado con Provider

## Resumen

Se ha implementado un sistema de gestión de estado centralizado usando Provider para resolver el problema de sincronización del nombre del Tamagotchi y otras propiedades entre pantallas.

## Problema Original

**Síntoma**: El nombre del Tamagotchi no se actualizaba en tiempo real entre pantallas.

**Causa raíz**:
- `HomeScreen` y `SettingsScreen` eran widgets independientes
- Cada uno manejaba su propia copia del estado de Pet
- `MainNavigation` usaba `IndexedStack` que preservaba el estado de cada pantalla
- No había comunicación entre pantallas cuando el estado cambiaba

**Ejemplo del problema**:
1. Usuario en HomeScreen ve "Mi Tamagotchi"
2. Navega a Settings y cambia el nombre a "Pikachu"
3. Vuelve a HomeScreen y sigue viendo "Mi Tamagotchi"
4. Solo al reiniciar la app se veía "Pikachu"

## Solución Implementada

### 1. PetProvider (Gestión de Estado Centralizada)

**Archivo**: `/lib/providers/pet_provider.dart`

```dart
class PetProvider with ChangeNotifier {
  Pet? _pet;
  PetPreferences _preferences;

  // Actualiza el nombre y notifica a todos los widgets
  Future<void> updatePetName(String name) async {
    final updatedPet = _pet!.copyWith(name: name);
    await updatePet(updatedPet);
  }
}
```

**Responsabilidades**:
- Mantener el estado global de Pet y PetPreferences
- Persistir cambios automáticamente en SharedPreferences
- Notificar a todos los widgets cuando hay cambios
- Proveer métodos para actualizar: nombre, color, accesorios, etc.

### 2. PetNameDisplay (Widget Reutilizable)

**Archivo**: `/lib/widgets/pet_name_display.dart`

```dart
class PetNameDisplay extends StatelessWidget {
  final bool editable;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        // Se actualiza automáticamente cuando cambia el nombre
        return Text(petProvider.pet!.name);
      },
    );
  }
}
```

**Características**:
- Muestra el nombre actual del Pet
- Se actualiza automáticamente (Consumer)
- Modo editable: muestra diálogo para cambiar nombre
- Completamente reutilizable en cualquier pantalla

### 3. Integración en Main App

**Archivo**: `/lib/main.dart`

```dart
class TamagotchiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PetProvider()..loadPet(),
      child: MaterialApp(...),
    );
  }
}
```

El Provider se crea en la raíz de la app, haciendo el estado accesible en toda la aplicación.

## Flujo de Datos

### Actualización del Nombre

```
1. Usuario hace tap en PetNameDisplay (editable: true)
   ↓
2. Se muestra diálogo con TextField
   ↓
3. Usuario ingresa nuevo nombre y presiona "Guardar"
   ↓
4. PetNameDisplay llama: petProvider.updatePetName(newName)
   ↓
5. PetProvider:
   - Actualiza _pet con el nuevo nombre
   - Guarda en SharedPreferences
   - Llama notifyListeners()
   ↓
6. Todos los widgets Consumer se reconstruyen automáticamente
   ↓
7. Nombre actualizado visible en TODAS las pantallas
```

### Lectura del Nombre

```
Widget usa Consumer<PetProvider>
   ↓
Provider detecta que el widget escucha cambios
   ↓
Widget se reconstruye cuando notifyListeners() se llama
   ↓
Widget muestra siempre el valor más reciente
```

## Archivos Modificados

### Creados
- `/lib/providers/pet_provider.dart` - Provider de estado global
- `/lib/widgets/pet_name_display.dart` - Widget reutilizable de nombre

### Modificados
- `/lib/main.dart` - Agregado ChangeNotifierProvider
- `/lib/widgets/pet_display.dart` - Usa PetNameDisplay
- `/lib/screens/settings_screen.dart` - Usa Consumer y PetProvider

## Uso del Widget PetNameDisplay

### Modo Solo Lectura
```dart
PetNameDisplay(
  textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  editable: false,
)
```

### Modo Editable
```dart
PetNameDisplay(
  editable: true,
  textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)
// Al hacer tap, muestra diálogo para editar
```

## Ventajas de esta Arquitectura

### 1. **Sincronización Automática**
- Todos los widgets ven el mismo estado
- Cambios en una pantalla se reflejan instantáneamente en todas

### 2. **Persistencia Integrada**
- Provider maneja la persistencia automáticamente
- No necesitas llamar `saveState()` manualmente

### 3. **Código Limpio**
- Widgets más simples (no manejan persistencia)
- Lógica de negocio centralizada en el Provider
- Fácil de mantener y testear

### 4. **Escalabilidad**
- Fácil agregar más propiedades al Provider
- Patrón consistente para todo el estado global

### 5. **Reutilización**
- PetNameDisplay se puede usar en cualquier pantalla
- Comportamiento consistente en toda la app

## Patrón de Uso

### Leer Estado
```dart
// En build method
Consumer<PetProvider>(
  builder: (context, petProvider, child) {
    final pet = petProvider.pet;
    return Text(pet.name);
  },
)
```

### Actualizar Estado (sin reconstruir el widget)
```dart
// En event handlers
final petProvider = context.read<PetProvider>();
await petProvider.updatePetName('Nuevo Nombre');
```

### Escuchar Cambios
```dart
// En build method (se reconstruye automáticamente)
final petProvider = context.watch<PetProvider>();
return Text(petProvider.pet.name);
```

## Próximos Pasos Sugeridos

1. **Migrar HomeScreen**: Convertir HomeScreen para usar PetProvider completamente
   - Eliminar estado local `_pet`
   - Usar Consumer para leer y actualizar

2. **Unificar Persistencia**: Hacer que todas las actualizaciones pasen por el Provider

3. **Testing**: Agregar tests unitarios para PetProvider

4. **Optimización**: Usar `Selector` en lugar de `Consumer` donde solo necesites partes específicas del estado

## Notas Técnicas

- **Thread Safety**: Provider es seguro para usar en la UI thread
- **Performance**: Consumer solo reconstruye cuando hay cambios reales
- **Memory**: Provider se libera automáticamente cuando la app cierra
- **Persistencia**: SharedPreferences es async pero rápido (<10ms típicamente)

## Debugging

Para ver cuándo se reconstruyen los widgets:
```dart
Consumer<PetProvider>(
  builder: (context, petProvider, child) {
    print('Widget reconstruido: ${petProvider.pet?.name}');
    return Text(petProvider.pet!.name);
  },
)
```

Para verificar la persistencia:
```dart
// En PetProvider
Future<void> updatePetName(String name) async {
  appLogger.d('Actualizando nombre: ${_pet!.name} -> $name');
  // ... resto del código
}
```

## Referencias

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [ChangeNotifier Documentation](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
