import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/screens/auth/widgets/password_criteria_widget.dart';
import 'package:prospectius/screens/auth/widgets/password_match_indicator.dart';

void main() {
  group('Auth Widgets Tests', () {
    testWidgets('PasswordCriteriaWidget should display criteria correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordCriteriaWidget(
              hasMinLength: true,
              hasUppercase: false,
              hasLowercase: true,
              hasDigits: false,
            ),
          ),
        ),
      );

      expect(find.text('8 caractères minimum'), findsOneWidget);
      expect(find.text('Une majuscule (A-Z)'), findsOneWidget);
      
      // We can't easily check colors/icons here without more complex finders, 
      // but we verify the texts are present.
    });

    testWidgets('PasswordMatchIndicator should show nothing when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordMatchIndicator(
              passwordsMatch: false,
              isNotEmpty: false,
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsNothing);
    });

    testWidgets('PasswordMatchIndicator should show match message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordMatchIndicator(
              passwordsMatch: true,
              isNotEmpty: true,
            ),
          ),
        ),
      );

      expect(find.text('Les mots de passe correspondent'), findsOneWidget);
    });

    testWidgets('PasswordMatchIndicator should show mismatch message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordMatchIndicator(
              passwordsMatch: false,
              isNotEmpty: true,
            ),
          ),
        ),
      );

      expect(find.text('Les mots de passe sont différents'), findsOneWidget);
    });
  });
}
