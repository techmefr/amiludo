import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/game_palette.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';

class CoinFace extends StatelessWidget {
  const CoinFace({
    super.key,
    required this.heads,
    required this.size,
    this.face,
    this.reader,
  });
  final bool heads;
  final double size;

  final DieFaceContent? face;
  final DieImageReader? reader;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _CoinPainter(heads, face != null),
    child: face == null
        ? null
        : SizedBox.square(
            dimension: size,
            child: Center(
              child: DieFaceView(
                face: face!,
                body: GamePalette.yellow,
                size: size,
                reader: reader,
              ),
            ),
          ),
  );
}

class _CoinPainter extends CustomPainter {
  const _CoinPainter(this.heads, this.custom);
  final bool heads, custom;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, Paint()..color = GamePalette.ink);
    canvas.drawCircle(
      center,
      radius * .94,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.4, -.5),
          colors: [GamePalette.cream, GamePalette.yellow, GamePalette.coral],
          stops: const [0, .55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius * .78,
      Paint()
        ..color = GamePalette.ink.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .05,
    );
    if (custom) return;
    if (heads) {
      _star(canvas, center, radius * .5);
    } else {
      _diamond(canvas, center, radius * .46);
    }
  }

  void _star(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -pi / 2 + i * pi / 5;
      final d = i.isEven ? r : r * .45;
      final p = center + Offset(cos(a), sin(a)) * d;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = GamePalette.ink);
  }

  void _diamond(Canvas canvas, Offset center, double r) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r * .7, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r * .7, center.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = GamePalette.purple);
    canvas.drawPath(
      path,
      Paint()
        ..color = GamePalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .12,
    );
  }

  @override
  bool shouldRepaint(_CoinPainter old) =>
      old.heads != heads || old.custom != custom;
}
