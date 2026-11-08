import 'dart:math';

import 'package:flutter/material.dart';

class ClockDisk extends CustomPainter {
  const ClockDisk({
    required this.segments,
    required this.filled,
    required this.fill,
    required this.line,
  });
  final int segments, filled;
  final Color fill, line;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    final step = 2 * pi / segments;
    for (var i = 0; i < segments; i++) {
      canvas.drawArc(
        rect,
        -pi / 2 + i * step,
        step,
        true,
        Paint()..color = i < filled ? fill : fill.withValues(alpha: .12),
      );
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = line;
    canvas.drawCircle(centre, radius, stroke);
    for (var i = 0; i < segments; i++) {
      final angle = -pi / 2 + i * step;
      canvas.drawLine(
        centre,
        centre + Offset(cos(angle), sin(angle)) * radius,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(ClockDisk old) =>
      old.segments != segments ||
      old.filled != filled ||
      old.fill != fill ||
      old.line != line;
}
