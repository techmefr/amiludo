import 'package:flutter/services.dart';

abstract final class DeckHaptics {
  static bool enabled = true;

  static Future<void> selection() async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  static Future<void> impact() async {
    if (enabled) await HapticFeedback.lightImpact();
  }

  static Future<void> heavy() async {
    if (enabled) await HapticFeedback.heavyImpact();
  }

  static Future<void> knock() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.selectionClick();
  }

  static Future<void> ripple() async {
    if (!enabled) return;
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.selectionClick();
      await Future<void>.delayed(const Duration(milliseconds: 55));
    }
  }
}
