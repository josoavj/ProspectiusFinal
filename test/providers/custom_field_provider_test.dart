import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prospectius/providers/custom_field_provider.dart';
import 'package:prospectius/domain/repositories/i_custom_field_repository.dart';
import 'package:prospectius/models/custom_field.dart';

class MockCustomFieldRepository extends Mock implements ICustomFieldRepository {}

void main() {
  late CustomFieldProvider provider;
  late MockCustomFieldRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomFieldRepository();
    provider = CustomFieldProvider(repository: mockRepository);
  });

  group('CustomFieldProvider Tests', () {
    test('loadFields should update fields list', () async {
      final tFields = [CustomField(id: 1, name: 'Budget', type: CustomFieldType.number)];
      when(() => mockRepository.getCustomFields()).thenAnswer((_) async => tFields);

      await provider.loadFields();

      expect(provider.fields, tFields);
      expect(provider.isLoading, false);
    });

    test('saveValue should call repository and reload values', () async {
      when(() => mockRepository.saveCustomFieldValue(any(), any(), any())).thenAnswer((_) async {});
      when(() => mockRepository.getValuesByProspect(any())).thenAnswer((_) async => []);

      final result = await provider.saveValue(1, 1, '5000');

      expect(result, true);
      verify(() => mockRepository.saveCustomFieldValue(1, 1, '5000')).called(1);
    });
  });
}
