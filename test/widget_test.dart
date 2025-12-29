import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/main.dart';

void main() {
  testWidgets('Tamagotchi app loads successfully', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const TamagotchiApp());

    // Verify that the app bar title is present
    expect(find.text('Tamagotchi'), findsOneWidget);

    // Verify that the default pet name is displayed
    expect(find.text('Mi Tamagotchi'), findsOneWidget);

    // Verify that the Estado section is present
    expect(find.text('Estado'), findsOneWidget);
  });
}
