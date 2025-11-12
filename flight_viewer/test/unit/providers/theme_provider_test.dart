import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      // Initialize the binding
      TestWidgetsFlutterBinding.ensureInitialized();
      // Mock shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('initial theme mode is system', () {
      themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('toggleTheme switches between light and dark mode', () async {
      themeProvider = ThemeProvider();
      // Initially should be system mode
      expect(themeProvider.themeMode, ThemeMode.system);
      
      // Toggle to dark mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Toggle to light mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Toggle back to dark mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('setThemeMode updates theme mode correctly', () async {
      themeProvider = ThemeProvider();
      // Set to light mode
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Set to dark mode
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Set to system mode
      await themeProvider.setThemeMode(ThemeMode.system);
      expect(themeProvider.themeMode, ThemeMode.system);
    });
  });
}