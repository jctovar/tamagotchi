# tamagotchi

Una aplicación en Flutter (Android) que simule un Tamagotchi debe incluir mecánicas básicas de cuidado de una mascota virtual, como alimentación, juego y monitoreo de salud, para mantenerla viva y evolucionando. Aunque los detalles exactos pueden variar según el diseño, la evidencia sugiere que las implementaciones exitosas priorizan la persistencia de estado y actualizaciones en tiempo real para simular vida continua.

Características esenciales: Incluye interacciones como alimentar, jugar y limpiar, con estados de humor que cambian con el tiempo; personalización de la mascota; y notificaciones para recordatorios de cuidado.
Implementación en background: Usa plugins como WorkManager para tareas periódicas en Android (por ejemplo, aumentar el hambre cada pocos minutos), pero en iOS hay limitaciones y se recurre a alternativas como background_fetch; los isolates ayudan en cálculos intensivos sin bloquear la UI.
Funciones clave a implementar: Maneja eventos como carga de estado, actualizaciones de temporizadores y persistencia de datos para asegurar que la mascota "viva" incluso cuando la app no está abierta.

## Características Principales

Una app de este tipo debe replicar la esencia de un Tamagotchi: una mascota digital que requiere atención constante para evitar que "muera" o se deteriore. Basado en ejemplos prácticos, incluye mecánicas de cuidado (alimentar, jugar), seguimiento de métricas como hambre o felicidad, y elementos visuales como animaciones. Agrega notificaciones push para alertas en background, y opcionalmente IA para comportamientos adaptativos. La personalización, como cambiar apariencias, aumenta el engagement.

### Implementación por Plataforma:

Android: Usa workmanager para tareas OS-level que sobreviven al cierre de la app. Por ejemplo, registra una tarea periódica para aumentar hambre cada 15 minutos. Código ejemplo:

## Lista de Funciones a Implementar

Aquí una lista sugerida basada en implementaciones reales:

* initApp(): Inicializa el estado, temporizadores y servicios de background.
* loadPetState(): Carga datos persistentes como nombre, últimos timestamps de interacciones.
* updateMood(): Calcula humor basado en tiempo transcurrido (por ejemplo, hambriento si >40 segundos sin alimentar).
* feedPet(): Actualiza estado de hambre, establece humor feliz y guarda cambios.
* playWithPet(): Mejora felicidad, actualiza timestamps y activa animaciones.
* saveState(): Persiste datos en almacenamiento local.
* startBackgroundTimer(): Configura tareas periódicas para actualizaciones en fondo.
* handleNotifications(): Envía alertas push cuando el estado crítico (por ejemplo, mascota triste).
* disposeResources(): Cancela temporizadores y servicios al cerrar.

## Características Básicas (Must-Have):

* Cuidado Rutinario de la Mascota: Alimentación, limpieza, juego y descanso. Por ejemplo, botones para "alimentar" que reduzcan el nivel de hambre, o "jugar" que aumenten la felicidad. Si se ignora, la mascota puede "enfermar" o "morir", reiniciando el progreso.
* Monitoreo de Estados y Métricas: Seguimiento de variables como hambre, felicidad, energía y salud. Estas cambian con el tiempo real, usando temporizadores para simular decadencia natural (e.g., hambre aumenta cada 5 minutos).
* Personalización: Permitir renombrar la mascota, cambiar apariencias (colores, accesorios) o entornos. Esto fomenta apego emocional.
* Interacciones Visuales y Animaciones: Animaciones simples para acciones, como un rebote al jugar o expresiones faciales para humores (feliz, hambriento, triste). Usa paquetes como flutter_bloc para manejar estados reactivos.
* Notificaciones y Recordatorios: Alertas push para eventos como "Tu mascota tiene hambre" o "Es hora de jugar", integradas con Firebase Cloud Messaging o similares.
* Persistencia de Estado: Guardado local de progreso para que la mascota "sobreviva" al cerrar la app, usando shared_preferences o Hive.

## Características Avanzadas (Opcionales para Escalabilidad):

Comportamientos Adaptativos con IA: La mascota aprende de interacciones, recordando preferencias (e.g., prefiere ciertos juegos). Integra modelos como TensorFlow Lite para respuestas conversacionales.
Mini-Juegos Integrados: Actividades como puzzles o carreras para ganar recompensas, implementadas con paquetes como Flame para juegos en Flutter.
Realidad Aumentada (AR): Proyectar la mascota en el mundo real usando ARCore/ARKit, para interacciones inmersivas.
Elementos Sociales: Compartir progreso en redes o multijugador para "visitar" mascotas de amigos.
Evolución y Ciclos de Vida: La mascota crece o evoluciona basado en cuidado, con etapas como bebé, adulto o formas especiales.

## Mecánica General:

Tareas Periódicas: Un temporizador (e.g., Timer.periodic) actualiza métricas como hambre o felicidad cada pocos segundos/minutos. Cuando la app está en foreground, esto es directo; en background, se delega a servicios del SO.
Persistencia: Al actualizar, guarda el estado en almacenamiento local. Al reabrir, carga y calcula cambios basados en timestamps (e.g., tiempo desde última interacción).
Notificaciones: Integra con firebase_messaging o flutter_local_notifications para alertas cuando un estado es crítico, incluso en background.

### Cómo Funcionaría la Implementación en Background
La clave de un Tamagotchi es que la mascota "vive" continuamente, incluso sin la app abierta. En Flutter, esto se logra con procesos en background que actualizan estados periódicamente, pero con limitaciones por plataforma debido a restricciones de batería y seguridad en móviles.

## Estado del Proyecto

### Fases Completadas

- ✅ **Fase 1**: Estructura base y UI - Modelos, widgets, pantallas, tema
- ✅ **Fase 2**: Interacciones básicas - Alimentar, jugar, limpiar, descansar
- ✅ **Fase 3**: Persistencia de estado - SharedPreferences, guardado/carga
- ✅ **Fase 4**: Temporizadores en tiempo real - Decaimiento continuo de métricas
- ✅ **Fase 5**: Background processing - WorkManager para actualizaciones 24/7
- ✅ **Fase 6**: Sistema de notificaciones - Alertas críticas cuando necesita atención
- ✅ **Fase 7**: Personalización - Colores, accesorios, renombrar mascota
- ✅ **Fase 8**: Pulido y UX - Animaciones, haptic feedback, onboarding
- ✅ **Fase 9**: Evolución y Ciclos de Vida - 5 etapas, experiencia, variantes

### Documentación por Fase

Cada fase implementada incluye documentación detallada:
- `FASE_4_TEMPORIZADORES.md` - Sistema de actualización en tiempo real
- `FASE_5_BACKGROUND.md` - Procesamiento en segundo plano
- `FASE_6_NOTIFICACIONES.md` - Sistema de notificaciones
- `FASE_7_PERSONALIZACION.md` - Sistema de personalización
- `FASE_8_PULIDO_UX.md` - Animaciones, haptic feedback y onboarding
- `FASE_9_EVOLUCION.md` - Sistema de evolución y ciclos de vida
- `COMO_PROBAR_PERSISTENCIA.md` - Guía de pruebas

Consulta `ROADMAP.md` para ver las siguientes fases opcionales (Mini-juegos, Social).

## Características Implementadas

Tu Tamagotchi incluye:

1. 🐾 **Mascota Virtual Completa** - Con estados de ánimo dinámicos
2. 🎮 **4 Acciones de Cuidado** - Alimentar, jugar, limpiar, descansar (con animaciones)
3. 💾 **Persistencia Total** - El estado se guarda entre sesiones
4. ⏱️ **Tiempo Real** - Métricas que decaen continuamente
5. 🔔 **Notificaciones** - Alertas cuando necesita atención
6. 🌙 **Background 24/7** - Vive incluso con la app cerrada
7. 🎨 **Personalización** - 8 colores y 5 accesorios
8. ✏️ **Renombrar** - Dale un nombre único a tu mascota
9. 📱 **3 Pantallas** - Cuidado, Configuración, Acerca de
10. ✨ **Animaciones Fluidas** - Botones animados y avatar que "respira"
11. 📳 **Haptic Feedback** - Vibración táctil en todas las interacciones
12. 🎓 **Onboarding** - Tutorial interactivo para nuevos usuarios
13. 🐣 **5 Etapas de Vida** - Huevo → Bebé → Niño → Adolescente → Adulto
14. ⭐ **Sistema de Experiencia** - Gana XP por cuidar, sube de nivel
15. 🦅 **3 Variantes** - Evoluciona diferente según tu cuidado
16. 🎉 **Celebración de Evolución** - Notificación especial al evolucionar

## Key Citations

* Is it possible to make a tamagotchi-like game w flutter as a no brainer
* Build Your First Flutter Game with Flame | Apps From Scratch
* How to Build an AI Virtual Pet App: A Step-by-Step Guide
* Background processes
* How I Built a Virtual Pet App in Flutter
* [A Hatsune Miku's Tamagotchi project made with Flutter - GitHub (https://github.com/wesleydevsouza/)]
* MikuDatchi?referrer=grok.com
* Running Background Tasks in Flutter - GeeksforGeeks
* Background Processing Using WorkManager and Isolates in Flutter

👥 Créditos
Desarrollado por
Facultad de Estudios Superiores Iztacala
Universidad Nacional Autónoma de México (UNAM)
Tecnologías principales
Flutter & Dart

Agradecimientos
Comunidad de FES Iztacala
Equipo de desarrollo de Flutter
Contribuidores del proyecto
Para más información sobre los créditos, consulta la sección "Acerca de" dentro de la aplicación.

📞 Contacto
FES Iztacala
🌐 Sitio Web Oficial
📱 Portal de Noticias
📧 Contacto: apps@iztacala.unam.mx
Hecho con ❤️ en Flutter | FES Iztacala, UNAM
Made with Flutter