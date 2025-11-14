import 'package:flutter/material.dart';
import '../screens/loading_screen.dart';

class NavigationUtils {
  static Future<void> navigateWithDelay({
    required BuildContext context,
    required Widget page,
    String message = 'Loading...',
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    // Navigate to loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(message: message),
      ),
    );

    // Wait for the delay
    await Future.delayed(delay);

    // Navigate to the target page
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  static Future<void> navigateAndReplaceWithDelay({
    required BuildContext context,
    required Widget page,
    String message = 'Loading...',
    Duration delay = const Duration(milliseconds: 1500),
  }) async {
    // Navigate to loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(message: message),
      ),
    );

    // Wait for the delay
    await Future.delayed(delay);

    // Navigate and remove all previous routes
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => page),
        (route) => false,
      );
    }
  }
}
