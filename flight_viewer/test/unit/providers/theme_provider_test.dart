import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeProvider', () {
    late ThemeProvider provider;
    
    setUp(() {
      // Mock shared preferences
      SharedPreferences.setMockInitialValues({});
    });
    
    test('initial theme mode is system', () async {
      provider = ThemeProvider();
      // Wait for async initialization
      await Future.delayed(Duration(milliseconds: 100));
      // Initially, theme mode should be system
      expect(provider.themeMode, ThemeMode.system);
    });
    
    test('toggleTheme switches between light and dark', () async {
      provider = ThemeProvider();
      // Wait for async initialization
      await Future.delayed(Duration(milliseconds: 100));
      
      // Initially system, toggle should switch to light or dark
      provider.toggleTheme();
      // Wait for async operation
      await Future.delayed(Duration(milliseconds: 100));
      final firstToggle = provider.themeMode;
      expect(firstToggle == ThemeMode.light || firstToggle == ThemeMode.dark, isTrue);
      
      // Toggle again should switch to the other mode
      provider.toggleTheme();
      // Wait for async operation
      await Future.delayed(Duration(milliseconds: 100));
      final secondToggle = provider.themeMode;
      expect(secondToggle == ThemeMode.light || secondToggle == ThemeMode.dark, isTrue);
      // Should be different from first toggle
      expect(secondToggle, isNot(equals(firstToggle)));
    });
    
    test('setThemeMode updates theme mode', () async {
      provider = ThemeProvider();
      // Wait for async initialization
      await Future.delayed(Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.light);
      // Wait for async operation
      await Future.delayed(Duration(milliseconds: 100));
      expect(provider.themeMode, ThemeMode.light);
      
      await provider.setThemeMode(ThemeMode.dark);
      // Wait for async operation
      await Future.delayed(Duration(milliseconds: 100));
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}