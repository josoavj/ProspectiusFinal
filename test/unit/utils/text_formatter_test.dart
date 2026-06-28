import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/utils/text_formatter.dart';

void main() {
  group('TextFormatter Tests', () {
    test('capitalize should handle single word', () {
      expect(TextFormatter.capitalize('hello'), 'Hello');
    });

    test('capitalize should handle multiple words', () {
      expect(TextFormatter.capitalize('hello world'), 'Hello World');
    });

    test('capitalize should handle empty string', () {
      expect(TextFormatter.capitalize(''), '');
    });

    test('formatDate should format correctly', () {
      final date = DateTime(2023, 10, 27);
      expect(TextFormatter.formatDate(date), '27/10/2023');
    });
  });
}
