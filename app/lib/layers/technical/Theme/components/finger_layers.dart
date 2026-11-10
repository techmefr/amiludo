import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';

const fingerCountdown = Duration(milliseconds: 1600);
const fingerBurst = Duration(milliseconds: 700);
const double _haloScale = 2.6;
const double _arcStroke = 6;

class FingerHalo extends StatelessWidget {
  const FingerHalo({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: fingerRingSize * _haloScale,
      height: fingerRingSize * _haloScale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: .5), color.withValues(alpha: 0)],
        ),
      ),
    ),
  );
}

class FingerCountdownArc extends StatelessWidget {
  const FingerCountdownArc({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : fingerCountdown,
      builder: (context, t, _) => CustomPaint(
        size: const Size.square(fingerRingSize + 28),
        painter: _ArcPainter(color: color, progress: t),
      ),
    ),
  );
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.color, required this.progress});
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _arcStroke;
    canvas.drawArc(
      (Offset.zero & size).deflate(_arcStroke),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

class FingerShockwave extends StatelessWidget {
  const FingerShockwave({super.key, required this.color, required this.reach});
  final Color color;
  final double reach;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: fingerBurst,
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          size: Size.square(reach * 2),
          painter: _WavePainter(color: color, progress: t),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({required this.color, required this.progress});
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2 * progress,
      Paint()
        ..color = color.withValues(alpha: 1 - progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}
