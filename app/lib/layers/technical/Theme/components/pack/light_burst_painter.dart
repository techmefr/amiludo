import 'dart:math' as math;

import 'package:flutter/material.dart';

class LightBurstPainter extends CustomPainter {
  const LightBurstPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final fade = math.sin(progress * math.pi);
    final reach = size.longestSide * (.2 + .6 * progress);
    final flash = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xffffffff).withValues(alpha: .9 * fade),
          color.withValues(alpha: .45 * fade),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: reach));
    canvas.drawCircle(center, reach, flash);
    final ray = Paint()..color = color.withValues(alpha: .55 * fade);
    const rays = 14;
    const spread = .05;
    for (var i = 0; i < rays; i++) {
      final angle = i * 2 * math.pi / rays + progress * .6;
      final length = reach * (i.isEven ? 1 : .7);
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(
            center.dx + math.cos(angle - spread) * length,
            center.dy + math.sin(angle - spread) * length,
          )
          ..lineTo(
            center.dx + math.cos(angle + spread) * length,
            center.dy + math.sin(angle + spread) * length,
          )
          ..close(),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(LightBurstPainter old) =>
      old.progress != progress || old.color != color;
}
