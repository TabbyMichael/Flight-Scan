import 'package:flutter/services.dart';

class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  
  factory HapticsService() => _instance;
  
  HapticsService._internal();

  /// Trigger a light impact haptic feedback (iOS-style)
  Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback is not available on all devices
      print('Haptic feedback not available: $e');
    }
  }

  /// Trigger a medium impact haptic feedback (iOS-style)
  Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback is not available on all devices
      print('Haptic feedback not available: $e');
    }
  }

  /// Trigger a heavy impact haptic feedback (iOS-style)
  Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic feedback is not available on all devices
      print('Haptic feedback not available: $e');
    }
  }

  /// Trigger a selection haptic feedback (iOS-style)
  Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Haptic feedback is not available on all devices
      print('Haptic feedback not available: $e');
    }
  }

  /// Trigger a success notification haptic feedback (iOS-style)
  Future<void> success() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Haptic feedback is not available on all devices
      print('Haptic feedback not available: $e');
    }
  }

  /// Trigger an error notification haptic feedback (iOS-style)
  Future<void> error() async {
    try {
      // Vibrate twice for error feedback
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.vibrate();
    } catch (e) {
      // Haptic feedback is not available on all devices
      print('Haptic feedback not available: $e');
    }
  }
}