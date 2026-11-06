import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const flipPerspective = 0.001;

class FlipCard extends StatelessWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.faceUp,
  });
  final Widget front, back;
  final bool faceUp;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: faceUp ? 1 : 0),
    duration: Motion.of(context, Motion.slow),
    curve: Motion.curve,
    builder: (context, t, _) {
      final showFront = t >= 0.5;
      final angle = (showFront ? 1 - t : t) * math.pi;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, flipPerspective)
          ..rotateY(angle),
        child: showFront ? front : back,
      );
    },
  );
}
