# Cómo Probar la Persistencia Correctamente

## ⚠️ IMPORTANTE: Hot Reload vs. Cerrar App

**La persistencia NO funciona con Hot Reload (`r`)** porque Flutter mantiene el estado en memoria.

Para probar la persistencia correctamente, debes **CERRAR LA APP COMPLETAMENTE**.

## 📱 Método 1: Cerrar desde el Dispositivo/Emulador (RECOMENDADO)

### Pasos:

1. **Abre la app** (ya está corriendo en el emulador)

2. **Interactúa con tu mascota**:
   - Presiona "Alimentar" varias veces (verás el hambre bajar)
   - Presiona "Jugar" varias veces (verás la felicidad subir y la energía bajar)
   - Observa los valores actuales de las métricas

3. **Cierra la app COMPLETAMENTE**:
   - En el emulador Android: Presiona el botón de "Overview" (cuadrado) y desliza la app hacia arriba
   - O desde la terminal donde está corriendo `flutter run`, presiona `q` (quit)

4. **Vuelve a abrir la app**:
   - Si usaste `q`, ejecuta de nuevo: `flutter run -d emulator-5554`
   - Si cerraste desde el emulador, abre la app desde el ícono

5. **Verifica los logs** en la terminal:
   ```
   I/flutter: 🔄 Cargando estado de la mascota...
   I/flutter: ✅ Estado cargado: {"name":"Mi Tamagotchi","hunger":XX,...
   I/flutter: 📊 Estado anterior - Hambre: XX, Felicidad: XX
   ```

6. **Verifica visualmente**: Las métricas deben estar EXACTAMENTE como las dejaste

## 🕐 Método 2: Probar Decaimiento con el Tiempo

### Pasos:

1. **Interactúa con la mascota**:
   - Alimenta hasta hambre = 0
   - Juega hasta felicidad = 100

2. **Cierra la app completamente** (presiona `q`)

3. **Espera 3-5 minutos**

4. **Vuelve a abrir la app**: `flutter run -d emulator-5554`

5. **Observa los cambios**:
   - Hambre habrá aumentado (~9-15 puntos)
   - Felicidad habrá disminuido (~5-9 puntos)
   - Energía habrá disminuido (~3-6 puntos)

## 📊 Logs que Debes Ver

### Primera vez (sin estado previo):
```
I/flutter: 🔄 Cargando estado de la mascota...
I/flutter: ℹ️ No hay estado guardado previo
I/flutter: 🆕 Creando mascota nueva
I/flutter: ✅ Estado guardado: {"name":"Mi Tamagotchi",...
```

### Al reabrir (con estado guardado):
```
I/flutter: 🔄 Cargando estado de la mascota...
I/flutter: ✅ Estado cargado: {"name":"Mi Tamagotchi",...
I/flutter: 📊 Estado anterior - Hambre: 15.5, Felicidad: 87.2
I/flutter: 📊 Estado actualizado - Hambre: 24.8, Felicidad: 82.5
I/flutter: ✅ Estado guardado: {"name":"Mi Tamagotchi",...
```

### Al interactuar (alimentar, jugar, etc.):
```
I/flutter: 💾 Guardando estado actual...
I/flutter: ✅ Estado guardado: {"name":"Mi Tamagotchi",...
```

## ❌ Errores Comunes

### 1. "No veo cambios"
**Causa**: Usaste Hot Reload (`r`) en lugar de cerrar la app
**Solución**: Presiona `q` para cerrar completamente, luego vuelve a ejecutar `flutter run`

### 2. "Las métricas no decayeron"
**Causa**: No esperaste suficiente tiempo o reabriste muy rápido
**Solución**: Espera al menos 2-3 minutos antes de reabrir

### 3. "Apareció una mascota nueva"
**Causa**: Los datos se borraron o hubo un error
**Solución**: Revisa los logs, debe decir "❌ Error cargando estado"

## 🧪 Prueba Rápida (30 segundos)

Si quieres una prueba rápida:

1. Con la app abierta, presiona "Alimentar" 3 veces
2. Observa el valor de hambre (debe estar en ~10 o menos)
3. Presiona `q` en la terminal
4. Ejecuta: `flutter run -d emulator-5554`
5. La app debe abrir con hambre ligeramente mayor (13-15)

## 📝 Comandos Útiles

```bash
# Ver logs en tiempo real (abre en otra terminal)
flutter logs

# Limpiar el estado guardado (borrar persistencia)
# Desinstala la app del emulador y vuélvela a instalar
flutter clean
flutter run -d emulator-5554
```

## ✅ ¿Cómo Sé que Funciona?

La persistencia funciona correctamente si:

1. ✅ Al cerrar y reabrir, las métricas están como las dejaste
2. ✅ Los logs muestran "✅ Estado cargado"
3. ✅ Al esperar tiempo, las métricas decaen
4. ✅ El estado de ánimo (emoji) se mantiene entre sesiones

## 🎯 Estado Actual

La persistencia **ESTÁ FUNCIONANDO** como lo demuestran los logs:
- Se guarda el estado en SharedPreferences
- Se carga correctamente al iniciar
- Se calcula el decaimiento basado en tiempo
- Se actualiza después de cada acción

El único requisito es **cerrar la app completamente** (no usar hot reload).
