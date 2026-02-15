# Interfaz Retro Pixel-Art - Guía de Implementación

## Resumen de Cambios

Se ha transformado la interfaz de la aplicación Tamagotchi a un estilo retro pixel-art inspirado en los dispositivos Tamagotchi a color.

## Paleta de Colores Tamagotchi

- **Rosa (fondo):** #FFB5C0
- **Verde (éxito):** #8BC34A
- **Azul (info):** #81D4FA
- **Naranja (advertencia):** #FFB74D
- **Morado (energía):** #BA68C8
- **Amarillo (felicidad):** #FFEE58
- **Rojo (crítico):** #EF5350
- **Marrón oscuro (texto):** #4A3728
- **Crema (fondo LCD):** #FFF9C4
- **Negro rojizo (bordes):** #2C2424

## Archivos Nuevos

### Configuración
- `lib/config/retro_theme.dart` - Tema completo con paleta retro y estilo Material3

### Widgets Retro
- `lib/widgets/retro/device_frame.dart` - Marco de dispositivo estilo Tamagotchi
- `lib/widgets/retro/retro_button.dart` - Botones con bordes pixel y animaciones frame-based
- `lib/widgets/retro/retro_progress_bar.dart` - Barras de progreso segmentadas (10 bloques)
- `lib/widgets/retro/retro_pet_display.dart` - Display de mascota con animaciones frame-based

### Assets
- `fonts/VT323-Regular.ttf` - Fuente pixel art (descargada de Google Fonts)
- `assets/sprites/README.md` - Guía para crear sprites de mascota
- `assets/icons/README.md` - Guía para crear iconos pixel

## Archivos Modificados

- `lib/config/theme.dart` - Añadido `retroTheme` y `currentTheme`
- `lib/main.dart` - Actualizado para usar `AppTheme.currentTheme`
- `lib/screens/home_screen.dart` - Actualizado para usar componentes retro
- `pubspec.yaml` - Añadida fuente VT323 y rutas de assets

## Características Implementadas

### 1. Fuente Pixel Art
- Fuente VT323 de Google Fonts para toda la aplicación
- Tipografía retro consistente en todos los componentes

### 2. Paleta de Colores Tamagotchi
- Colores vibrantes inspirados en Tamagotchis a color
- Contraste alto para legibilidad

### 3. Componentes Retro

#### DeviceFrame
- Marco rosa con bordes negro rojizo
- Esquinas redondeadas suaves (16px)
- Sombra dura (no blur)
- Contenedor interno crema estilo LCD

#### RetroProgressBar
- 10 bloques individuales (no smooth)
- Bordes pixel sin border radius
- Porcentaje visible
- Colores según el estado (verde/amarillo/rojo)

#### RetroButton
- Bordes rectos sin border radius
- Animación frame-based (cambio instantáneo)
- Sombra dura con offset
- Feedback visual al presionar

#### RetroPetDisplay
- Animación frame-based (200ms por frame, 3 frames)
- Emojis grandes para mascota (compatible con sprites futuros)
- Indicadores con estilo retro

### 4. Animaciones Frame-Based
- PetDisplay: 3 frames cíclicos para la mascota
- Botones: Cambio instantáneo entre estados (no smooth)
- Transiciones más rápidas y estilo 8-bit

### 5. Marco de Dispositivo
El `DeviceFrame` simula un dispositivo Tamagotchi con:
- Cuerpo rosa exterior
- Pantalla LCD interna
- Opcionales botones A/B/C decorativos

## Uso de Componentes

### DeviceFrame
```dart
DeviceFrame(
  child: YourContent(),
  showControls: true, // Mostrar botones A/B/C
)
```

### RetroProgressBar
```dart
RetroProgressBar(
  value: 7,  // 0-10 bloques activos
  max: 10,
  color: RetroColors.green,
  height: 12.0,
)
```

### RetroButton
```dart
RetroButton(
  label: 'Alimentar',
  icon: Icons.restaurant,
  color: RetroColors.orange,
  onPressed: () => print('Presionado'),
)
```

### RetroMetricBar
```dart
RetroMetricBar(
  label: 'Felicidad',
  value: 75.0,  // 0-100%
  color: RetroColors.yellow,
  icon: Icons.sentiment_satisfied,
)
```

## Próximos Pasos (Opcionales)

### 1. Crear Sprites de Mascota
Usa un editor de pixel art para crear 15 sprites:
- 5 etapas: egg, baby, child, teen, adult
- 3 variantes: normal, excellent, neglected

**Herramientas recomendadas:**
- Aseprite (profesional)
- Piskel (online gratuito)
- GIMP (gratis con escala píxel)

### 2. Crear Iconos Pixel
Crea 8 iconos de 16x16 píxeles:
- feed, play, clean, rest
- hunger, happiness, energy, health

### 3. Efectos Adicionales (Opcionales)
- Scanlines overlay (efecto CRT)
- Partículas pixel al interactuar
- Sonido chiptune para acciones

### 4. Pantallas Adicionales
Actualizar otras pantallas con estilo retro:
- StatsScreen
- SettingsScreen
- Mini-games

## Cambiar entre Temas

Para desactivar el tema retro, edita `lib/config/theme.dart`:

```dart
class AppTheme {
  static bool useRetroTheme = false;  // Cambiar a false para usar tema moderno
  // ...
}
```

## Resultados

- ✅ 12/12 tareas completadas
- ✅ 627/627 pruebas pasadas
- ✅ 0 errores de análisis
- ✅ Código formateado

## Notas

- Los emojis actuales funcionan como placeholders para futuros sprites
- Los iconos Material Icons mantienen compatibilidad
- La paleta de colores es consistente en toda la app
- El tema es completamente compatible con Material3
