#!/usr/bin/env python3
"""
Script para entrenar el modelo CriticalTimePredictor para Tamagotchi.

Este modelo predice cuántos minutos faltan para que cada métrica
alcance un estado crítico, basándose en el estado actual y patrones.

Arquitectura:
    Input(20) → Dense(32, ReLU) → Dense(16, ReLU) → Dense(4, Linear)

Features de entrada (20):
    0-3: Métricas actuales (hunger, happiness, energy, health) [0-1]
    4-7: Tasas de decaimiento estimadas [0-1]
    8-11: Tiempo desde última acción de cada tipo [0-1]
    12-15: Patrones de usuario (proactive, reactive, frequency, consistency)
    16-19: Contexto temporal (hour, weekday, hours_since_last, is_active_time)

Salidas (4 valores de regresión):
    0: Minutos hasta hambre crítica (>70)
    1: Minutos hasta felicidad crítica (<30)
    2: Minutos hasta energía crítica (<20)
    3: Minutos hasta salud crítica (<30)

Uso:
    python train_critical_time.py [--epochs N] [--output PATH]
"""

import argparse
import numpy as np
import os
from pathlib import Path

try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False
    print("TensorFlow no está instalado. Instálalo con: pip install tensorflow")


# Constantes del modelo
INPUT_SIZE = 20
OUTPUT_SIZE = 4
METRICS = ['hunger', 'happiness', 'energy', 'health']

# Umbrales críticos (para calcular tiempo hasta crítico)
CRITICAL_THRESHOLDS = {
    'hunger': 70.0,      # Crítico cuando > 70
    'happiness': 30.0,   # Crítico cuando < 30
    'energy': 20.0,      # Crítico cuando < 20
    'health': 30.0,      # Crítico cuando < 30
}

# Tasas de decaimiento base (por minuto)
DECAY_RATES = {
    'hunger': 0.12,      # Aumenta ~7.2/hora
    'happiness': -0.06,  # Decrece ~3.6/hora
    'energy': -0.05,     # Decrece ~3/hora
    'health': -0.02,     # Decrece ~1.2/hora
}


def create_model():
    """Crea la arquitectura del modelo CriticalTimePredictor."""
    model = keras.Sequential([
        layers.Input(shape=(INPUT_SIZE,), name='input'),
        layers.Dense(32, activation='relu', name='dense_1'),
        layers.Dense(16, activation='relu', name='dense_2'),
        layers.Dense(OUTPUT_SIZE, activation='linear', name='output')
    ])

    model.compile(
        optimizer='adam',
        loss='mse',
        metrics=['mae']
    )

    return model


def calculate_time_to_critical(metric_name: str, current_value: float,
                                decay_rate: float, user_activity: float) -> float:
    """
    Calcula minutos hasta que una métrica alcance estado crítico.

    Args:
        metric_name: Nombre de la métrica
        current_value: Valor actual (0-100)
        decay_rate: Tasa de cambio por minuto
        user_activity: Factor de actividad del usuario (0-1)

    Returns:
        Minutos hasta crítico (0-180, clamped)
    """
    threshold = CRITICAL_THRESHOLDS[metric_name]

    # Ajustar decay_rate según actividad del usuario
    # Usuarios más activos cuidan mejor → métricas tardan más en decaer
    adjusted_rate = decay_rate * (1 - user_activity * 0.5)

    if metric_name == 'hunger':
        # Hunger aumenta hasta crítico
        if current_value >= threshold:
            return 0.0
        time_to_critical = (threshold - current_value) / max(adjusted_rate, 0.01)
    else:
        # Otras métricas decrecen hasta crítico
        if current_value <= threshold:
            return 0.0
        time_to_critical = (current_value - threshold) / max(abs(adjusted_rate), 0.01)

    return np.clip(time_to_critical, 0, 180)


def generate_synthetic_data(n_samples: int = 2000) -> tuple:
    """
    Genera datos sintéticos para entrenamiento.

    Returns:
        tuple: (X, y) arrays de numpy
    """
    np.random.seed(42)

    X = []
    y = []

    for _ in range(n_samples):
        # Métricas actuales (0-100, luego normalizadas a 0-1)
        hunger = np.random.uniform(0, 100)
        happiness = np.random.uniform(0, 100)
        energy = np.random.uniform(0, 100)
        health = np.random.uniform(0, 100)

        # Tasas de decaimiento estimadas (variación aleatoria)
        decay_hunger = DECAY_RATES['hunger'] * np.random.uniform(0.5, 1.5)
        decay_happiness = abs(DECAY_RATES['happiness']) * np.random.uniform(0.5, 1.5)
        decay_energy = abs(DECAY_RATES['energy']) * np.random.uniform(0.5, 1.5)
        decay_health = abs(DECAY_RATES['health']) * np.random.uniform(0.5, 1.5)

        # Tiempo desde última acción de cada tipo (normalizado a 24h)
        time_since_feed = np.random.uniform(0, 1)
        time_since_play = np.random.uniform(0, 1)
        time_since_rest = np.random.uniform(0, 1)
        time_since_clean = np.random.uniform(0, 1)

        # Patrones de usuario
        proactive_ratio = np.random.uniform(0, 1)
        reactive_ratio = 1 - proactive_ratio
        interaction_frequency = np.random.uniform(0, 1)
        consistency_score = np.random.uniform(0, 1)

        # Actividad general del usuario
        user_activity = (proactive_ratio + interaction_frequency + consistency_score) / 3

        # Contexto temporal
        time_of_day = np.random.uniform(0, 1)
        day_of_week = np.random.uniform(0, 1)
        hours_since_last = np.random.uniform(0, 1)
        is_active_time = 1.0 if np.random.random() > 0.3 else 0.0

        # Construir features
        features = [
            # Métricas actuales (4)
            hunger / 100,
            happiness / 100,
            energy / 100,
            health / 100,

            # Tasas de decaimiento (4) - normalizadas
            decay_hunger / 0.2,
            decay_happiness / 0.1,
            decay_energy / 0.1,
            decay_health / 0.05,

            # Tiempo desde última acción (4)
            time_since_feed,
            time_since_play,
            time_since_rest,
            time_since_clean,

            # Patrones de usuario (4)
            proactive_ratio,
            reactive_ratio,
            interaction_frequency,
            consistency_score,

            # Contexto temporal (4)
            time_of_day,
            day_of_week,
            hours_since_last,
            is_active_time,
        ]

        # Calcular tiempos hasta crítico (targets)
        minutes_to_hunger = calculate_time_to_critical(
            'hunger', hunger, decay_hunger, user_activity
        )
        minutes_to_happiness = calculate_time_to_critical(
            'happiness', happiness, decay_happiness, user_activity
        )
        minutes_to_energy = calculate_time_to_critical(
            'energy', energy, decay_energy, user_activity
        )
        minutes_to_health = calculate_time_to_critical(
            'health', health, decay_health, user_activity
        )

        # Agregar ruido a los targets para robustez
        noise = np.random.normal(0, 5, 4)
        targets = np.clip([
            minutes_to_hunger + noise[0],
            minutes_to_happiness + noise[1],
            minutes_to_energy + noise[2],
            minutes_to_health + noise[3],
        ], 0, 180)

        X.append(features)
        y.append(targets)

    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)


def convert_to_tflite(model, output_path: str, quantize: bool = True):
    """Convierte el modelo Keras a TensorFlow Lite."""
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    if quantize:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]

    tflite_model = converter.convert()

    with open(output_path, 'wb') as f:
        f.write(tflite_model)

    size_kb = len(tflite_model) / 1024
    print(f"Modelo guardado en: {output_path}")
    print(f"   Tamaño: {size_kb:.2f} KB")


def evaluate_model(model, X_test, y_test):
    """Evalúa el modelo y muestra métricas."""
    loss, mae = model.evaluate(X_test, y_test, verbose=0)
    print(f"\nMétricas de evaluación:")
    print(f"   MSE Loss: {loss:.4f}")
    print(f"   MAE: {mae:.4f} minutos")

    # Predicciones para análisis
    predictions = model.predict(X_test, verbose=0)

    print(f"\nEstadísticas por métrica:")
    for i, metric in enumerate(METRICS):
        pred_mean = np.mean(predictions[:, i])
        pred_std = np.std(predictions[:, i])
        true_mean = np.mean(y_test[:, i])
        true_std = np.std(y_test[:, i])

        error = np.mean(np.abs(predictions[:, i] - y_test[:, i]))
        print(f"   {metric}:")
        print(f"      Predicho: {pred_mean:.1f} ± {pred_std:.1f} min")
        print(f"      Real:     {true_mean:.1f} ± {true_std:.1f} min")
        print(f"      MAE:      {error:.1f} min")


def main():
    parser = argparse.ArgumentParser(
        description='Entrenar modelo CriticalTimePredictor para Tamagotchi'
    )
    parser.add_argument(
        '--epochs', '-e',
        type=int,
        default=50,
        help='Número de epochs de entrenamiento (default: 50)'
    )
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='../assets/models/critical_time.tflite',
        help='Ruta de salida para el modelo TFLite'
    )
    parser.add_argument(
        '--samples', '-s',
        type=int,
        default=3000,
        help='Número de muestras sintéticas (default: 3000)'
    )
    parser.add_argument(
        '--no-quantize',
        action='store_true',
        help='No aplicar cuantización al modelo'
    )

    args = parser.parse_args()

    if not TF_AVAILABLE:
        print("TensorFlow es requerido para entrenar el modelo")
        return 1

    print("Entrenamiento de CriticalTimePredictor para Tamagotchi")
    print("=" * 55)

    # Generar datos
    print(f"\nGenerando {args.samples} muestras sintéticas...")
    X, y = generate_synthetic_data(args.samples)
    print(f"   Total de muestras: {len(X)}")

    # Dividir en train/test
    split_idx = int(len(X) * 0.8)
    X_train, X_test = X[:split_idx], X[split_idx:]
    y_train, y_test = y[:split_idx], y[split_idx:]

    print(f"   Train: {len(X_train)}, Test: {len(X_test)}")

    # Crear y entrenar modelo
    print(f"\nCreando modelo...")
    model = create_model()
    model.summary()

    print(f"\nEntrenando por {args.epochs} epochs...")
    history = model.fit(
        X_train, y_train,
        epochs=args.epochs,
        batch_size=32,
        validation_split=0.2,
        verbose=1
    )

    # Evaluar
    evaluate_model(model, X_test, y_test)

    # Convertir a TFLite
    print(f"\nConvirtiendo a TensorFlow Lite...")
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    convert_to_tflite(model, str(output_path), quantize=not args.no_quantize)

    print("\n¡Entrenamiento completado!")
    return 0


if __name__ == '__main__':
    exit(main())
