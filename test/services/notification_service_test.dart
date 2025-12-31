import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService - Lógica de Mensajes Críticos', () {
    // Nota: Este grupo de pruebas valida la lógica de decisión para mensajes críticos
    // basada en el estado del Pet. Las pruebas del plugin de notificaciones en sí
    // requieren integración con la plataforma y se validan mejor a través de
    // pruebas de integración o pruebas manuales.

    group('Condiciones críticas del Pet', () {
      test('pet con salud < 30 es considerado crítico', () {
        final pet = Pet(
          name: 'TestPet',
          hunger: 20.0,
          happiness: 80.0,
          energy: 80.0,
          health: 25.0, // Crítico
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.health < 30, true);
        // El mensaje sería: 'TestPet está muy enfermo. ¡Necesita cuidados ahora!'
      });

      test('pet con hambre > 80 es considerado crítico', () {
        final pet = Pet(
          name: 'HungryPet',
          hunger: 85.0, // Crítico
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.hunger > 80, true);
        // El mensaje sería: 'HungryPet tiene mucha hambre. ¡Aliméntalo pronto!'
      });

      test('pet con energía < 20 es considerado crítico', () {
        final pet = Pet(
          name: 'TiredPet',
          hunger: 20.0,
          happiness: 80.0,
          energy: 15.0, // Crítico
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.energy < 20, true);
        // El mensaje sería: 'TiredPet está agotado. ¡Deja que descanse!'
      });

      test('pet con felicidad < 30 NO es crítico (es sad)', () {
        final pet = Pet(
          name: 'SadPet',
          hunger: 20.0,
          happiness: 25.0, // Bajo pero NO crítico
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.sad);
        expect(pet.happiness < 30, true);
        // El mensaje sería de tristeza, no crítico
      });

      test('pet saludable no es considerado crítico', () {
        final pet = Pet(
          name: 'HealthyPet',
          hunger: 20.0,
          happiness: 80.0,
          energy: 80.0,
          health: 90.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.happy);
        // No se enviaría notificación
      });
    });

    group('Múltiples condiciones críticas', () {
      test('múltiples métricas críticas hacen al pet crítico', () {
        final pet = Pet(
          name: 'MultiCritical',
          hunger: 85.0, // Crítico
          happiness: 25.0, // Sad pero no crítico por sí solo
          energy: 15.0, // Crítico
          health: 25.0, // Crítico
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.health < 30, true);
        expect(pet.hunger > 80, true);
        expect(pet.energy < 20, true);
        // NotificationService debería priorizar el mensaje más urgente
      });

      test('hambre crítica con baja felicidad', () {
        final pet = Pet(
          name: 'HungryAndSad',
          hunger: 85.0, // Crítico
          happiness: 25.0, // Sad pero no crítico
          energy: 50.0, // OK
          health: 80.0, // OK
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.hunger > 80, true);
        expect(pet.health >= 30, true);
        expect(pet.energy >= 20, true);
        // El mensaje debería ser de hambre crítica
      });

      test('energía crítica con baja felicidad', () {
        final pet = Pet(
          name: 'TiredAndSad',
          hunger: 20.0, // OK
          happiness: 25.0, // Sad pero no crítico
          energy: 15.0, // Crítico
          health: 80.0, // OK
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.energy < 20, true);
        expect(pet.hunger <= 80, true);
        expect(pet.health >= 30, true);
        // El mensaje debería ser de energía crítica
      });

      test('solo felicidad baja NO es crítico', () {
        final pet = Pet(
          name: 'OnlySad',
          hunger: 20.0, // OK
          happiness: 25.0, // Sad
          energy: 80.0, // OK
          health: 80.0, // OK
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.sad);
        expect(pet.happiness < 30, true);
        expect(pet.hunger <= 80, true);
        expect(pet.energy >= 20, true);
        expect(pet.health >= 30, true);
        // Solo un mensaje de tristeza, no crítico
      });
    });

    group('Condiciones límite', () {
      test('pet en el límite exacto no es crítico', () {
        final pet = Pet(
          name: 'EdgePet',
          hunger: 80.0, // Justo en el límite
          happiness: 30.0, // Justo en el límite
          energy: 20.0, // Justo en el límite
          health: 30.0, // Justo en el límite
        );

        expect(pet.isCritical, false);
        expect(pet.hunger <= 80, true);
        expect(pet.happiness >= 30, true);
        expect(pet.energy >= 20, true);
        expect(pet.health >= 30, true);
      });

      test('pet un punto por debajo del límite crítico de health', () {
        final pet = Pet(
          name: 'JustCritical',
          hunger: 20.0,
          happiness: 50.0,
          energy: 80.0,
          health: 29.0, // Un punto por debajo del límite
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.health < 30, true);
      });

      test('pet con todas las métricas perfectas', () {
        final pet = Pet(
          name: 'PerfectPet',
          hunger: 0.0,
          happiness: 100.0,
          energy: 100.0,
          health: 100.0,
        );

        expect(pet.isCritical, false);
      });

      test('pet con todas las métricas en estado crítico', () {
        final pet = Pet(
          name: 'WorstPet',
          hunger: 100.0,
          happiness: 0.0,
          energy: 0.0,
          health: 0.0,
        );

        expect(pet.isCritical, true);
        expect(pet.health < 30, true);
        expect(pet.hunger > 80, true);
        expect(pet.energy < 20, true);
        expect(pet.happiness < 30, true);
      });
    });

    group('Validación de nombres en mensajes', () {
      test('pet con nombre vacío cumple condiciones críticas', () {
        final pet = Pet(
          name: '',
          hunger: 85.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.name, '');
        // El mensaje incluiría el nombre vacío
      });

      test('pet con nombre muy largo cumple condiciones críticas', () {
        final longName = 'A' * 100;
        final pet = Pet(
          name: longName,
          hunger: 85.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.name.length, 100);
        // El mensaje incluiría el nombre largo
      });

      test('pet con caracteres especiales en el nombre', () {
        final pet = Pet(
          name: '🐾 Mascota-Especial_123!',
          hunger: 85.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.name, contains('🐾'));
        // El mensaje incluiría caracteres especiales
      });
    });

    group('Combinaciones de métricas críticas', () {
      test('hambre y energía críticas hacen al pet crítico', () {
        final pet = Pet(
          name: 'AlmostWorst',
          hunger: 85.0, // Crítico
          happiness: 25.0, // Sad, no crítico
          energy: 15.0, // Crítico
          health: 80.0, // OK
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.hunger > 80, true);
        expect(pet.energy < 20, true);
        expect(pet.health >= 30, true);
      });

      test('solo salud crítica es suficiente', () {
        final pet = Pet(
          name: 'SingleCritical',
          hunger: 20.0,
          happiness: 80.0,
          energy: 80.0,
          health: 25.0, // Solo esta es crítica
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.health < 30, true);
      });

      test('dos condiciones críticas: hambre y energía', () {
        final pet = Pet(
          name: 'DoubleCritical',
          hunger: 85.0, // Crítico
          happiness: 80.0,
          energy: 15.0, // Crítico
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.hunger > 80, true);
        expect(pet.energy < 20, true);
      });
    });

    group('Transiciones de estado', () {
      test('pet que pasa de crítico a normal en salud', () {
        final criticalPet = Pet(
          name: 'Recovering',
          hunger: 20.0,
          happiness: 80.0,
          energy: 80.0,
          health: 25.0,
        );

        expect(criticalPet.isCritical, true);

        final healthyPet = Pet(
          name: 'Recovering',
          hunger: 20.0,
          happiness: 80.0,
          energy: 80.0,
          health: 35.0,
        );

        expect(healthyPet.isCritical, false);
      });

      test('pet que pasa de crítico a normal en hambre', () {
        final hungryPet = Pet(
          name: 'GettingFed',
          hunger: 85.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(hungryPet.isCritical, true);

        final fedPet = Pet(
          name: 'GettingFed',
          hunger: 75.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(fedPet.isCritical, false);
      });

      test('pet que pasa de normal a crítico', () {
        final okPet = Pet(
          name: 'Declining',
          hunger: 75.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(okPet.isCritical, false);

        final criticalPet = Pet(
          name: 'Declining',
          hunger: 85.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(criticalPet.isCritical, true);
      });
    });

    group('Valores decimales', () {
      test('pet con valores decimales en límite crítico', () {
        final pet = Pet(
          name: 'Decimal',
          hunger: 80.5, // Apenas crítico
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.hunger > 80, true);
      });

      test('pet con valores decimales justo debajo del límite', () {
        final pet = Pet(
          name: 'Decimal',
          hunger: 79.9, // No crítico pero hungry (> 60)
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.hungry); // hunger > 60 = hungry
        expect(pet.hunger <= 80, true);
      });

      test('pet con energía en decimal crítico', () {
        final pet = Pet(
          name: 'Decimal',
          hunger: 20.0,
          happiness: 80.0,
          energy: 19.9, // Crítico
          health: 80.0,
        );

        expect(pet.isCritical, true);
        expect(pet.mood, PetMood.critical);
        expect(pet.energy < 20, true);
      });
    });

    group('Estados de ánimo no críticos', () {
      test('pet con hambre moderada (60 < hunger <= 80) está hungry', () {
        final pet = Pet(
          name: 'ModeratelyHungry',
          hunger: 70.0, // Hungry pero no crítico
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.hungry);
        expect(pet.hunger > 60, true);
        expect(pet.hunger <= 80, true);
      });

      test('pet con energía baja (20 <= energy < 40) está tired', () {
        final pet = Pet(
          name: 'Tired',
          hunger: 20.0,
          happiness: 80.0,
          energy: 30.0, // Tired pero no crítico
          health: 80.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.tired);
        expect(pet.energy < 40, true);
        expect(pet.energy >= 20, true);
      });

      test('pet con felicidad baja está sad', () {
        final pet = Pet(
          name: 'Sad',
          hunger: 20.0,
          happiness: 25.0, // Sad
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.sad);
        expect(pet.happiness < 30, true);
      });

      test('pet feliz tiene happiness > 70 y health > 70', () {
        final pet = Pet(
          name: 'Happy',
          hunger: 20.0,
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.happy);
        expect(pet.happiness > 70, true);
        expect(pet.health > 70, true);
      });

      test('pet neutral no cumple condiciones extremas', () {
        final pet = Pet(
          name: 'Neutral',
          hunger: 50.0,
          happiness: 50.0,
          energy: 50.0,
          health: 60.0,
        );

        expect(pet.isCritical, false);
        expect(pet.mood, PetMood.neutral);
      });
    });

    group('Prioridad de condiciones en mood', () {
      test('crítico tiene prioridad sobre sad', () {
        final pet = Pet(
          name: 'CriticalNotSad',
          hunger: 85.0, // Crítico
          happiness: 25.0, // También sad
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.mood, PetMood.critical);
        expect(pet.mood, isNot(PetMood.sad));
      });

      test('crítico tiene prioridad sobre hungry', () {
        final pet = Pet(
          name: 'CriticalNotHungry',
          hunger: 85.0, // Crítico (> 80)
          happiness: 80.0,
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.mood, PetMood.critical);
        expect(pet.mood, isNot(PetMood.hungry));
      });

      test('sad tiene prioridad sobre hungry', () {
        final pet = Pet(
          name: 'SadNotHungry',
          hunger: 70.0, // Hungry
          happiness: 25.0, // Sad
          energy: 80.0,
          health: 80.0,
        );

        expect(pet.mood, PetMood.sad);
        expect(pet.mood, isNot(PetMood.hungry));
      });

      test('hungry tiene prioridad sobre tired', () {
        final pet = Pet(
          name: 'HungryNotTired',
          hunger: 70.0, // Hungry
          happiness: 50.0,
          energy: 30.0, // Tired
          health: 80.0,
        );

        expect(pet.mood, PetMood.hungry);
        expect(pet.mood, isNot(PetMood.tired));
      });
    });
  });
}
