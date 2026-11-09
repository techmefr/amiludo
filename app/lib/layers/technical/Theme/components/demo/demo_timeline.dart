import 'package:flutter/animation.dart';

abstract final class DemoTimeline {
  static const Duration loop = Duration(milliseconds: 9000);
  static const double _span = 9000;
  static const double slotLength = 2000;
  static const double slotWork = 1700;
  static const double staticFrame = 8300 / _span;

  static double slot(double t, int index) {
    final from = index * slotLength + 100;
    return ((t * _span - from) / slotWork).clamp(0.0, 1.0);
  }

  static double cycleFade(double t) {
    final enter = (t * _span / 300).clamp(0.0, 1.0);
    final leave = ((_span - t * _span) / 400).clamp(0.0, 1.0);
    return Curves.easeOut.transform(enter < leave ? enter : leave);
  }
}
