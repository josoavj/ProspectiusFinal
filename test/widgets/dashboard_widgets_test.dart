import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prospectius/screens/dashboard/widgets/stats_widgets.dart';
import 'package:prospectius/models/stats.dart';

void main() {
  group('Dashboard Widgets Tests', () {
    testWidgets('ConversionCard should display stats correctly', (WidgetTester tester) async {
      final stats = ConversionStats(
        totalProspects: 100,
        convertedClients: 25,
        conversionRate: 0.25,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConversionCard(stats: stats),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
    });

    testWidgets('PerformanceMetric should display label and percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceMetric(
              label: 'Test Metric',
              value: 75.5,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Test Metric'), findsOneWidget);
      expect(find.text('75.5%'), findsOneWidget);
    });
  });
}
