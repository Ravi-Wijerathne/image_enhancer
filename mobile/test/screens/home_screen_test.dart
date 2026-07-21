import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('Initial state displays tap to select', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('AI Enhancer'), findsOneWidget);
      expect(find.text('Tap to select an image'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });
  });
}
