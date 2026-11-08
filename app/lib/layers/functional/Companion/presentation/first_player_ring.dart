import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/presentation/life_palette.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _seat = 76.0;

Offset seatCentre(int index, int count, Size box) {
  final angle = -pi / 2 + 2 * pi * index / count;
  final radius = (box.shortestSide - _seat) / 2;
  return box.center(Offset.zero) +
      Offset(cos(angle), sin(angle)) * radius;
}

class FirstPlayerRing extends StatelessWidget {
  const FirstPlayerRing({
    super.key,
    required this.names,
    required this.from,
    required this.to,
    required this.fraction,
    required this.chosen,
  });
  final List<String> names;
  final int from, to;
  final double fraction;
  final int? chosen;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final at = Offset.lerp(
          seatCentre(from, names.length, size),
          seatCentre(to, names.length, size),
          fraction,
        )!;
        return Stack(
          children: [
            for (final (i, name) in names.indexed)
              Positioned.fromRect(
                rect: Rect.fromCenter(
                  center: seatCentre(i, names.length, size),
                  width: _seat,
                  height: _seat,
                ),
                child: _Seat(
                  name: name,
                  color: playerTints[i % playerTints.length],
                  chosen: i == chosen,
                ),
              ),
            Positioned.fromRect(
              rect: Rect.fromCenter(center: at, width: _seat, height: _seat),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: StonePalette.gold, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: StonePalette.gold.withValues(alpha: .6),
                        blurRadius: Space.lg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Seat extends StatelessWidget {
  const _Seat({required this.name, required this.color, required this.chosen});
  final String name;
  final Color color;
  final bool chosen;

  @override
  Widget build(BuildContext context) => Semantics(
    label: name,
    child: ExcludeSemantics(
      child: AnimatedScale(
        scale: chosen ? 1.18 : 1,
        duration: Motion.of(context, Motion.base),
        curve: Motion.spring,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: StonePalette.stone,
            border: Border.all(color: color, width: 4),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: StonePalette.cream,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
