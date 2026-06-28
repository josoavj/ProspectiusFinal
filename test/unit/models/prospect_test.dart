import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/models/prospect.dart';

void main() {
  group('Prospect Model Tests', () {
    test('should create a Prospect from JSON', () {
      final json = {
        'id_prospect': 1,
        'nomp': 'Doe',
        'prenomp': 'John',
        'email': 'john@doe.com',
        'telephone': '0123456789',
        'adresse': '123 Main St',
        'type': 'particulier',
        'status': 'nouveau',
        'creation': '2023-10-27T10:00:00.000',
        'date_update': '2023-10-27T10:00:00.000',
        'assignation': 1,
      };

      final prospect = Prospect.fromJson(json);

      expect(prospect.id, 1);
      expect(prospect.nom, 'Doe');
      expect(prospect.fullName, 'John Doe');
      expect(prospect.status, 'nouveau');
    });

    test('should convert Prospect to JSON', () {
      final prospect = Prospect(
        id: 1,
        nom: 'Doe',
        prenom: 'John',
        email: 'john@doe.com',
        telephone: '0123456789',
        adresse: '123 Main St',
        type: 'particulier',
        status: 'nouveau',
        creation: DateTime(2023, 10, 27),
        dateUpdate: DateTime(2023, 10, 27),
        assignation: 1,
      );

      final json = prospect.toJson();

      expect(json['id_prospect'], 1);
      expect(json['nomp'], 'Doe');
      expect(json['status'], 'nouveau');
    });
  });
}
