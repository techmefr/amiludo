import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/demo/demo_dice_painter.dart';
import 'package:amiludo/layers/technical/Theme/components/demo/demo_ring_painter.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const int demoScore = 128;
const int demoSeconds = 30;

class DemoDieTile extends StatelessWidget {
  const DemoDieTile({
    super.key,
    required this.progress,
    required this.color,
    required this.contrast,
  });

  final double progress;
  final Color color;
  final Color contrast;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: DemoDicePainter(progress: progress, body: color, pip: contrast),
  );
}

class DemoCardTile extends StatelessWidget {
  const DemoCardTile({
    super.key,
    required this.progress,
    required this.color,
    required this.contrast,
  });

  final double progress;
  final Color color;
  final Color contrast;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final width = math.min(c.maxWidth * .6, c.maxHeight * .8 * tarotRatio);
      final turn = Curves.easeInOutCubic.transform(progress) * math.pi;
      final front = turn > math.pi / 2;
      return Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .002)
            ..rotateY(front ? turn - math.pi : turn),
          child: front
              ? _Face(width: width, color: color, contrast: contrast)
              : TarotBack(style: TarotStyle.nightGold, width: width),
        ),
      );
    },
  );
}

class _Face extends StatelessWidget {
  const _Face({
    required this.width,
    required this.color,
    required this.contrast,
  });

  final double width;
  final Color color;
  final Color contrast;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: width / tarotRatio,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(width * .06),
    ),
    child: Icon(Icons.auto_awesome, color: contrast, size: width * .5),
  );
}

class DemoScoreTile extends StatelessWidget {
  const DemoScoreTile({super.key, required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = (demoScore * Curves.easeOutCubic.transform(progress)).round();
    return Center(
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: Text(
            '$value',
            style: Numerals.instrument(
              Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoTimerTile extends StatelessWidget {
  const DemoTimerTile({super.key, required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Positioned.fill(
        child: CustomPaint(
          painter: DemoRingPainter(remaining: 1 - progress, color: color),
        ),
      ),
      Text(
        '${(demoSeconds * (1 - progress)).ceil()}',
        style: Numerals.instrument(
          Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
      ),
    ],
  );
}
