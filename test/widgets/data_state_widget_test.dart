import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/widgets/data_state_widget.dart';

void main() {
  group('SimpleStateBuilder Widget Tests', () {
    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleStateBuilder(
              isLoading: true,
              error: null,
              child: Text('Success'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Chargement en cours...'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets('should show error message when error is not null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleStateBuilder(
              isLoading: false,
              error: 'Test Error',
              child: Text('Success'),
            ),
          ),
        ),
      );

      expect(find.text('Une erreur s\'est produite'), findsOneWidget);
      expect(find.text('Test Error'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets('should show child when not loading and no error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleStateBuilder(
              isLoading: false,
              error: null,
              child: Text('Success'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
