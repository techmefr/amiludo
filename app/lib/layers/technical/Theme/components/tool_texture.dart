import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ToolTexturePainter extends CustomPainter {
  const ToolTexturePainter(this.texture, this.color);
  final ToolTexture texture;
  final Color color;

  static const double _step = Space.lg;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = Hairline.width * 2;
    switch (texture) {
      case ToolTexture.plain:
        break;
      case ToolTexture.felt:
        _dots(canvas, size, paint, _step / 2);
      case ToolTexture.tactile:
        _hatch(canvas, size, paint);
      case ToolTexture.glass:
        _sheen(canvas, size);
      case ToolTexture.parchment:
        _fibres(canvas, size, paint);
      case ToolTexture.paper:
        _rules(canvas, size, paint);
      case ToolTexture.deck:
        _lattice(canvas, size, paint);
      case ToolTexture.frame:
        _vignette(canvas, size);
    }
  }

  void _dots(Canvas canvas, Size size, Paint paint, double gap) {
    for (var y = 0.0, row = 0; y < size.height; y += gap, row++) {
      for (var x = row.isOdd ? gap / 2 : 0.0; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), Hairline.width, paint);
      }
    }
  }

  void _hatch(Canvas canvas, Size size, Paint paint) {
    for (var d = -size.height; d < size.width; d += _step) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        paint,
      );
    }
  }

  void _sheen(Canvas canvas, Size size) {
    final band = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
        stops: const [.3, .42, .54],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, band);
  }

  void _fibres(Canvas canvas, Size size, Paint paint) {
    final random = Random(size.width.toInt());
    for (var y = _step; y < size.height; y += _step) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x < size.width; x += _step * 3) {
        path.quadraticBezierTo(
          x + _step * 1.5,
          y + (random.nextDouble() - .5) * Space.md,
          x + _step * 3,
          y,
        );
      }
      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }
  }

  void _rules(Canvas canvas, Size size, Paint paint) {
    for (var y = Space.xl; y < size.height; y += Space.xl) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    canvas.drawLine(
      const Offset(Space.section, 0),
      Offset(Space.section, size.height),
      paint,
    );
  }

  void _lattice(Canvas canvas, Size size, Paint paint) {
    for (var d = -size.height; d < size.width; d += Space.xl) {
      canvas
        ..drawLine(Offset(d, 0), Offset(d + size.height, size.height), paint)
        ..drawLine(Offset(d + size.height, 0), Offset(d, size.height), paint);
    }
  }

  void _vignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1,
          colors: [color.withValues(alpha: 0), color],
          stops: const [.6, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(ToolTexturePainter old) =>
      old.texture != texture || old.color != color;
}

class ToolTextureLayer extends StatelessWidget {
  const ToolTextureLayer({
    super.key,
    required this.texture,
    this.opacity = .05,
  });
  final ToolTexture texture;
  final double opacity;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: ToolTexturePainter(
              texture,
              Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    ),
  );
}
