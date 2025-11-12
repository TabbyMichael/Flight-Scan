import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flight_viewer/providers/theme_provider.dart';
import 'package:flight_viewer/screens/main_tab_screen.dart';

void main() {
  testWidgets('Theme toggle button changes icon based on theme mode',
      (WidgetTester tester) async {
    // Build the main tab screen with theme provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MaterialApp(
          home: MainTabScreen(),
        ),
      ),
    );

    // Initially should show dark_mode icon (assuming system defaults to light)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsNothing);

    // Tap the theme toggle button
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // Should now show light_mode icon
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsNothing);

    // Tap the theme toggle button again
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // Should now show dark_mode icon again
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsNothing);
  });

  testWidgets('Theme toggle button exists in app bar',
      (WidgetTester tester) async {
    // Build the main tab screen with theme provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MaterialApp(
          home: MainTabScreen(),
        ),
      ),
    );

    // Verify that the theme toggle button exists in the app bar
    expect(find.byType(IconButton), findsWidgets);
  });
}