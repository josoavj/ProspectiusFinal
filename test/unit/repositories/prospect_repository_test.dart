import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prospectius/data/repositories/prospect_repository_impl.dart';
import 'package:prospectius/models/prospect.dart';
import 'package:prospectius/services/mysql_service.dart';
import 'package:mysql1/mysql1.dart';

class MockMySQLService extends Mock implements MySQLService {}
class MockResults extends Mock implements Results {}
class MockResultRow extends Mock implements ResultRow {}

void main() {
  late ProspectRepositoryImpl repository;
  late MockMySQLService mockMySQL;

  setUp(() {
    mockMySQL = MockMySQLService();
    repository = ProspectRepositoryImpl(mockMySQL);
  });

  group('ProspectRepository Tests', () {
    test('getProspects should return list from database', () async {
      final mockRow = MockResultRow();
      final mockResults = MockResults();
      
      final rowData = {
        'id_prospect': 1,
        'nomp': 'Doe',
        'prenomp': 'John',
        'email': 'john@doe.com',
        'telephone': '123',
        'adresse': 'St',
        'type': 'particulier',
        'status': 'nouveau',
        'creation': DateTime.now().toIso8601String(),
        'date_update': DateTime.now().toIso8601String(),
        'assignation': 1,
      };

      when(() => mockRow.fields).thenReturn(rowData);
      when(() => mockRow[any()]).thenAnswer((inv) => rowData[inv.positionalArguments[0]]);
      
      // Stubbing map since Results is an Iterable
      when(() => mockResults.map<Prospect>(any())).thenAnswer((invocation) {
        final fn = invocation.positionalArguments[0] as Prospect Function(ResultRow);
        return [fn(mockRow)];
      });

      when(() => mockMySQL.query(any(), any())).thenAnswer((_) async => mockResults);

      final result = await repository.getProspects(1, 'Utilisateur');

      expect(result.length, 1);
      expect(result.first.nom, 'Doe');
    });
  });
}
