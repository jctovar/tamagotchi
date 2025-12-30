# ROADMAP.md

Hoja de ruta para el desarrollo de la aplicación Tamagotchi en Flutter.

## Fase 1: Fundamentos y Estructura Base ✅

- [x] Definir estructura de carpetas del proyecto (models, services, screens, widgets, utils)
- [x] Crear modelo de datos `Pet` con atributos: nombre, hambre, felicidad, energía, salud
- [x] Implementar pantalla principal con visualización básica de la mascota
- [x] Agregar indicadores visuales para cada métrica (barras de progreso)
- [x] Configurar tema y estilos de la aplicación

## Fase 2: Interacciones Básicas ✅

- [x] Implementar `feedPet()`: botón de alimentar que reduce hambre
- [x] Implementar `playWithPet()`: botón de jugar que aumenta felicidad
- [x] Implementar `cleanPet()`: botón de limpiar
- [x] Implementar `restPet()`: botón de descansar que recupera energía
- [x] Agregar animaciones visuales para cada acción
- [x] Implementar sistema de humor basado en métricas (`updateMood()`)

## Fase 3: Persistencia de Estado ✅

- [x] Agregar dependencia `shared_preferences` o `Hive`
- [x] Implementar `saveState()`: guardar estado de la mascota
- [x] Implementar `loadPetState()`: cargar estado al iniciar
- [x] Guardar timestamps de última interacción
- [x] Calcular cambios de estado basados en tiempo transcurrido al reabrir

## Fase 4: Sistema de Temporizadores ✅

- [x] Implementar `Timer.periodic` para actualización de métricas en foreground
- [x] Configurar tasas de decaimiento para hambre, felicidad, energía
- [x] Agregar lógica de "muerte" o deterioro si se ignora la mascota
- [x] Implementar sistema de estados críticos (hambriento, triste, enfermo)

## Fase 5: Procesamiento en Background (Android) ✅

- [x] Agregar dependencia `workmanager`
- [x] Implementar `startBackgroundTimer()`: tareas periódicas OS-level
- [x] Configurar tareas para actualizar métricas cada 15 minutos
- [x] Manejar lifecycle de la app (onPause, onResume)
- [x] Implementar `disposeResources()`: limpieza de recursos

## Fase 6: Sistema de Notificaciones ✅

- [x] Agregar dependencia `flutter_local_notifications`
- [x] Implementar `handleNotifications()`: alertas push
- [x] Configurar notificaciones para estados críticos
- [x] Agregar recordatorios periódicos de cuidado
- [x] Manejar permisos de notificación

## Fase 7: Personalización ✅

- [x] Permitir renombrar la mascota
- [x] Agregar opciones de apariencia (colores, accesorios)
- [x] Implementar pantalla de configuración
- [x] Guardar preferencias de personalización

## Fase 8: Pulido y UX ✅

- [x] Mejorar animaciones con expresiones faciales
- [x] Agregar efectos de sonido
- [x] Implementar onboarding para nuevos usuarios
- [x] Optimizar rendimiento y uso de batería
- [x] Pruebas en múltiples dispositivos Android

---

## Fases Opcionales (Avanzadas)

### Fase 9: Evolución y Ciclos de Vida ✅

- [x] Implementar etapas de vida (bebé, joven, adulto)
- [x] Agregar sistema de evolución basado en cuidado
- [x] Crear diferentes formas/variantes de mascota

### Fase 10: Mini-Juegos ✅

- [x] Implementar 3 mini-juegos diferentes (Memory, Sliding Puzzle, Reaction Race)
- [x] Sistema completo de monedas como nueva métrica
- [x] Sistema de recompensas dinámicas (XP y monedas según rendimiento)
- [x] Pantalla de selección de mini-juegos con estadísticas
- [x] Tracking de estadísticas por juego (partidas, victorias, récords)
- [x] Persistencia de estadísticas con SharedPreferences
- [x] Integración con HomeScreen (botón y display de monedas)
- [x] Balance de recompensas (3-8x más XP que acciones normales)

### Fase 11: Comportamientos con IA

- [ ] Integrar TensorFlow Lite
- [ ] Implementar mascota que aprende preferencias del usuario
- [ ] Respuestas adaptativas basadas en historial de interacciones

### Fase 12: Realidad Aumentada

- [ ] Integrar ARCore
- [ ] Proyectar mascota en mundo real
- [ ] Interacciones AR

### Fase 13: Características Sociales

- [ ] Compartir progreso en redes sociales
- [ ] Sistema de visitas a mascotas de amigos
- [ ] Integración con Firebase para multiplayer

---

## Dependencias Implementadas

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6

  # Persistencia
  shared_preferences: ^2.2.2

  # Background Processing
  workmanager: ^0.5.1

  # Notificaciones
  flutter_local_notifications: ^16.3.0
  permission_handler: ^11.1.0

  # UX y Feedback
  vibration: ^2.0.0
  introduction_screen: ^3.1.14
```

## Progreso del Proyecto

### ✅ Completadas (Fases 1-10)
- **Fase 1-2**: Fundamentos e Interacciones Básicas
- **Fase 3-4**: Persistencia y Temporizadores
- **Fase 5-6**: Background Processing y Notificaciones
- **Fase 7-8**: Personalización y Pulido UX
- **Fase 9**: Sistema de Evolución con 5 etapas de vida
- **Fase 10**: Sistema de Mini-Juegos con monedas y estadísticas

### 🚀 Total: 53 tareas completadas

## Notas

- MVP funcional completado (Fases 1-6) ✅
- Fases opcionales 9-10 implementadas con éxito ✅
- Las fases 11-13 pueden implementarse según tiempo y recursos
- Considerar restricciones de batería en dispositivos Android
- iOS tiene limitaciones adicionales para background processing
- Sistema de mini-juegos implementado sin dependencias de `flame` (usando Flutter nativo)
