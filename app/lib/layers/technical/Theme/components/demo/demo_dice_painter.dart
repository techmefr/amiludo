import 'dart:math' as math;

import 'package:flutter/material.dart';

const _pips = <int, List<Offset>>{
  1: [Offset(.5, .5)],
  2: [Offset(.28, .28), Offset(.72, .72)],
  3: [Offset(.28, .28), Offset(.5, .5), Offset(.72, .72)],
  4: [Offset(.28, .28), Offset(.72, .28), Offset(.28, .72), Offset(.72, .72)],
  5: [
    Offset(.28, .28),
    Offset(.72, .28),
    Offset(.5, .5),
    Offset(.28, .72),
    Offset(.72, .72),
  ],
  6: [
    Offset(.28, .26),
    Offset(.72, .26),
    Offset(.28, .5),
    Offset(.72, .5),
    Offset(.28, .74),
    Offset(.72, .74),
  ],
};

const int demoDieResult = 5;

class DemoDicePainter extends CustomPainter {
  const DemoDicePainter({
    required this.progress,
    required this.body,
    required this.pip,
  });

  final double progress;
  final Color body;
  final Color pip;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) * .5;
    final settle = Curves.easeOutCubic.transform(progress);
    final hop = (1 - progress) * math.sin(progress * math.pi * 3).abs();
    final center = Offset(
      size.width / 2 - (1 - settle) * size.width * .3,
      size.height * .55 - hop * size.height * .35,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * .55 + side * .62),
        width: side * (1 - hop * .4),
        height: side * .18,
      ),
      Paint()..color = body.withValues(alpha: .18),
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((1 - settle) * math.pi * 3);
    final box = Rect.fromCenter(center: Offset.zero, width: side, height: side);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(side * .22)),
      Paint()..color = body,
    );
    final face = progress < .85
        ? (progress * 24).floor() % 6 + 1
        : demoDieResult;
    for (final p in _pips[face]!) {
      canvas.drawCircle(
        box.topLeft + Offset(p.dx * side, p.dy * side),
        side * .09,
        Paint()..color = pip,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DemoDicePainter old) =>
      old.progress != progress || old.body != body || old.pip != pip;
}
