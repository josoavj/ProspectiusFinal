import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/services/cache_service.dart';
import 'package:prospectius/models/prospect.dart';

void main() {
  late CacheService cacheService;

  setUp(() {
    cacheService = CacheService();
    cacheService.clearAll();
  });

  group('CacheService Tests', () {
    test('should return null when cache is empty', () {
      final results = cacheService.getProspects(1);
      expect(results, isNull);
    });

    test('should store and retrieve prospects', () {
      final prospects = [
        Prospect(
          id: 1,
          nom: 'Test',
          prenom: 'User',
          email: '',
          telephone: '',
          adresse: '',
          type: 'particulier',
          status: 'nouveau',
          creation: DateTime.now(),
          dateUpdate: DateTime.now(),
          assignation: 1,
        )
      ];

      cacheService.setProspects(1, prospects);
      final results = cacheService.getProspects(1);

      expect(results, isNotNull);
      expect(results!.length, 1);
      expect(results[0].nom, 'Test');
    });

    test('should invalidate cache for specific user', () {
      cacheService.setProspects(1, []);
      cacheService.invalidate(1);
      expect(cacheService.getProspects(1), isNull);
    });
  });
}
