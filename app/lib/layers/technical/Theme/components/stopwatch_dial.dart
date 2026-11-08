import 'dart:math';

import 'package:flutter/material.dart';

class StopwatchDial extends CustomPainter {
  const StopwatchDial({
    required this.progress,
    required this.track,
    required this.sweep,
    required this.marks,
  });
  final double progress;
  final Color track, sweep, marks;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, ring..color = track);
    final tick = Paint()
      ..color = marks
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final angle = -pi / 2 + i * pi / 30;
      final long = i % 5 == 0;
      final from = radius - (long ? 26 : 18);
      final to = radius - 12;
      canvas.drawLine(
        center + Offset(cos(angle), sin(angle)) * from,
        center + Offset(cos(angle), sin(angle)) * to,
        tick..strokeWidth = long ? 3 : 1.5,
      );
    }
    final turn = progress.clamp(0.0, 1.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      turn,
      false,
      ring..color = sweep,
    );
    final tip = -pi / 2 + turn;
    canvas.drawCircle(
      center + Offset(cos(tip), sin(tip)) * radius,
      9,
      Paint()..color = sweep,
    );
  }

  @override
  bool shouldRepaint(StopwatchDial old) =>
      old.progress != progress ||
      old.track != track ||
      old.sweep != sweep ||
      old.marks != marks;
}
