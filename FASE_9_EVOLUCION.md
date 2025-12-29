# Fase 9: Sistema de Evolución y Ciclos de Vida - COMPLETADA ✅

## Implementación Realizada

### 1. Modelo de Etapas de Vida

**Archivo**: `lib/models/life_stage.dart`

Sistema completo de evolución con 5 etapas de vida:

#### **Etapas de Vida (LifeStage enum)**
1. **Huevo** 🥚 - 0-5 minutos (0-100 XP)
2. **Bebé** 🐣 - 5-30 minutos (100-500 XP)
3. **Niño** 🐥 - 30 min - 2 horas (500-1500 XP)
4. **Adolescente** 🐤 - 2-6 horas (1500-3000 XP)
5. **Adulto** 🐦 - 6+ horas (3000+ XP)

Cada etapa tiene:
- ✅ Nombre en español
- ✅ Emoji base característico
- ✅ Tiempo mínimo requerido
- ✅ Experiencia requerida
- ✅ Color asociado (pastel)
- ✅ Siguiente etapa

#### **Variantes de Mascota (PetVariant enum)**

Según calidad de cuidado:

1. **Descuidado** 💀 - Promedio < 40 (mal cuidado)
2. **Normal** 🐦 - Promedio 40-70 (cuidado promedio)
3. **Excelente** 🦅 - Promedio 70+ (muy buen cuidado)

Las variantes solo se muestran en etapa **Adulto**.

### 2. Sistema de Experiencia y Niveles

**Clase**: `EvolutionUtils`

#### **Ganancia de Experiencia por Acción**
```dart
Alimentar: +10 XP
Jugar: +15 XP
Limpiar: +10 XP
Descansar: +5 XP
```

#### **Cálculo de Nivel**
```dart
Nivel = sqrt(experiencia / 100) + 1

Ejemplos:
0 XP = Nivel 1
100 XP = Nivel 2
400 XP = Nivel 3
900 XP = Nivel 4
```

#### **Progreso de Nivel**
Barra de progreso visual que muestra cuánta experiencia falta para el siguiente nivel.

### 3. Lógica de Evolución

La evolución se determina por **experiencia O tiempo**, lo que ocurra primero:

```dart
// Evoluciona si tiene la experiencia necesaria
if (experience >= 3000) → Adulto
else if (experience >= 1500) → Adolescente
else if (experience >= 500) → Niño
else if (experience >= 100) → Bebé
else → Huevo

// O si ha vivido el tiempo suficiente
if (timeAlive >= 6 horas) → Adulto
else if (timeAlive >= 2 horas) → Adolescente
else if (timeAlive >= 30 min) → Niño
else if (timeAlive >= 5 min) → Bebé
else → Huevo
```

**Prioridad**: La experiencia tiene prioridad sobre el tiempo, permitiendo evolución acelerada con buen cuidado.

### 4. Actualización del Modelo Pet

**Archivo**: `lib/models/pet.dart`

Nuevas propiedades agregadas:

```dart
int experience;          // Experiencia acumulada
int totalTimeAlive;      // Tiempo total vivo en segundos
DateTime birthDate;      // Fecha de nacimiento
LifeStage lifeStage;    // Etapa de vida actual
PetVariant variant;     // Variante según cuidado
```

Nuevos métodos:

```dart
int get level;                  // Nivel actual
double get levelProgress;       // Progreso hacia siguiente nivel
int get experienceForNextLevel; // XP necesaria para nivel siguiente

Pet gainExperience(String action);  // Gana XP por acción
Pet updateLifeStage();              // Actualiza etapa de vida
Pet updateVariant();                // Actualiza variante
```

### 5. UI con Indicadores de Evolución

**Archivo**: `lib/widgets/pet_display.dart`

El widget de la mascota fue actualizado con:

#### **Indicador de Nivel y Experiencia**
- Icono de estrella ⭐
- Nivel actual (ej: "Nivel 3")
- Experiencia total (ej: "450 XP")
- Barra de progreso dorada
- Progreso hacia siguiente nivel

#### **Indicador de Etapa de Vida**
- Emoji de la etapa
- Nombre de la etapa
- Color de fondo según etapa
- Borde con color de la etapa

#### **Avatar que Cambia con Evolución**
- Huevo 🥚 → Bebé 🐣 → Niño 🐥 → Adolescente 🐤 → Adulto 🐦/🦅/💀
- En etapa adulta, muestra la variante según cuidado
- Estado crítico 😵 siempre visible

### 6. Integración en HomeScreen

**Archivo**: `lib/screens/home_screen.dart`

#### **Ganancia de XP al Hacer Acciones**
Cada botón de acción ahora:
1. Guarda etapa anterior
2. Ejecuta acción normal
3. Gana experiencia correspondiente
4. Actualiza etapa de vida
5. Actualiza variante
6. Verifica si hubo evolución
7. Muestra feedback con XP ganada

#### **Actualización Periódica**
El timer de 1 segundo:
1. Actualiza métricas normales
2. Actualiza tiempo vivo
3. Recalcula etapa de vida
4. Recalcula variante
5. Detecta evolución automática

#### **Diálogo de Celebración de Evolución**
Cuando la mascota evoluciona:
```
🎉 ¡Evolución!

¡Mi Tamagotchi ha evolucionado!

[Emoji grande de la nueva etapa]

Ahora es un Bebé
[Botón: ¡Genial!]
```

## Cómo Funciona

### Flujo de Evolución por Experiencia

```
Usuario presiona "Jugar"
  ↓
Acción: happiness +25, energy -15
  ↓
Gana experiencia: +15 XP
  ↓
Experiencia total: 115 XP
  ↓
EvolutionUtils.calculateLifeStage()
  ↓
115 XP >= 100 XP (Bebé)
  ↓
Etapa anterior: Huevo
Etapa nueva: Bebé
  ↓
Cambio detectado
  ↓
Muestra diálogo de celebración
  ↓
"¡Mi Tamagotchi ha evolucionado!"
🐣 "Ahora es un Bebé"
```

### Flujo de Evolución por Tiempo

```
Timer ejecuta cada 1s
  ↓
Actualiza timeAlive (+1s)
  ↓
timeAlive = 301s (5 minutos 1 segundo)
  ↓
EvolutionUtils.calculateLifeStage()
  ↓
301s >= 300s (Bebé)
  ↓
Etapa anterior: Huevo
Etapa nueva: Bebé
  ↓
Cambio detectado
  ↓
Muestra diálogo de celebración
```

### Cálculo de Variante

```
updateVariant() ejecuta
  ↓
Calcula promedio de métricas
avgScore = (health + happiness + energy) / 3
  ↓
health = 90, happiness = 80, energy = 85
avgScore = (90 + 80 + 85) / 3 = 85
  ↓
85 >= 70 → Excelente 🦅
  ↓
En etapa adulta, avatar muestra 🦅
```

## Cómo Probar

### Prueba 1: Evolución Rápida (Experiencia)

1. Abre la app
2. **Verifica**: Mascota es Huevo 🥚, Nivel 1, 0 XP
3. Presiona **"Jugar"** 7 veces
   - 7 × 15 XP = 105 XP
4. **Verifica**:
   - Nivel 2
   - Aparece diálogo: "¡Evolución!"
   - Avatar cambia a Bebé 🐣
   - Indicador muestra "Bebé"

### Prueba 2: Evolución por Tiempo

1. **Resetea la app** (borra datos)
2. Crea nueva mascota (Huevo 🥚)
3. **Espera 5 minutos** (300 segundos)
4. **Verifica**:
   - Automáticamente evoluciona a Bebé 🐣
   - Diálogo de celebración aparece
   - Sin necesidad de hacer acciones

### Prueba 3: Todas las Etapas

Para probar rápidamente todas las etapas:

```dart
// SOLO PARA TESTING - en home_screen.dart, crear mascota de prueba
_pet = Pet(
  name: 'Test',
  experience: 0,      // Cambiar a 100, 500, 1500, 3000
  birthDate: DateTime.now().subtract(Duration(hours: 7)), // Adulto
);
```

### Prueba 4: Variantes de Adulto

1. Deja evolucionar hasta **Adulto**
2. **Variante Excelente** 🦅:
   - Mantén health, happiness, energy > 70
   - Avatar muestra águila
3. **Variante Normal** 🐦:
   - Mantén métricas entre 40-70
   - Avatar muestra pájaro normal
4. **Variante Descuidado** 💀:
   - Deja que métricas bajen < 40
   - Avatar muestra calavera

### Prueba 5: Persistencia de Evolución

1. Evoluciona a Bebé o Niño
2. Cierra la app completamente (`q`)
3. Reabre la app
4. **Verifica**:
   - Etapa de vida se mantiene
   - Experiencia se mantiene
   - Nivel se mantiene
   - Tiempo vivo continúa incrementando

## Archivos Creados/Modificados

### Nuevos Archivos:
- ✅ `lib/models/life_stage.dart` - Etapas de vida, variantes y utilidades
- ✅ `FASE_9_EVOLUCION.md` - Este documento

### Archivos Modificados:
- ✅ `lib/models/pet.dart` - Nuevas propiedades y métodos de evolución
- ✅ `lib/widgets/pet_display.dart` - Indicadores de nivel y etapa
- ✅ `lib/screens/home_screen.dart` - Ganancia de XP y celebración

## Características Técnicas

### Algoritmo de Evolución

**Dual-Track Evolution**:
```dart
// Experiencia tiene prioridad
if (experience >= requiredXP) {
  return correspondingStage;
}

// Fallback a tiempo si no hay XP suficiente
if (timeAlive >= requiredTime) {
  return correspondingStage;
}
```

Esto permite:
- **Evolución acelerada** cuidando bien (más XP)
- **Evolución garantizada** por tiempo (sin acciones)
- **Flexibilidad** en estilos de juego

### Cálculo de Nivel Exponencial

```dart
level = floor(sqrt(experience / 100)) + 1
```

Ejemplos de XP necesaria:
- Nivel 1→2: 100 XP
- Nivel 2→3: 300 XP adicionales
- Nivel 3→4: 500 XP adicionales
- Nivel 10: 9900 XP total

Curva exponencial hace que niveles altos sean logros significativos.

### Colores de Etapas (ARGB)

```dart
Huevo: 0xFFE0E0E0 (Gris claro)
Bebé: 0xFFFFE0B2 (Naranja pastel)
Niño: 0xFFFFF9C4 (Amarillo pastel)
Adolescente: 0xFFB3E5FC (Azul pastel)
Adulto: 0xFFC5E1A5 (Verde pastel)
```

## Balanceo del Sistema

### Tiempos de Evolución

**Solo por Tiempo** (sin acciones):
- Huevo → Bebé: 5 minutos
- Bebé → Niño: 25 minutos adicionales
- Niño → Adolescente: 1.5 horas adicionales
- Adolescente → Adulto: 4 horas adicionales
- **Total**: ~6 horas para adulto

**Solo por Experiencia** (acciones):
- Huevo → Bebé: 10 acciones de "jugar"
- Bebé → Niño: 27 acciones adicionales
- Niño → Adolescente: 67 acciones adicionales
- Adolescente → Adulto: 100 acciones adicionales
- **Total**: ~200 acciones de "jugar"

**Realista** (mix):
- Con cuidado regular: 2-4 horas
- Con cuidado intensivo: 1-2 horas
- Descuidado: 6+ horas

### Variantes Balanceadas

```dart
Excelente (70+): Requiere atención constante
Normal (40-70): Jugabilidad natural
Descuidado (<40): Advertencia visual (calavera)
```

## Estado Actual del Proyecto

**Fase 1**: ✅ Estructura base y UI
**Fase 2**: ✅ Interacciones básicas
**Fase 3**: ✅ Persistencia de estado
**Fase 4**: ✅ Temporizadores en tiempo real
**Fase 5**: ✅ Background processing
**Fase 6**: ✅ Sistema de notificaciones
**Fase 7**: ✅ Personalización
**Fase 8**: ✅ Pulido y UX
**Fase 9**: ✅ **EVOLUCIÓN Y CICLOS DE VIDA COMPLETADO** 🐣

## Características Completas

Tu Tamagotchi ahora tiene:

1. ✅ Mascota virtual completa con estados de ánimo
2. ✅ 4 acciones de cuidado con animaciones y haptic feedback
3. ✅ Persistencia total
4. ✅ Temporizadores en tiempo real
5. ✅ Background processing 24/7
6. ✅ Sistema de notificaciones
7. ✅ 8 colores y 5 accesorios
8. ✅ Renombrar mascota
9. ✅ 3 pantallas con navegación
10. ✅ Animaciones fluidas
11. ✅ Haptic feedback
12. ✅ Onboarding interactivo
13. ✅ **5 etapas de vida (Huevo → Bebé → Niño → Adolescente → Adulto)**
14. ✅ **Sistema de experiencia y niveles**
15. ✅ **3 variantes de mascota (Descuidado, Normal, Excelente)**
16. ✅ **Evolución automática y por acciones**
17. ✅ **Celebración de evolución**

## Próximas Mejoras Opcionales

### Fase 10: Mini-Juegos
- Juegos interactivos para ganar XP extra
- Desbloquear accesorios especiales
- Recompensas por completar desafíos

### Fase 11: Social
- Compartir evoluciones en redes
- Comparar niveles con amigos
- Tabla de clasificación

### Fase 12: Más Variantes
- Evoluciones ramificadas
- Formas especiales según accesorios
- Eventos de evolución especial

## Tips de Diseño

### Agregar Nueva Etapa de Vida

1. Actualiza `LifeStage` enum:
```dart
enum LifeStage {
  egg, baby, child, teen, adult, elder  // ← Nuevo
}
```

2. Actualiza extensión:
```dart
case LifeStage.elder:
  return '👴';  // Emoji
```

3. Define requisitos:
```dart
int get requiredExperience {
  case LifeStage.elder:
    return 5000;  // XP necesaria
}
```

### Cambiar Velocidad de Evolución

```dart
// Para evolución más rápida
static int getExperienceForAction(String action) {
  switch (action) {
    case 'feed':
      return 20;  // ← Era 10
    // ...
  }
}

// Para evolución más lenta
int get minTimeSeconds {
  case LifeStage.baby:
    return 600;  // ← Era 300 (10 min en vez de 5)
}
```

## Notas Técnicas

- **Enum Serialization**: Se usa `.index` para JSON (int)
- **Backwards Compatibility**: Valores por defecto para mascotas antiguas
- **Performance**: Cálculos de evolución son O(1)
- **UX**: Celebración no interrumpe juego (modal puede cerrarse)
- **Persistencia**: Tiempo vivo se recalcula al abrir app

¡Tu Tamagotchi ahora tiene un completo sistema de evolución y ciclos de vida! 🐣→🐦
