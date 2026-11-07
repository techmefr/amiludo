import 'package:flutter/services.dart';

abstract final class DeckHaptics {
  static bool enabled = true;

  static Future<void> selection() async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  static Future<void> impact() async {
    if (enabled) await HapticFeedback.lightImpact();
  }
}
