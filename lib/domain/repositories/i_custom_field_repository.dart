import '../../models/custom_field.dart';

abstract class ICustomFieldRepository {
  Future<List<CustomField>> getCustomFields();
  Future<List<CustomFieldValue>> getValuesByProspect(int prospectId);
  Future<void> saveCustomFieldValue(int prospectId, int fieldId, String value);
  Future<void> createCustomField(String name, CustomFieldType type);
}
