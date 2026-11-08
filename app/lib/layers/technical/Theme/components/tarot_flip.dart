import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TarotFlip extends StatelessWidget {
  const TarotFlip({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
    this.sheen,
  });
  final Widget front, back;
  final bool flipped;
  final Color? sheen;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: flipped ? 1 : 0),
    duration: Motion.of(context, const Duration(milliseconds: 420)),
    curve: Curves.easeInOutCubic,
    builder: (context, t, _) {
      final showFront = t >= .5;
      final angle = t * math.pi;
      final face = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: showFront ? 0 : 1, child: back),
          Opacity(
            opacity: showFront ? 1 : 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: front,
            ),
          ),
        ],
      );
      final glint = sheen == null
          ? const SizedBox.shrink()
          : Positioned.fill(
              child: IgnorePointer(
                child: FractionallySizedBox(
                  widthFactor: .35,
                  alignment: Alignment(-1 + 2 * t, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          sheen!.withValues(alpha: 0),
                          sheen!.withValues(alpha: .55 * math.sin(t * math.pi)),
                          sheen!.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .0012)
          ..rotateY(angle),
        child: Stack(
          alignment: Alignment.center,
          children: [face, if (t > 0 && t < 1) glint],
        ),
      );
    },
  );
}
