enum CustomFieldType { text, number, date, boolean }

class CustomField {
  final int id;
  final String name;
  final CustomFieldType type;

  CustomField({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id_champ'] as int,
      name: json['nom'] as String? ?? '',
      type: _parseType(json['type_donnee'] as String? ?? 'texte'),
    );
  }

  static CustomFieldType _parseType(String type) {
    switch (type) {
      case 'nombre':
        return CustomFieldType.number;
      case 'date':
        return CustomFieldType.date;
      case 'booleen':
        return CustomFieldType.boolean;
      default:
        return CustomFieldType.text;
    }
  }

  String get typeString {
    switch (type) {
      case CustomFieldType.number:
        return 'nombre';
      case CustomFieldType.date:
        return 'date';
      case CustomFieldType.boolean:
        return 'booleen';
      default:
        return 'texte';
    }
  }
}

class CustomFieldValue {
  final int idProspect;
  final int idField;
  final String value;
  final String? fieldName; // Joined for convenience

  CustomFieldValue({
    required this.idProspect,
    required this.idField,
    required this.value,
    this.fieldName,
  });

  factory CustomFieldValue.fromJson(Map<String, dynamic> json) {
    return CustomFieldValue(
      idProspect: json['id_prospect'] as int,
      idField: json['id_champ'] as int,
      value: json['valeur'] as String? ?? '',
      fieldName: json['nom_champ'] as String?,
    );
  }
}
