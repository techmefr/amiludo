import 'dart:math';

import 'package:flutter/material.dart';

class SandPalette {
  const SandPalette._();
  static const night = Color(0xff0f1b24);
  static const dusk = Color(0xff3a2b45);
  static const ember = Color(0xff7a4a2a);
  static const sand = Color(0xffe9c46a);
  static const alert = Color(0xffe76f51);
  static const glass = Color(0xffbfe3e0);
  static const cream = Color(0xfff6ebd6);
  static const wood = Color(0xffb5832f);
  static const woodLight = Color(0xffd9a74e);
}

class SandglassPainter extends CustomPainter {
  const SandglassPainter({
    required this.upperFill,
    required this.lowerFill,
    required this.sand,
    required this.streaming,
    required this.phase,
  });

  final double upperFill, lowerFill, phase;
  final Color sand;
  final bool streaming;

  Path _glass(double w, double top, double bottom) {
    final mid = (top + bottom) / 2, neck = w * .035, inset = w * .1;
    final half = mid - top;
    return Path()
      ..moveTo(inset, top)
      ..lineTo(w - inset, top)
      ..cubicTo(
        w - inset,
        top + half * .7,
        w / 2 + neck * 3,
        mid - half * .3,
        w / 2 + neck,
        mid,
      )
      ..cubicTo(
        w / 2 + neck * 3,
        mid + half * .3,
        w - inset,
        bottom - half * .7,
        w - inset,
        bottom,
      )
      ..lineTo(inset, bottom)
      ..cubicTo(
        inset,
        bottom - half * .7,
        w / 2 - neck * 3,
        mid + half * .3,
        w / 2 - neck,
        mid,
      )
      ..cubicTo(
        w / 2 - neck * 3,
        mid - half * .3,
        inset,
        top + half * .7,
        inset,
        top,
      )
      ..close();
  }

  void _cap(Canvas canvas, Rect rect) {
    final radius = Radius.circular(rect.height / 2.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SandPalette.woodLight, SandPalette.wood],
        ).createShader(rect),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cap = h * .06;
    final top = cap, bottom = h - cap, mid = h / 2;
    final glass = _glass(w, top, bottom);
    canvas.drawPath(
      glass,
      Paint()..color = Colors.white.withValues(alpha: .07),
    );
    canvas.save();
    canvas.clipPath(glass);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.lerp(sand, Colors.white, .25)!, sand],
      ).createShader(Rect.fromLTRB(0, top, w, bottom));
    final upper = upperFill.clamp(0.0, 1.0), lower = lowerFill.clamp(0.0, 1.0);
    if (upper > 0) {
      canvas.drawRect(
        Rect.fromLTRB(0, mid - (mid - top) * upper, w, mid),
        paint,
      );
    }
    final level = bottom - (bottom - mid) * lower * .9;
    if (lower > 0) {
      final k = w * .05 * min(1.0, lower * 4);
      canvas.drawPath(
        Path()
          ..moveTo(0, level + k)
          ..quadraticBezierTo(w / 2, level - k, w, level + k)
          ..lineTo(w, bottom)
          ..lineTo(0, bottom)
          ..close(),
        paint,
      );
    }
    if (streaming) {
      final grain = Paint()..color = sand;
      for (var i = 0; i < 9; i++) {
        final y = mid + (level - mid) * ((i / 9 + phase) % 1);
        canvas.drawCircle(Offset(w / 2, y), w * .008, grain);
      }
      canvas.drawRect(
        Rect.fromLTRB(w / 2 - w * .004, mid, w / 2 + w * .004, level),
        grain,
      );
    }
    canvas.restore();
    canvas.drawPath(
      glass,
      Paint()
        ..color = SandPalette.glass.withValues(alpha: .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2, w * .012),
    );
    canvas.drawArc(
      Rect.fromLTWH(w * .16, top + (mid - top) * .1, w * .18, (mid - top) * .8),
      pi * .75,
      pi * .5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2, w * .014)
        ..strokeCap = StrokeCap.round,
    );
    _cap(canvas, Rect.fromLTWH(w * .04, 0, w * .92, cap));
    _cap(canvas, Rect.fromLTWH(w * .04, h - cap, w * .92, cap));
  }

  @override
  bool shouldRepaint(SandglassPainter old) =>
      old.upperFill != upperFill ||
      old.lowerFill != lowerFill ||
      old.sand != sand ||
      old.streaming != streaming ||
      old.phase != phase;
}
