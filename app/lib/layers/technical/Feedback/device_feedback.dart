import 'package:flutter/services.dart';

class DeviceFeedback {
  static Future<void> expired({
    required bool sound,
    required bool haptics,
  }) async {
    if (haptics) {
      await HapticFeedback.heavyImpact();
    }
    if (sound) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  static Future<void> tap({required bool sound, required bool haptics}) async {
    if (haptics) {
      await HapticFeedback.lightImpact();
    }
    if (sound) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> selection({required bool haptics}) async {
    if (haptics) {
      await HapticFeedback.selectionClick();
    }
  }
}
