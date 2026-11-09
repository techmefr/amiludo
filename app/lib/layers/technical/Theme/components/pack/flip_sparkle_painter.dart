import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlipSparklePainter extends CustomPainter {
  const FlipSparklePainter({
    required this.progress,
    required this.rarity,
    required this.color,
  });
  final double progress, rarity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final random = math.Random(11);
    final center = size.center(Offset.zero);
    final count = 8 + (34 * rarity).round();
    final local = Curves.easeOut.transform(progress);
    final fade = math.sin(progress * math.pi);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = (.3 + random.nextDouble() * .7) * size.width * .5;
      final at =
          center + Offset(math.cos(angle), math.sin(angle)) * distance * local;
      final r = size.width * (.012 + random.nextDouble() * .02) * (1 + rarity);
      paint.color = Color.lerp(
        color,
        const Color(0xffffffff),
        random.nextDouble() * .6,
      )!.withValues(alpha: fade * (.55 + .4 * rarity));
      canvas.drawPath(_spark(at, r), paint);
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
  bool shouldRepaint(FlipSparklePainter old) =>
      old.progress != progress || old.rarity != rarity;
}
