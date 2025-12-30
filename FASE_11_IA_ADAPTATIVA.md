# Fase 11: Sistema de IA Adaptativa

## Descripción General

La Fase 11 implementa un sistema de Inteligencia Artificial que permite a la mascota aprender de las preferencias del usuario y desarrollar una personalidad única basada en cómo es cuidada.

## Características Implementadas

### 1. Historial de Interacciones

El sistema trackea todas las acciones del usuario para analizar patrones de comportamiento.

**Tipos de Interacciones:**
| Tipo | ID | Emoji | Descripción |
|------|-----|-------|-------------|
| Alimentar | `feed` | 🍔 | Usuario alimenta a la mascota |
| Jugar | `play` | 🎮 | Usuario juega con la mascota |
| Limpiar | `clean` | 🧼 | Usuario limpia a la mascota |
| Descansar | `rest` | 😴 | Usuario hace descansar a la mascota |
| Mini-juego | `minigame` | 🎯 | Usuario completa un mini-juego |
| Personalizar | `customize` | 🎨 | Usuario personaliza a la mascota |
| Evolución | `evolve` | ✨ | La mascota evoluciona |
| Abrir app | `app_open` | 📱 | Usuario abre la aplicación |
| Cerrar app | `app_close` | 👋 | Usuario cierra la aplicación |

**Datos Capturados por Interacción:**
- Tipo de interacción
- Timestamp exacto
- Período del día (Madrugada, Mañana, Tarde, Noche)
- Día de la semana
- Estado de la mascota antes de la acción
- Metadatos adicionales opcionales

### 2. Sistema de Personalidad Adaptativa

La mascota desarrolla traits de personalidad únicos basados en el cuidado recibido.

**Traits de Personalidad:**

| Trait | Emoji | Descripción | Cómo se desarrolla |
|-------|-------|-------------|-------------------|
| Juguetón | 🎮 | Le encanta jugar | Jugar frecuentemente |
| Cariñoso | 🥰 | Busca atención | Cuidado constante |
| Curioso | 🔍 | Explora todo | Mini-juegos |
| Tranquilo | 😌 | Relajado | Limpiar y descansar |
| Energético | ⚡ | Lleno de energía | Jugar mucho |
| Glotón | 🍕 | Ama la comida | Alimentar frecuentemente |
| Independiente | 🦁 | No necesita tanta atención | Poco cuidado |
| Nocturno | 🦉 | Activo de noche | Interacciones nocturnas |
| Madrugador | 🐓 | Activo en mañanas | Interacciones matutinas |
| Ansioso | 😰 | Se preocupa | Cuidado reactivo/tardío |
| Tímido | 🙈 | Reservado | Poca interacción |
| Gruñón | 😤 | Mal humor | Descuido prolongado |

**Intensidad de Traits:**
- Cada trait tiene un valor de 0-100
- Comienzan en 50 (neutral)
- Se ajustan según las acciones del usuario
- Los 3 traits más altos definen la personalidad dominante

### 3. Estados Emocionales

La mascota tiene estados emocionales que varían según las métricas y el cuidado.

| Estado | Emoji | Valor | Condición |
|--------|-------|-------|-----------|
| Extasiado | 🤩 | 1.0 | Score >= 0.9 |
| Feliz | 😊 | 0.8 | Score >= 0.75 |
| Contento | 🙂 | 0.6 | Score >= 0.6 |
| Neutral | 😐 | 0.5 | Score >= 0.45 |
| Aburrido | 😑 | 0.4 | Score >= 0.35 |
| Triste | 😢 | 0.3 | Score >= 0.25 |
| Solitario | 😔 | 0.2 | Score >= 0.15 |
| Ansioso | 😰 | 0.1 | Score < 0.15 |

**Cálculo del Score Emocional:**
```
emotionScore = (happiness/100 * 0.4) +
               (health/100 * 0.25) +
               ((100-hunger)/100 * 0.2) +
               (energy/100 * 0.15) +
               bondBonus - timeWithoutInteractionPenalty
```

### 4. Sistema de Vínculo

El nivel de vínculo refleja la relación entre el usuario y la mascota.

| Nivel | Interacciones Requeridas | Descripción |
|-------|-------------------------|-------------|
| Desconocido | 0 | Tu mascota aún no te conoce |
| Conocido | 50 | Tu mascota te está conociendo |
| Amigo | 150 | Tu mascota te considera su amigo |
| Mejor amigo | 300 | Tu mascota te adora |
| Alma gemela | 500 | Vínculo inquebrantable |

**Cómo Ganar Puntos de Vínculo:**
- +1 punto por cada interacción regular
- +2 puntos adicionales por cuidado proactivo
- +3 puntos por completar mini-juegos

### 5. Mensajes Contextuales

La mascota genera mensajes personalizados basados en:

- Estado emocional actual
- Personalidad dominante
- Nivel de vínculo
- Hora del día
- Historial de interacciones

**Ejemplos de Mensajes:**
- "¡[nombre] está súper feliz! 🎉" (estado: extasiado)
- "[nombre] está listo para jugar 🎮" (trait: juguetón)
- "[nombre] te adora 💝" (vínculo: mejor amigo)
- "¡[nombre] madrugó hoy! 🐓" (trait: madrugador + hora matutina)

### 6. Sugerencias Inteligentes

El sistema genera sugerencias basadas en el análisis del estado actual.

**Tipos de Sugerencias:**

| Tipo | Emoji | Prioridad | Descripción |
|------|-------|-----------|-------------|
| Urgente | ⚠️ | Alta | Necesidad crítica |
| Importante | ❗ | Media | Requiere atención pronto |
| Consejo | 💡 | Baja | Tip para mejorar experiencia |
| Amistoso | 💬 | Informativo | Mensaje de conexión |

### 7. Respuestas Adaptativas a Acciones

Cuando el usuario realiza una acción, la respuesta varía según la personalidad.

**Ejemplo - Alimentar:**
- Normal: "¡Ñam ñam! 🍔 (+10 XP)"
- Glotón: "¡[nombre] devora la comida! 🍔 (+10 XP)"

**Ejemplo - Jugar:**
- Normal: "¡Qué divertido! 🎮 (+15 XP)"
- Juguetón: "¡[nombre] está eufórico! 🎮 (+15 XP)"
- Tranquilo: "[nombre] juega tranquilamente 🎮 (+15 XP)"

### 8. Predicción de Necesidades

El sistema predice cuándo la mascota necesitará atención.

```dart
PredictedNeed? predictNextNeed({
  required Pet pet,
  required InteractionHistory history,
});
```

**Predicciones Disponibles:**
- Tiempo hasta hambre crítica
- Tiempo hasta felicidad baja
- Tiempo hasta energía baja

### 9. Análisis de Preferencias del Usuario

El sistema aprende:
- Hora preferida de interacción
- Período del día más activo
- Día de la semana más activo
- Tipo de interacción favorita
- Nivel de consistencia del usuario

## Arquitectura

### Archivos Creados

```
lib/
├── models/
│   ├── interaction_history.dart    # Historial de interacciones
│   └── pet_personality.dart        # Personalidad adaptativa
├── services/
│   └── ai_service.dart             # Servicio principal de IA
└── widgets/
    └── ai_insight_card.dart        # Widget de visualización de IA
```

### Archivos Modificados

```
lib/
├── services/
│   └── storage_service.dart        # Persistencia de datos de IA
└── screens/
    └── home_screen.dart            # Integración de IA en UI
```

## Flujo de Datos

```
┌─────────────────────────────────────────────────────────────┐
│                     Usuario interactúa                       │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              HomeScreen registra interacción                 │
│                    _recordInteraction()                      │
└────────────────────────────┬────────────────────────────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
┌───────────────────────┐         ┌───────────────────────────┐
│  StorageService       │         │  PetPersonality           │
│  - Guarda interacción │         │  - Actualiza traits       │
│  - Actualiza historial│         │  - Calcula puntos vínculo │
└───────────────────────┘         └───────────────────────────┘
            │                                 │
            └────────────────┬────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      AIService                               │
│  - Genera mensaje contextual                                 │
│  - Crea sugerencias                                          │
│  - Actualiza estado emocional                                │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                   AIInsightCard                              │
│  - Muestra estado emocional                                  │
│  - Muestra mensaje de mascota                                │
│  - Muestra sugerencias                                       │
│  - Muestra personalidad                                      │
│  - Muestra progreso de vínculo                               │
└─────────────────────────────────────────────────────────────┘
```

## Persistencia

Todos los datos de IA se guardan automáticamente:

```dart
// Claves de almacenamiento
static const String _interactionHistoryKey = 'interaction_history';
static const String _petPersonalityKey = 'pet_personality';
```

**Datos Persistidos:**
- Lista de interacciones (últimas 1000)
- Traits de personalidad con intensidades
- Estado emocional
- Nivel y puntos de vínculo
- Preferencias del usuario aprendidas

## Preparación para TensorFlow Lite

El sistema incluye un método para generar features normalizadas listas para un modelo ML:

```dart
List<double> generateMLFeatures({
  required Pet pet,
  required PetPersonality personality,
  required InteractionHistory history,
}) {
  return [
    pet.hunger / 100,
    pet.happiness / 100,
    pet.energy / 100,
    pet.health / 100,
    personality.emotionalState.value,
    personality.bondPoints / 500,
    history.proactiveRatio,
    history.reactiveRatio,
    history.averageInteractionsPerDay / 10,
    TimeOfDay.current.index / 4,
    DateTime.now().weekday / 7,
  ];
}
```

Este método puede usarse en el futuro para entrenar un modelo TensorFlow Lite que prediga necesidades o genere respuestas más sofisticadas.

## Uso del Widget AIInsightCard

```dart
AIInsightCard(
  pet: _pet,
  personality: _petPersonality,
  history: _interactionHistory,
  petMessage: _petMessage,
  suggestion: _currentSuggestion,
)
```

**Muestra:**
- Emoji y nombre del estado emocional
- Nivel de vínculo con color
- Puntos de vínculo totales
- Mensaje contextual de la mascota
- Sugerencia actual (si hay)
- Top 3 traits de personalidad
- Barra de progreso hacia siguiente nivel de vínculo

## Cuidado Proactivo vs Reactivo

El sistema distingue entre:

**Cuidado Proactivo:**
- Interactuar cuando la mascota está en buen estado
- Bonus de puntos de vínculo (+2)
- Reduce ansiedad de la mascota

**Cuidado Reactivo:**
- Interactuar solo cuando la mascota está en estado crítico
- Puntos de vínculo normales (+1)
- Puede aumentar ansiedad de la mascota

## Conclusión

La Fase 11 transforma al Tamagotchi de una mascota estática a un compañero inteligente que:

1. **Aprende** las preferencias y patrones del usuario
2. **Desarrolla** una personalidad única basada en el cuidado
3. **Comunica** de manera contextual y personalizada
4. **Sugiere** acciones relevantes según el análisis
5. **Evoluciona** su relación con el usuario a través del vínculo

Este sistema sienta las bases para futuras mejoras con machine learning real usando TensorFlow Lite.

---

**Implementación completada:** 2024-12-30
**Archivos nuevos:** 4
**Archivos modificados:** 2
**Total de líneas de código:** ~1,500
