import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Theme/tokens/breakpoints.dart';

abstract final class ToolStage {
  static const double maxTextScale = 2;
  static const double referenceHeight = 640;

  static double factor(BuildContext context) {
    final boost = switch (Breakpoints.of(context)) {
      WindowClass.compact => 1.0,
      WindowClass.medium => 1.25,
      WindowClass.expanded => 1.5,
      WindowClass.large => 1.8,
    };
    final size = MediaQuery.sizeOf(context);
    final fit = math.min(boost, size.height / referenceHeight);
    final user = MediaQuery.textScalerOf(context).scale(1);
    return math.max(1.0, math.min(fit, maxTextScale / user));
  }
}

class ToolFocus extends StatelessWidget {
  const ToolFocus({super.key, required this.child, this.baseWidth = 420});
  final Widget child;
  final double baseWidth;

  @override
  Widget build(BuildContext context) {
    final factor = ToolStage.factor(context);
    final media = MediaQuery.of(context);
    final scaled = media.copyWith(
      textScaler: TextScaler.linear(media.textScaler.scale(1) * factor),
    );
    return MediaQuery(
      data: scaled,
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: baseWidth * factor),
          child: child,
        ),
      ),
    );
  }
}
