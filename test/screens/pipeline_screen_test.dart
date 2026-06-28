import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:prospectius/screens/pipeline_screen.dart';
import 'package:prospectius/providers/prospect_provider.dart';
import 'package:prospectius/providers/auth_provider.dart';
import 'package:prospectius/models/prospect.dart';
import 'package:prospectius/models/account.dart';

class MockProspectProvider extends Mock implements ProspectProvider {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockProspectProvider mockProspectProvider;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockProspectProvider = MockProspectProvider();
    mockAuthProvider = MockAuthProvider();
    
    when(() => mockAuthProvider.currentUser).thenReturn(
      Account(id: 1, nom: 'Admin', prenom: 'User', email: 'a@b.com', username: 'admin', typeCompte: 'Administrateur', dateCreation: DateTime.now())
    );
    when(() => mockProspectProvider.isLoading).thenReturn(false);
    when(() => mockProspectProvider.error).thenReturn(null);
    when(() => mockProspectProvider.prospects).thenReturn([]);
    when(() => mockProspectProvider.loadProspects(any())).thenAnswer((_) async {});
  });

  testWidgets('PipelineScreen should show empty columns initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProspectProvider>.value(value: mockProspectProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: const MaterialApp(home: PipelineScreen()),
      ),
    );

    expect(find.text('NOUVEAU'), findsOneWidget);
    expect(find.text('INTERESSE'), findsOneWidget);
    expect(find.text('NEGOCIATION'), findsOneWidget);
  });

  testWidgets('PipelineScreen should show prospect cards', (WidgetTester tester) async {
    final prospect = Prospect(
      id: 1, nom: 'Doe', prenom: 'John', email: '', telephone: '', adresse: '', 
      type: 'particulier', status: 'nouveau', creation: DateTime.now(), dateUpdate: DateTime.now(), assignation: 1
    );

    when(() => mockProspectProvider.prospects).thenReturn([prospect]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProspectProvider>.value(value: mockProspectProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ],
        child: const MaterialApp(home: PipelineScreen()),
      ),
    );

    expect(find.text('John Doe'), findsOneWidget);
  });
}
