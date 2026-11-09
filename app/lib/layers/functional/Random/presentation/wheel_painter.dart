import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/game_palette.dart';

class WheelPainter extends CustomPainter {
  WheelPainter(this.labels);
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rim = radius * .07;
    final face = radius - rim;
    canvas.drawCircle(
      center.translate(0, rim * .6),
      radius,
      Paint()..color = GamePalette.ink.withValues(alpha: .25),
    );
    canvas.drawCircle(center, radius, Paint()..color = GamePalette.ink);
    if (labels.isEmpty) {
      canvas.drawCircle(center, face, Paint()..color = GamePalette.cream);
    } else {
      _sectors(canvas, center, face);
    }
    _studs(canvas, center, radius - rim / 2, rim * .28);
    canvas.drawCircle(center, radius * .13, Paint()..color = GamePalette.ink);
    canvas.drawCircle(center, radius * .09, Paint()..color = GamePalette.cream);
  }

  void _sectors(Canvas canvas, Offset center, double face) {
    final sweep = 2 * pi / labels.length;
    for (var i = 0; i < labels.length; i++) {
      final start = -pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: face),
        start,
        sweep,
        true,
        Paint()..color = GamePalette.sector(i, labels.length),
      );
      canvas.drawLine(
        center,
        center + Offset(cos(start), sin(start)) * face,
        Paint()
          ..color = GamePalette.cream
          ..strokeWidth = 2,
      );
      _label(canvas, center, face, start + sweep / 2, labels[i]);
    }
  }

  void _label(
    Canvas canvas,
    Offset center,
    double face,
    double angle,
    String label,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final text = TextPainter(
      text: TextSpan(
        text: label.length > 12 ? '${label.substring(0, 11)}…' : label,
        style: TextStyle(
          color: GamePalette.ink,
          fontSize: face * (labels.length > 12 ? .075 : .1),
          fontWeight: FontWeight.w700,
          fontFamily: 'SpaceGrotesk',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: face * .62);
    text.paint(canvas, Offset(face * .26, -text.height / 2));
    canvas.restore();
  }

  void _studs(Canvas canvas, Offset center, double ring, double dot) {
    for (var i = 0; i < 16; i++) {
      final a = i * pi / 8;
      canvas.drawCircle(
        center + Offset(cos(a), sin(a)) * ring,
        dot,
        Paint()..color = GamePalette.yellow,
      );
    }
  }

  @override
  bool shouldRepaint(WheelPainter old) => old.labels != labels;
}

class WheelPointer extends CustomPainter {
  const WheelPointer();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = GamePalette.coral);
    canvas.drawPath(
      path,
      Paint()
        ..color = GamePalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(WheelPointer old) => false;
}
