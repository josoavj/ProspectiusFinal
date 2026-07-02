import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prospectius/providers/prospect_provider.dart';
import 'package:prospectius/domain/repositories/i_prospect_repository.dart';
import 'package:prospectius/models/prospect.dart';

class MockProspectRepository extends Mock implements IProspectRepository {}

void main() {
  late ProspectProvider prospectProvider;
  late MockProspectRepository mockRepository;

  setUp(() {
    mockRepository = MockProspectRepository();
    prospectProvider = ProspectProvider(repository: mockRepository);
  });

  group('ProspectProvider Tests', () {
    final tProspects = [
      Prospect(
        id: 1,
        nom: 'Doe',
        prenom: 'John',
        email: 'john@doe.com',
        telephone: '',
        adresse: '',
        type: 'particulier',
        status: 'nouveau',
        creation: DateTime.now(),
        dateUpdate: DateTime.now(),
        assignation: 1,
      )
    ];

    test('initial state should be empty and not loading', () {
      expect(prospectProvider.prospects, isEmpty);
      expect(prospectProvider.isLoading, false);
      expect(prospectProvider.error, isNull);
    });

    test('loadProspects should update prospects list on success', () async {
      // Arrange
      when(() => mockRepository.getProspects(any(), any(), limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => tProspects);

      // Act
      await prospectProvider.loadProspects(1, 'Utilisateur');

      // Assert
      expect(prospectProvider.prospects, equals(tProspects));
      expect(prospectProvider.isLoading, false);
      verify(() => mockRepository.getProspects(1, 'Utilisateur', limit: 20, offset: 0)).called(1);
    });

    test('loadProspects should set error on failure', () async {
      // Arrange
      when(() => mockRepository.getProspects(any(), any(), limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenThrow(Exception('Database error'));

      // Act
      await prospectProvider.loadProspects(1, 'Utilisateur');

      // Assert
      expect(prospectProvider.error, isNotNull);
      expect(prospectProvider.isLoading, false);
    });
  });
}
