import 'dart:math' as math;

import 'package:flutter/material.dart';

class SparkleRainPainter extends CustomPainter {
  const SparkleRainPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final random = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 48; i++) {
      final x = random.nextDouble() * size.width;
      final delay = random.nextDouble() * .5;
      final speed = .6 + random.nextDouble() * .6;
      final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (local == 0) continue;
      final y = -size.height * .1 + local * size.height * 1.1 * speed;
      final fade = math.sin(local * math.pi);
      paint.color = color.withValues(alpha: fade * .9);
      final r = size.width * (.006 + random.nextDouble() * .01);
      final c = Offset(x + math.sin(local * 6 + i) * size.width * .02, y);
      canvas.drawPath(_spark(c, r * 2.2), paint);
    }
  }

  Path _spark(Offset c, double r) => Path()
    ..moveTo(c.dx, c.dy - r)
    ..lineTo(c.dx + r * .3, c.dy - r * .3)
    ..lineTo(c.dx + r, c.dy)
    ..lineTo(c.dx + r * .3, c.dy + r * .3)
    ..lineTo(c.dx, c.dy + r)
    ..lineTo(c.dx - r * .3, c.dy + r * .3)
    ..lineTo(c.dx - r, c.dy)
    ..lineTo(c.dx - r * .3, c.dy - r * .3)
    ..close();

  @override
  bool shouldRepaint(SparkleRainPainter old) => old.progress != progress;
}
