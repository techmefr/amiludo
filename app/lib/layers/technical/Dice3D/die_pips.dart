import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';

const _lo = 0.28, _mid = 0.5, _hi = 0.72;

const _spots = {
  1: [Offset(_mid, _mid)],
  2: [Offset(_lo, _lo), Offset(_hi, _hi)],
  3: [Offset(_lo, _lo), Offset(_mid, _mid), Offset(_hi, _hi)],
  4: [Offset(_lo, _lo), Offset(_hi, _lo), Offset(_lo, _hi), Offset(_hi, _hi)],
  5: [
    Offset(_lo, _lo),
    Offset(_hi, _lo),
    Offset(_mid, _mid),
    Offset(_lo, _hi),
    Offset(_hi, _hi),
  ],
  6: [
    Offset(_lo, _lo),
    Offset(_hi, _lo),
    Offset(_lo, _mid),
    Offset(_hi, _mid),
    Offset(_lo, _hi),
    Offset(_hi, _hi),
  ],
};

class DiePips extends StatelessWidget {
  const DiePips({super.key, required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PipsPainter(count, color));
}

class _PipsPainter extends CustomPainter {
  const _PipsPainter(this.count, this.color);

  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 0.085;
    for (final spot in _spots[count] ?? const <Offset>[]) {
      final c = Offset(spot.dx * size.width, spot.dy * size.height);
      canvas.drawCircle(
        c + Offset(0, r * 0.18),
        r,
        Paint()..color = lighten(color, 0.55).withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            c + Offset(-r * 0.3, -r * 0.3),
            r * 1.4,
            [lighten(color, 0.2), color, darken(color, 0.3)],
            const [0, 0.55, 1],
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_PipsPainter old) =>
      old.count != count || old.color != color;
}

class EngravedNumber extends StatelessWidget {
  const EngravedNumber({
    super.key,
    required this.text,
    required this.color,
    required this.light,
  });

  final String text;
  final Color color, light;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          height: 1,
          shadows: [
            Shadow(color: light.withValues(alpha: 0.55), offset: const Offset(0, 1)),
            Shadow(color: color.withValues(alpha: 0.3), offset: const Offset(0, -0.6)),
          ],
        ),
      ),
    ),
  );
}
