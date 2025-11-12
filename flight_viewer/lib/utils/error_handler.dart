import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> showRetryDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onRetry,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  static String formatErrorMessage(Object error) {
    String message = error.toString();
    
    // Handle common error types
    if (message.contains('Failed to fetch flights')) {
      return 'Unable to load flights. Please check your connection and try again.';
    }
    
    if (message.contains('Failed to load airlines')) {
      return 'Unable to load airlines. Please check your connection and try again.';
    }
    
    if (message.contains('Failed to fetch services')) {
      return 'Unable to load services. Please check your connection and try again.';
    }
    
    if (message.contains('Failed to create booking')) {
      return 'Unable to create booking. Please check your information and try again.';
    }
    
    if (message.contains('Login failed')) {
      return 'Login failed. Please check your credentials and try again.';
    }
    
    if (message.contains('Registration failed')) {
      return 'Registration failed. Please check your information and try again.';
    }
    
    if (message.contains('Failed to load bookings')) {
      return 'Unable to load bookings. Please check your connection and try again.';
    }
    
    // Handle network errors
    if (message.contains('SocketException') || message.contains('Connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }
    
    // Handle timeout errors
    if (message.contains('Timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Generic error message
    if (message.isNotEmpty) {
      return message;
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}