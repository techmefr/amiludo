import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/demo/demo_tiles.dart';
import 'package:amiludo/layers/technical/Theme/components/demo/demo_timeline.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DemoStage extends StatelessWidget {
  const DemoStage({
    super.key,
    required this.animation,
    required this.color,
    required this.contrast,
    required this.mockup,
  });

  final Animation<double> animation;
  final Color color;
  final Color contrast;
  final bool mockup;

  @override
  Widget build(BuildContext context) {
    final screen = ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(Space.sm),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value;
            return Opacity(
              opacity: DemoTimeline.cycleFade(t),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _row(t, 0, 1)),
                  const SizedBox(height: Space.sm),
                  Expanded(child: _row(t, 2, 3)),
                ],
              ),
            );
          },
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: contrast.withValues(alpha: mockup ? .55 : .25),
        borderRadius: BorderRadius.circular(mockup ? Radii.lg : Radii.group),
        border: Border.all(
          color: color.withValues(alpha: mockup ? .9 : .35),
          width: mockup ? Space.xs : 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: screen),
          if (mockup)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: Space.xs),
                width: Space.section,
                height: Space.xs,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(double t, int a, int b) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(child: _tile(t, a)),
      const SizedBox(width: Space.sm),
      Expanded(child: _tile(t, b)),
    ],
  );

  Widget _tile(double t, int index) {
    final p = DemoTimeline.slot(t, index);
    final content = switch (index) {
      0 => DemoDieTile(progress: p, color: color, contrast: contrast),
      1 => DemoCardTile(progress: p, color: color, contrast: contrast),
      2 => DemoScoreTile(progress: p, color: color),
      _ => DemoTimerTile(progress: p, color: color),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.md),
        child: content,
      ),
    );
  }
}
