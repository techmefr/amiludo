import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';

Color parseHex(String? hex, Color fallback) {
  if (hex == null) return fallback;
  final v = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return v == null || hex.length < 7 ? fallback : Color(0xff000000 | v);
}

double buildWidth(String? build) => switch (build) {
  'mince' => 0.42,
  'robuste' => 0.7,
  'trapue' => 0.74,
  'athlétique' => 0.62,
  _ => 0.54,
};

class PortraitPainter extends CustomPainter {
  const PortraitPainter(this.look, this.fallback, this.ink);
  final ChroniclesAppearance look;
  final Color fallback, ink;

  @override
  void paint(Canvas canvas, Size size) {
    final skin = parseHex(look.skin, fallback);
    final hair = parseHex(look.hair, ink);
    final eye = parseHex(look.eyes, ink);
    final eye2 = parseHex(look.eyes2, eye);
    final cx = size.width / 2;
    final head = Offset(cx, size.height * 0.34);
    final r = size.width * 0.2;
    final bodyWidth = size.width * buildWidth(look.build);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, size.height * 0.78),
            width: bodyWidth,
            height: size.height * 0.45,
          ),
          Radius.circular(r),
        ),
        Paint()..color = skin,
      )
      ..drawCircle(head, r, Paint()..color = skin)
      ..drawArc(
        Rect.fromCircle(center: head, radius: r * 1.12),
        math.pi,
        math.pi,
        true,
        Paint()..color = hair,
      )
      ..drawCircle(head.translate(-r * 0.4, 0), r * 0.1, Paint()..color = eye)
      ..drawCircle(head.translate(r * 0.4, 0), r * 0.1, Paint()..color = eye2);
  }

  @override
  bool shouldRepaint(PortraitPainter old) =>
      old.look != look || old.fallback != fallback || old.ink != ink;
}

class ChroniclesPortrait extends StatelessWidget {
  const ChroniclesPortrait({super.key, required this.look});
  final ChroniclesAppearance look;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox(
        width: 120,
        height: 160,
        child: CustomPaint(
          painter: PortraitPainter(look, scheme.outlineVariant, scheme.onSurface),
        ),
      ),
    );
  }
}
