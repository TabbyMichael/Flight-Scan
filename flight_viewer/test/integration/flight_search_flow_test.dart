import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flight_viewer/main.dart';
import 'package:flight_viewer/providers/flight_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flight Search Flow', () {
    testWidgets('App launches and displays main screen', 
      (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify the main screen is displayed
      expect(find.text('SkyScan'), findsOneWidget);
      expect(find.text('Find and manage your flights'), findsOneWidget);
    });

    testWidgets('Search form is displayed', 
      (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify search form elements are present
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Departure'), findsOneWidget);
    });
  });
}