import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

abstract final class Gutters {
  static const double compact = Space.lg;
  static const double medium = Space.xl;
  static const double wide = Space.xxl;

  static double forWidth(double width) => switch (Breakpoints.classify(width)) {
    WindowClass.compact => compact,
    WindowClass.medium => medium,
    _ => wide,
  };

  static double of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  static double columnInset(double width, double maxWidth) {
    final centred = (width - maxWidth) / 2;
    final gutter = forWidth(width);
    return centred > gutter ? centred : gutter;
  }

  static double columnInsetOf(BuildContext context, double maxWidth) =>
      columnInset(MediaQuery.sizeOf(context).width, maxWidth);
}

abstract final class Rows {
  static const double minimum = 56;
  static const double chip = Targets.minimum;
  static const double chipCompact = 32;
  static const double step = Targets.minimum;
}

abstract final class CardPadding {
  static const double compact = Space.md;
  static const double regular = Space.lg;
  static const double roomy = Space.xl;
}
