import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/screens/prospects/widgets/prospect_list_item.dart';
import 'package:prospectius/screens/prospects/widgets/status_chip.dart';
import 'package:prospectius/models/prospect.dart';

void main() {
  group('Prospect Widgets Tests', () {
    final prospect = Prospect(
      id: 1,
      nom: 'Doe',
      prenom: 'John',
      email: 'john@doe.com',
      telephone: '2613400000',
      adresse: 'Tana',
      type: 'particulier',
      status: 'converti',
      creation: DateTime.now(),
      dateUpdate: DateTime.now(),
      assignation: 1,
    );

    testWidgets('StatusChip should display formatted status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'converti'),
          ),
        ),
      );

      expect(find.text('Converti'), findsOneWidget);
    });

    testWidgets('ProspectListItem should display prospect info', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProspectListItem(
              prospect: prospect,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Doe John'), findsOneWidget);
      expect(find.text('john@doe.com'), findsOneWidget);
      expect(find.text('Converti'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
