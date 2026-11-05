import 'package:flutter/widgets.dart';

abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 48;
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double pill = 28;
}

abstract final class Elevation {
  static const double none = 0;
  static const double raised = 1;
  static const double overlay = 3;
}

abstract final class TypeScale {
  static const double caption = 12;
  static const double body = 15;
  static const double subtitle = 17;
  static const double title = 22;
  static const double headline = 28;
  static const double display = 36;
}

abstract final class Targets {
  static const double minimum = 44;
}

abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Curve curve = Curves.easeOutCubic;

  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
