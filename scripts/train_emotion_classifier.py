#!/usr/bin/env python3
"""
Script para entrenar el modelo EmotionClassifier para Tamagotchi.

Este modelo clasifica el estado emocional óptimo del pet basándose
en las métricas actuales, historial emocional y contexto.

Arquitectura:
    Input(16) → Dense(24, ReLU) → Dense(16, ReLU) → Dense(8, Softmax)

Features de entrada (16):
    0-3: Métricas del pet (hunger, happiness, energy, health)
    4-11: Historial emocional (últimos 8 estados, sliding window)
    12: Duración de sesión normalizada
    13: Interacciones en esta sesión
    14: Hora del día normalizada
    15: Nivel de vínculo

Salidas (8 probabilidades):
    0: Extasiado (muy feliz, >90 happiness)
    1: Feliz (70-90 happiness)
    2: Contento (50-70 happiness)
    3: Neutral (40-50 happiness)
    4: Aburrido (30-40 happiness, baja energía)
    5: Triste (20-30 happiness)
    6: Solo (bajo vínculo, poca interacción)
    7: Ansioso (baja salud o métricas críticas)

Uso:
    python train_emotion_classifier.py [--epochs N] [--output PATH]
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


INPUT_SIZE = 16
OUTPUT_SIZE = 8
EMOTIONS = ['ecstatic', 'happy', 'content', 'neutral', 'bored', 'sad', 'lonely', 'anxious']


def create_model():
    """Crea la arquitectura del modelo EmotionClassifier."""
    model = keras.Sequential([
        layers.Input(shape=(INPUT_SIZE,), name='input'),
        layers.Dense(24, activation='relu', name='dense_1'),
        layers.Dense(16, activation='relu', name='dense_2'),
        layers.Dense(OUTPUT_SIZE, activation='softmax', name='output')
    ])

    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    return model


def determine_emotion(hunger, happiness, energy, health, bond_level,
                      session_interactions) -> int:
    """
    Determina el estado emocional basado en métricas.
    Retorna índice de la emoción (0-7).
    """
    # Verificar estados críticos primero
    if health < 0.3 or hunger > 0.8:
        return 7  # anxious

    if bond_level < 0.2 and session_interactions < 0.1:
        return 6  # lonely

    if happiness < 0.2:
        return 5  # sad

    if happiness < 0.35 and energy < 0.3:
        return 4  # bored

    if happiness < 0.45:
        return 3  # neutral

    if happiness < 0.65:
        return 2  # content

    if happiness < 0.85:
        return 1  # happy

    return 0  # ecstatic


def generate_synthetic_data(n_samples: int = 3000) -> tuple:
    """Genera datos sintéticos para entrenamiento."""
    np.random.seed(42)

    X = []
    y = []

    for _ in range(n_samples):
        # Métricas del pet (0-1, valores invertidos para representar porcentaje)
        hunger = np.random.random()  # 0 = no hungry, 1 = very hungry
        happiness = np.random.random()  # 0 = sad, 1 = very happy
        energy = np.random.random()
        health = np.random.random()

        # Historial emocional (8 valores, cada uno representa un estado previo)
        # Los valores son normalizados entre 0-1 (representando happiness anterior)
        emotion_history = np.random.random(8)

        # Contexto de sesión
        session_duration = np.random.random()
        session_interactions = np.random.random()
        time_of_day = np.random.random()
        bond_level = np.random.random()

        features = [
            hunger, happiness, energy, health,
            *emotion_history,
            session_duration, session_interactions, time_of_day, bond_level,
        ]

        # Determinar emoción con algo de ruido
        base_emotion = determine_emotion(
            hunger, happiness, energy, health, bond_level, session_interactions
        )

        # Crear distribución de probabilidades con la emoción base como más probable
        probs = np.zeros(OUTPUT_SIZE)
        probs[base_emotion] = 0.6 + np.random.random() * 0.3

        # Distribuir el resto entre emociones cercanas
        remaining = 1.0 - probs[base_emotion]
        for i in range(OUTPUT_SIZE):
            if i != base_emotion:
                distance = abs(i - base_emotion)
                weight = 1.0 / (distance + 1)
                probs[i] = weight

        # Normalizar
        probs = probs / probs.sum()

        # One-hot encode basado en muestreo
        emotion_idx = np.random.choice(OUTPUT_SIZE, p=probs)
        one_hot = np.zeros(OUTPUT_SIZE)
        one_hot[emotion_idx] = 1

        X.append(features)
        y.append(one_hot)

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
    loss, accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"\nMétricas de evaluación:")
    print(f"   Loss: {loss:.4f}")
    print(f"   Accuracy: {accuracy:.4f}")

    predictions = model.predict(X_test, verbose=0)
    predicted_classes = np.argmax(predictions, axis=1)
    true_classes = np.argmax(y_test, axis=1)

    print(f"\nDistribución de predicciones:")
    for i, emotion in enumerate(EMOTIONS):
        pred_count = np.sum(predicted_classes == i)
        true_count = np.sum(true_classes == i)
        print(f"   {emotion}: {pred_count} predichas, {true_count} reales")


def main():
    parser = argparse.ArgumentParser(
        description='Entrenar modelo EmotionClassifier para Tamagotchi'
    )
    parser.add_argument('--epochs', '-e', type=int, default=50)
    parser.add_argument('--output', '-o', type=str,
                        default='../assets/models/emotion_classifier.tflite')
    parser.add_argument('--samples', '-s', type=int, default=3000)
    parser.add_argument('--no-quantize', action='store_true')

    args = parser.parse_args()

    if not TF_AVAILABLE:
        print("TensorFlow es requerido")
        return 1

    print("Entrenamiento de EmotionClassifier para Tamagotchi")
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
