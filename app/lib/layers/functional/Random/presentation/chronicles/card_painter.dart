import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const hologramFrom = 3;
const _hues = [0.0, 130.0, 210.0, 280.0, 40.0, 340.0];

int _index(int score) => (score - 1).clamp(0, _hues.length - 1).toInt();

Color rarityColor(int score) {
  final i = _index(score);
  return HSLColor.fromAHSL(1, _hues[i], i == 0 ? 0 : 0.65, 0.5).toColor();
}

int sigilSeed(String id) => id.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0xffff);

class ChroniclesCardPainter extends CustomPainter {
  const ChroniclesCardPainter({
    required this.id,
    required this.score,
    required this.surface,
    this.phase = 0.5,
  });
  final String id;
  final int score;
  final Color surface;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final color = rarityColor(score);
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(Radii.lg),
    );
    canvas.drawRRect(rect, Paint()..color = surface);
    _sigil(canvas, size, color);
    if (score >= hologramFrom) _hologram(canvas, size, rect, color);
    canvas.drawRRect(
      rect.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + score
        ..color = color,
    );
  }

  void _sigil(Canvas canvas, Size size, Color color) {
    final seed = sigilSeed(id);
    final points = 3 + seed % 5;
    final skip = 1 + (seed ~/ 7) % (points - 1);
    final center = Offset(size.width / 2, size.height * 0.32);
    final radius = size.width * 0.28;
    final turn = (seed % 360) * math.pi / 180;
    final path = Path();
    for (var i = 0; i <= points; i++) {
      final a = turn + (i * skip % points) * 2 * math.pi / points;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas
      ..drawCircle(
        center,
        radius * 1.15,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.5),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color,
      );
  }

  void _hologram(Canvas canvas, Size size, RRect rect, Color color) {
    final shift = (phase * 2 - 1) * size.width;
    canvas
      ..save()
      ..clipRRect(rect)
      ..drawRect(
        Offset.zero & size,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 0.35),
              HSLColor.fromAHSL(0.3, (_hues[_index(score)] + 60) % 360, 0.8, 0.7)
                  .toColor(),
              color.withValues(alpha: 0),
            ],
            stops: const [0.2, 0.4, 0.55, 0.8],
            transform: GradientRotation(shift / size.width),
          ).createShader(Offset.zero & size),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(ChroniclesCardPainter old) =>
      old.id != id || old.score != score || old.phase != phase;
}
