import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

class TarotBack extends StatelessWidget {
  const TarotBack({
    super.key,
    this.style = TarotStyle.nightGold,
    this.width = 160,
  });
  final TarotStyle style;
  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: width / tarotRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * .06),
          boxShadow: [
            BoxShadow(
              color: style.deep.withValues(alpha: .5),
              blurRadius: width * .1,
              offset: Offset(0, width * .04),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * .06),
          child: CustomPaint(painter: TarotBackPainter(style)),
        ),
      ),
    ),
  );
}

class TarotBackPainter extends CustomPainter {
  const TarotBackPainter(this.style);
  final TarotStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.base, style.deep],
        ).createShader(rect),
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = style.line;
    _frames(canvas, size, stroke);
    _corners(canvas, size, stroke);
    _medallion(canvas, Offset(w / 2, h / 2), w, stroke);
    _stars(canvas, size);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0x33ffffff),
            const Color(0x00ffffff),
            const Color(0x1affffff),
          ],
          stops: const [0, .5, 1],
        ).createShader(rect),
    );
  }

  void _frames(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    for (final (inset, weight) in [(.055, .012), (.085, .006)]) {
      stroke.strokeWidth = w * weight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * inset,
            w * inset,
            w * (1 - 2 * inset),
            size.height - 2 * w * inset,
          ),
          Radius.circular(w * .03),
        ),
        stroke,
      );
    }
  }

  void _corners(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final fill = Paint()..color = style.line;
    stroke.strokeWidth = w * .008;
    for (final sx in [-1.0, 1.0]) {
      for (final sy in [-1.0, 1.0]) {
        final corner = Offset(
          sx < 0 ? w * .085 : w - w * .085,
          sy < 0 ? w * .085 : size.height - w * .085,
        );
        canvas.save();
        canvas.translate(corner.dx, corner.dy);
        canvas.scale(-sx, -sy);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: w * .1),
          0,
          math.pi / 2,
          false,
          stroke,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: w * .06),
          0,
          math.pi / 2,
          false,
          stroke,
        );
        canvas.drawCircle(Offset(w * .03, w * .03), w * .012, fill);
        canvas.restore();
      }
    }
  }

  void _medallion(Canvas canvas, Offset c, double w, Paint stroke) {
    final radius = w * .3;
    stroke.strokeWidth = w * .01;
    canvas.drawCircle(c, radius, stroke);
    canvas.drawCircle(c, radius * .86, stroke..strokeWidth = w * .005);
    final ray = Paint()
      ..color = style.line
      ..strokeWidth = w * .008
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      final inner = radius * 1.02;
      final outer = radius * (i.isEven ? 1.2 : 1.12);
      canvas.drawLine(
        c + Offset(math.cos(angle), math.sin(angle)) * inner,
        c + Offset(math.cos(angle), math.sin(angle)) * outer,
        ray,
      );
    }
    final petal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .005
      ..color = style.line.withValues(alpha: .8);
    for (var i = 0; i < 8; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * math.pi / 4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -radius * .45),
          width: radius * .3,
          height: radius * .55,
        ),
        petal,
      );
      canvas.restore();
    }
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: radius * .38)),
      Path()
        ..addOval(
          Rect.fromCircle(
            center: c + Offset(radius * .16, -radius * .06),
            radius: radius * .33,
          ),
        ),
    );
    canvas.drawPath(moon, Paint()..color = style.line);
    _star(canvas, c + Offset(radius * .17, -radius * .02), radius * .12);
  }

  void _stars(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    for (final y in [.2, .8]) {
      _star(canvas, Offset(w / 2, h * y), w * .05);
    }
    for (final x in [.24, .76]) {
      for (final y in [.3, .7]) {
        _star(canvas, Offset(w * x, h * y), w * .028);
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final len = i.isEven ? r : r * .3;
      final a = i * math.pi / 4 - math.pi / 2;
      final p = c + Offset(math.cos(a), math.sin(a)) * len;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = style.line);
  }

  @override
  bool shouldRepaint(TarotBackPainter old) => old.style != style;
}
