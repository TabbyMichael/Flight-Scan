import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('initial theme mode is system', () {
      // Initially it might be system, but we can't easily test the async load
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('toggleTheme switches between light and dark mode', () {
      // Start with dark mode
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Toggle to light mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Toggle back to dark mode
      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    test('themeIcon returns correct icon based on theme', () {
      // Dark mode should return light_mode icon (sun)
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeIcon, Icons.light_mode);
      
      // Light mode should return dark_mode icon (moon)
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeIcon, Icons.dark_mode);
    });

    test('isDarkMode returns correct boolean', () {
      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.isDarkMode, true);
      
      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.isDarkMode, false);
    });
  });
}