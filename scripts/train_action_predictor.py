#!/usr/bin/env python3
"""
Script para entrenar el modelo ActionPredictor para Tamagotchi.

Este modelo predice la próxima acción que el usuario probablemente realizará
basándose en el estado actual de la mascota y patrones de comportamiento.

Arquitectura:
    Input(15) → Dense(32, ReLU) → Dropout(0.2) → Dense(16, ReLU) → Dense(6, Softmax)

Features de entrada (15):
    0: hunger (0-1)
    1: happiness (0-1)
    2: energy (0-1)
    3: health (0-1)
    4: emotional_state (0-1)
    5: bond_level (0-1)
    6: proactive_ratio (0-1)
    7: time_of_day (0-1)
    8: day_of_week (0-1)
    9: minutes_since_last_interaction (0-1)
    10-14: one-hot encoding de última acción (feed, play, clean, rest, minigame)

Salidas (6 probabilidades):
    0: feed
    1: play
    2: clean
    3: rest
    4: minigame
    5: other

Uso:
    python train_action_predictor.py [--data PATH] [--epochs N] [--output PATH]

Ejemplo:
    python train_action_predictor.py --data ml_training_data.json --epochs 100
"""

import argparse
import json
import numpy as np
import os
from pathlib import Path

# Verificar disponibilidad de TensorFlow
try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False
    print("⚠️  TensorFlow no está instalado. Instálalo con: pip install tensorflow")


# Constantes del modelo
INPUT_SIZE = 15
OUTPUT_SIZE = 6
ACTIONS = ['feed', 'play', 'clean', 'rest', 'minigame', 'other']


def create_model():
    """Crea la arquitectura del modelo ActionPredictor."""
    model = keras.Sequential([
        layers.Input(shape=(INPUT_SIZE,), name='input'),
        layers.Dense(32, activation='relu', name='dense_1'),
        layers.Dropout(0.2, name='dropout'),
        layers.Dense(16, activation='relu', name='dense_2'),
        layers.Dense(OUTPUT_SIZE, activation='softmax', name='output')
    ])

    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    return model


def load_training_data(data_path: str) -> tuple:
    """
    Carga datos de entrenamiento desde archivo JSON exportado por la app.

    Returns:
        tuple: (X_train, y_train) arrays de numpy
    """
    with open(data_path, 'r') as f:
        data = json.load(f)

    records = data.get('records', [])
    if not records:
        raise ValueError("No se encontraron registros en el archivo de datos")

    X = []
    y = []

    action_to_idx = {action: idx for idx, action in enumerate(ACTIONS)}

    for record in records:
        features = record.get('features', [])
        action = record.get('action_taken', 'other')

        if len(features) != INPUT_SIZE:
            print(f"⚠️  Registro ignorado: features tiene {len(features)} elementos, se esperaban {INPUT_SIZE}")
            continue

        X.append(features)

        # One-hot encoding de la acción
        action_idx = action_to_idx.get(action, 5)  # 5 = 'other'
        y_one_hot = [0] * OUTPUT_SIZE
        y_one_hot[action_idx] = 1
        y.append(y_one_hot)

    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)


def generate_synthetic_data(n_samples: int = 1000) -> tuple:
    """
    Genera datos sintéticos para entrenamiento inicial.

    Los datos siguen reglas heurísticas simples:
    - Si hunger > 0.7 → probablemente feed
    - Si happiness < 0.4 → probablemente play
    - Si energy < 0.3 → probablemente rest
    - Si health < 0.4 → probablemente clean

    Returns:
        tuple: (X, y) arrays de numpy
    """
    np.random.seed(42)

    X = []
    y = []

    for _ in range(n_samples):
        # Generar features aleatorios
        hunger = np.random.random()
        happiness = np.random.random()
        energy = np.random.random()
        health = np.random.random()
        emotional_state = np.random.random()
        bond_level = np.random.random()
        proactive_ratio = np.random.random()
        time_of_day = np.random.random()
        day_of_week = np.random.random()
        minutes_since_last = np.random.random()

        # One-hot de última acción (aleatorio)
        last_action = [0] * 5
        if np.random.random() > 0.3:  # 70% tiene última acción
            last_action[np.random.randint(0, 5)] = 1

        features = [
            hunger, happiness, energy, health,
            emotional_state, bond_level, proactive_ratio,
            time_of_day, day_of_week, minutes_since_last
        ] + last_action

        # Determinar acción basada en reglas heurísticas
        # con algo de ruido para hacer el modelo más robusto
        action_probs = np.zeros(OUTPUT_SIZE)

        # Reglas principales
        if hunger > 0.7:
            action_probs[0] += 3.0  # feed
        if happiness < 0.4:
            action_probs[1] += 2.5  # play
        if energy < 0.3:
            action_probs[3] += 2.0  # rest
        if health < 0.4:
            action_probs[2] += 2.5  # clean

        # Reglas secundarias
        if happiness > 0.7 and energy > 0.5:
            action_probs[4] += 1.5  # minigame

        # Base probability para todas las acciones
        action_probs += 0.5

        # Añadir ruido
        action_probs += np.random.random(OUTPUT_SIZE) * 0.3

        # Normalizar a probabilidades
        action_probs = action_probs / action_probs.sum()

        # Seleccionar acción (muestreo de la distribución)
        action_idx = np.random.choice(OUTPUT_SIZE, p=action_probs)

        # One-hot encoding
        y_one_hot = [0] * OUTPUT_SIZE
        y_one_hot[action_idx] = 1

        X.append(features)
        y.append(y_one_hot)

    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)


def convert_to_tflite(model, output_path: str, quantize: bool = True):
    """
    Convierte el modelo Keras a TensorFlow Lite.

    Args:
        model: Modelo Keras entrenado
        output_path: Ruta de salida para el archivo .tflite
        quantize: Si True, aplica cuantización INT8
    """
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    if quantize:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        # Para cuantización completa INT8, necesitaríamos datos representativos
        # converter.target_spec.supported_types = [tf.int8]

    tflite_model = converter.convert()

    with open(output_path, 'wb') as f:
        f.write(tflite_model)

    # Mostrar tamaño del modelo
    size_kb = len(tflite_model) / 1024
    print(f"✅ Modelo guardado en: {output_path}")
    print(f"   Tamaño: {size_kb:.2f} KB")


def evaluate_model(model, X_test, y_test):
    """Evalúa el modelo y muestra métricas."""
    loss, accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"\n📊 Métricas de evaluación:")
    print(f"   Loss: {loss:.4f}")
    print(f"   Accuracy: {accuracy:.4f}")

    # Predicciones para análisis
    predictions = model.predict(X_test, verbose=0)
    predicted_classes = np.argmax(predictions, axis=1)
    true_classes = np.argmax(y_test, axis=1)

    # Matriz de confusión simplificada
    print(f"\n📈 Distribución de predicciones:")
    for i, action in enumerate(ACTIONS):
        pred_count = np.sum(predicted_classes == i)
        true_count = np.sum(true_classes == i)
        print(f"   {action}: {pred_count} predichas, {true_count} reales")


def main():
    parser = argparse.ArgumentParser(
        description='Entrenar modelo ActionPredictor para Tamagotchi'
    )
    parser.add_argument(
        '--data', '-d',
        type=str,
        help='Ruta al archivo JSON con datos de entrenamiento'
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
        default='../assets/models/action_predictor.tflite',
        help='Ruta de salida para el modelo TFLite'
    )
    parser.add_argument(
        '--synthetic', '-s',
        type=int,
        default=0,
        help='Generar N muestras sintéticas (0 = usar datos reales)'
    )
    parser.add_argument(
        '--no-quantize',
        action='store_true',
        help='No aplicar cuantización al modelo'
    )

    args = parser.parse_args()

    if not TF_AVAILABLE:
        print("❌ TensorFlow es requerido para entrenar el modelo")
        print("   Instálalo con: pip install tensorflow")
        return 1

    print("🤖 Entrenamiento de ActionPredictor para Tamagotchi")
    print("=" * 50)

    # Cargar o generar datos
    if args.synthetic > 0:
        print(f"\n📦 Generando {args.synthetic} muestras sintéticas...")
        X, y = generate_synthetic_data(args.synthetic)
    elif args.data:
        print(f"\n📦 Cargando datos desde: {args.data}")
        X, y = load_training_data(args.data)
    else:
        print("\n📦 Generando 2000 muestras sintéticas (default)...")
        X, y = generate_synthetic_data(2000)

    print(f"   Total de muestras: {len(X)}")

    # Dividir en train/test
    split_idx = int(len(X) * 0.8)
    X_train, X_test = X[:split_idx], X[split_idx:]
    y_train, y_test = y[:split_idx], y[split_idx:]

    print(f"   Train: {len(X_train)}, Test: {len(X_test)}")

    # Crear y entrenar modelo
    print(f"\n🏗️  Creando modelo...")
    model = create_model()
    model.summary()

    print(f"\n🚀 Entrenando por {args.epochs} epochs...")
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
    print(f"\n📱 Convirtiendo a TensorFlow Lite...")
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    convert_to_tflite(model, str(output_path), quantize=not args.no_quantize)

    print("\n✨ ¡Entrenamiento completado!")
    return 0


if __name__ == '__main__':
    exit(main())
