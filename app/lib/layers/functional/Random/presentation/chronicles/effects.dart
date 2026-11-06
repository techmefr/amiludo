import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const particleCount = 16;

class BurstPainter extends CustomPainter {
  const BurstPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final reach = size.shortestSide * 0.6 * t;
    final paint = Paint()..color = color.withValues(alpha: 1 - t);
    for (var i = 0; i < particleCount; i++) {
      final a = i * 2 * math.pi / particleCount;
      canvas.drawCircle(
        center + Offset(math.cos(a), math.sin(a)) * reach,
        4 * (1 - t) + 1,
        paint,
      );
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withValues(alpha: 0.35 * (1 - t)),
    );
  }

  @override
  bool shouldRepaint(BurstPainter old) => old.t != t || old.color != color;
}

class Burst extends StatelessWidget {
  const Burst({
    super.key,
    required this.trigger,
    required this.color,
    required this.child,
  });
  final String trigger;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final active =
        !MediaQuery.disableAnimationsOf(context) && trigger.isNotEmpty;
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (active)
          Positioned.fill(
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(trigger),
              tween: Tween(begin: 0, end: 1),
              duration: Motion.slow,
              builder: (context, t, _) => t >= 1
                  ? const SizedBox.shrink()
                  : CustomPaint(painter: BurstPainter(t, color)),
            ),
          ),
        ),
      ],
    );
  }
}

class Halo extends StatelessWidget {
  const Halo({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Radii.lg),
      boxShadow: MediaQuery.disableAnimationsOf(context)
          ? null
          : [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 24)],
    ),
    child: child,
  );
}
