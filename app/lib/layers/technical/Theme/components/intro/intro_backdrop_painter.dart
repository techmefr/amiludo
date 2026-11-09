import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/intro/intro_timeline.dart';

class IntroBackdropPainter extends CustomPainter {
  IntroBackdropPainter({
    required this.animation,
    required this.color,
    required this.centerFactor,
    required this.markSize,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double centerFactor;
  final double markSize;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    _sweep(canvas, size, IntroTimeline.span(t, 0, IntroTimeline.sweepEnd));
    final pulse = math.sin(
      math.pi * IntroTimeline.span(t, 1400, IntroTimeline.glowEnd),
    );
    final hold =
        IntroTimeline.span(t, 1500, IntroTimeline.glowEnd) *
        (1 -
            IntroTimeline.span(
              t,
              IntroTimeline.zoomStart,
              IntroTimeline.zoomEnd,
            ));
    final alpha = (.5 * pulse + .22 * hold).clamp(0.0, 1.0);
    if (alpha <= 0) return;
    final center = Offset(size.width / 2, size.height * centerFactor);
    final radius = markSize * (1.3 + pulse * .9 + hold * .4);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _sweep(Canvas canvas, Size size, double p) {
    if (p <= 0 || p >= 1) return;
    final x = size.width * (-.1 + 1.2 * p);
    final fade = math.sin(math.pi * p);
    final trail = Rect.fromLTRB(x - size.width * .22, 0, x, size.height);
    canvas.drawRect(
      trail,
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: .16 * fade),
          ],
        ).createShader(trail),
    );
    final line = Rect.fromLTWH(x - 1, 0, 2, size.height);
    canvas.drawRect(
      line,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: .9 * fade),
            color.withValues(alpha: 0),
          ],
        ).createShader(line),
    );
  }

  @override
  bool shouldRepaint(IntroBackdropPainter old) =>
      old.color != color ||
      old.markSize != markSize ||
      old.centerFactor != centerFactor;
}
