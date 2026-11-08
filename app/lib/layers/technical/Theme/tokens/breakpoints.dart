import 'package:flutter/widgets.dart';

enum WindowClass { compact, medium, expanded, large }

abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 1024;
  static const double large = 1600;

  static WindowClass classify(double width) {
    if (width >= large) return WindowClass.large;
    if (width >= expanded) return WindowClass.expanded;
    if (width >= medium) return WindowClass.medium;
    return WindowClass.compact;
  }

  static WindowClass of(BuildContext context) =>
      classify(MediaQuery.sizeOf(context).width);

  static bool atLeast(BuildContext context, WindowClass window) =>
      of(context).index >= window.index;

  static double contentWidth(WindowClass window) => switch (window) {
    WindowClass.compact => 640,
    WindowClass.medium => 760,
    WindowClass.expanded => 960,
    WindowClass.large => 1120,
  };

  static double pageWidth(WindowClass window) => switch (window) {
    WindowClass.large => 1480,
    _ => 1320,
  };

  static double textScale(BuildContext context) =>
      (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(1.0, 2.0);

  static int columns(double width, double minimum, {double gap = 16}) =>
      ((width + gap) / (minimum + gap)).floor().clamp(1, 12);
}
