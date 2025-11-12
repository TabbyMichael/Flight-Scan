import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flight_viewer/providers/theme_provider.dart';
import 'package:flight_viewer/screens/main_tab_screen.dart';

void main() {
  testWidgets('Theme toggle switches between light and dark mode', 
    (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: MainTabScreen(),
        ),
      ),
    );

    // Find and tap the theme toggle button
    final themeButton = find.byIcon(Icons.dark_mode);
    expect(themeButton, findsOneWidget);
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    // Verify the icon changed to light_mode (sun icon)
    final lightThemeButton = find.byIcon(Icons.light_mode);
    expect(lightThemeButton, findsOneWidget);
  });
}