#!/usr/bin/env python3
"""
Script para entrenar el modelo ActionRecommender para Tamagotchi.

Este modelo genera recomendaciones personalizadas de acciones basándose
en el estado del pet, personalidad, historial y patrones del usuario.

Arquitectura:
    Input(25) → Dense(48, ReLU) → Dropout(0.2) → Dense(24, ReLU) → Dense(7, Linear)

Features de entrada (25):
    0-3: Métricas del pet (hunger, happiness, energy, health)
    4: Estado emocional (0-1)
    5: Nivel de vínculo (0-1)
    6-7: Patrones de interacción (proactive, reactive ratio)
    8: Frecuencia de interacciones
    9-10: Contexto temporal (hour, weekday)
    11-22: 12 traits de personalidad normalizados
    23: Tasa de seguimiento de sugerencias
    24: Tiempo desde última sugerencia

Salidas (7 valores):
    0-5: Scores de recomendación para cada acción (feed, play, clean, rest, minigame, other)
    6: Score de urgencia general (0-1)

Uso:
    python train_action_recommender.py [--epochs N] [--output PATH]
"""

import argparse
import numpy as np
from pathlib import Path

try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False
    print("TensorFlow no está instalado.")


INPUT_SIZE = 25
OUTPUT_SIZE = 7
ACTIONS = ['feed', 'play', 'clean', 'rest', 'minigame', 'other']


def create_model():
    """Crea la arquitectura del modelo ActionRecommender."""
    model = keras.Sequential([
        layers.Input(shape=(INPUT_SIZE,), name='input'),
        layers.Dense(48, activation='relu', name='dense_1'),
        layers.Dropout(0.2, name='dropout'),
        layers.Dense(24, activation='relu', name='dense_2'),
        layers.Dense(OUTPUT_SIZE, activation='sigmoid', name='output')
    ])

    model.compile(
        optimizer='adam',
        loss='mse',
        metrics=['mae']
    )

    return model


def generate_synthetic_data(n_samples: int = 3000) -> tuple:
    """Genera datos sintéticos para entrenamiento."""
    np.random.seed(42)

    X = []
    y = []

    for _ in range(n_samples):
        # Métricas del pet (0-1)
        hunger = np.random.random()
        happiness = np.random.random()
        energy = np.random.random()
        health = np.random.random()

        # Estado emocional y vínculo
        emotional_state = np.random.random()
        bond_level = np.random.random()

        # Patrones de interacción
        proactive_ratio = np.random.random()
        reactive_ratio = 1 - proactive_ratio
        interaction_frequency = np.random.random()

        # Contexto temporal
        time_of_day = np.random.random()
        day_of_week = np.random.random()

        # 12 traits de personalidad
        traits = np.random.random(12)

        # Métricas de sugerencias
        suggestion_follow_rate = np.random.random()
        time_since_suggestion = np.random.random()

        features = [
            hunger, happiness, energy, health,
            emotional_state, bond_level,
            proactive_ratio, reactive_ratio, interaction_frequency,
            time_of_day, day_of_week,
            *traits,
            suggestion_follow_rate, time_since_suggestion,
        ]

        # Calcular scores de recomendación basados en reglas
        scores = np.zeros(6)

        # Score de alimentar
        scores[0] = hunger * 0.7 + (1 - health) * 0.2 + traits[4] * 0.1  # foodie trait

        # Score de jugar
        scores[1] = (1 - happiness) * 0.5 + traits[0] * 0.3 + energy * 0.2  # playful trait

        # Score de limpiar
        scores[2] = (1 - health) * 0.6 + (1 - happiness) * 0.2 + 0.2

        # Score de descansar
        scores[3] = (1 - energy) * 0.7 + traits[3] * 0.2 + 0.1  # calm trait

        # Score de minigame
        scores[4] = happiness * 0.3 + energy * 0.3 + bond_level * 0.2 + traits[0] * 0.2

        # Score de other
        scores[5] = 0.2 + np.random.random() * 0.1

        # Normalizar scores a 0-1
        scores = np.clip(scores, 0, 1)

        # Calcular urgencia basada en métricas críticas
        urgency = 0.0
        if hunger > 0.7:
            urgency = max(urgency, (hunger - 0.7) / 0.3)
        if happiness < 0.3:
            urgency = max(urgency, (0.3 - happiness) / 0.3)
        if energy < 0.2:
            urgency = max(urgency, (0.2 - energy) / 0.2)
        if health < 0.3:
            urgency = max(urgency, (0.3 - health) / 0.3)

        urgency = np.clip(urgency + np.random.normal(0, 0.1), 0, 1)

        # Agregar ruido a los scores
        scores += np.random.normal(0, 0.05, 6)
        scores = np.clip(scores, 0, 1)

        targets = list(scores) + [urgency]

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
    """Evalúa el modelo."""
    loss, mae = model.evaluate(X_test, y_test, verbose=0)
    print(f"\nMétricas de evaluación:")
    print(f"   MSE Loss: {loss:.4f}")
    print(f"   MAE: {mae:.4f}")

    predictions = model.predict(X_test, verbose=0)

    print(f"\nEstadísticas por salida:")
    labels = ACTIONS + ['urgency']
    for i, label in enumerate(labels):
        pred_mean = np.mean(predictions[:, i])
        true_mean = np.mean(y_test[:, i])
        error = np.mean(np.abs(predictions[:, i] - y_test[:, i]))
        print(f"   {label}: pred={pred_mean:.3f}, real={true_mean:.3f}, MAE={error:.3f}")


def main():
    parser = argparse.ArgumentParser(
        description='Entrenar modelo ActionRecommender para Tamagotchi'
    )
    parser.add_argument('--epochs', '-e', type=int, default=50)
    parser.add_argument('--output', '-o', type=str,
                        default='../assets/models/action_recommender.tflite')
    parser.add_argument('--samples', '-s', type=int, default=3000)
    parser.add_argument('--no-quantize', action='store_true')

    args = parser.parse_args()

    if not TF_AVAILABLE:
        print("TensorFlow es requerido")
        return 1

    print("Entrenamiento de ActionRecommender para Tamagotchi")
    print("=" * 55)

    print(f"\nGenerando {args.samples} muestras sintéticas...")
    X, y = generate_synthetic_data(args.samples)
    print(f"   Total de muestras: {len(X)}")

    split_idx = int(len(X) * 0.8)
    X_train, X_test = X[:split_idx], X[split_idx:]
    y_train, y_test = y[:split_idx], y[split_idx:]
    print(f"   Train: {len(X_train)}, Test: {len(X_test)}")

    print(f"\nCreando modelo...")
    model = create_model()
    model.summary()

    print(f"\nEntrenando por {args.epochs} epochs...")
    model.fit(
        X_train, y_train,
        epochs=args.epochs,
        batch_size=32,
        validation_split=0.2,
        verbose=1
    )

    evaluate_model(model, X_test, y_test)

    print(f"\nConvirtiendo a TensorFlow Lite...")
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    convert_to_tflite(model, str(output_path), quantize=not args.no_quantize)

    print("\n¡Entrenamiento completado!")
    return 0


if __name__ == '__main__':
    exit(main())
