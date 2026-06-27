import '../../domain/repositories/i_custom_field_repository.dart';
import '../../models/custom_field.dart';
import '../../services/mysql_service.dart';
import '../../core/constants/sql_queries.dart';

class CustomFieldRepositoryImpl implements ICustomFieldRepository {
  final MySQLService _mysqlService;

  CustomFieldRepositoryImpl(this._mysqlService);

  @override
  Future<List<CustomField>> getCustomFields() async {
    final results = await _mysqlService.query(SqlQueries.selectCustomFields);
    return results.map((row) => CustomField.fromJson(row)).toList();
  }

  @override
  Future<List<CustomFieldValue>> getValuesByProspect(int prospectId) async {
    final results = await _mysqlService.query(
      SqlQueries.selectValuesByProspectId,
      [prospectId],
    );
    return results.map((row) => CustomFieldValue.fromJson(row)).toList();
  }

  @override
  Future<void> saveCustomFieldValue(int prospectId, int fieldId, String value) async {
    await _mysqlService.query(
      SqlQueries.upsertCustomFieldValue,
      [prospectId, fieldId, value],
    );
  }

  @override
  Future<void> createCustomField(String name, CustomFieldType type) async {
    String typeStr;
    switch (type) {
      case CustomFieldType.number: typeStr = 'nombre'; break;
      case CustomFieldType.date: typeStr = 'date'; break;
      case CustomFieldType.boolean: typeStr = 'booleen'; break;
      default: typeStr = 'texte';
    }
    
    await _mysqlService.query(
      'INSERT INTO champs_personnalises (nom, type_donnee) VALUES (?, ?)',
      [name, typeStr],
    );
  }
}
