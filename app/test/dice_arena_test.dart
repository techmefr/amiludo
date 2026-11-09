import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_parts.dart';

void main() {
  test('few dice get a tighter arena than many dice', () {
    const stage = Size(1280, 720);
    expect(arenaWidthFor(stage, 2), lessThan(arenaWidthFor(stage, 8)));
    expect(arenaWidthFor(stage, 8), lessThan(arenaWidthFor(stage, 20)));
  });

  test('wide stages get a wide arena, portrait stages a narrow one', () {
    expect(
      arenaWidthFor(const Size(1280, 720), 8),
      greaterThan(arenaWidthFor(const Size(375, 812), 8)),
    );
  });

  test('arena depth stays within bounds', () {
    for (final stage in const [Size(375, 812), Size(1280, 720)]) {
      final depth = arenaDepthFor(stage, arenaWidthFor(stage, 2));
      expect(depth, inInclusiveRange(3.4, 8.0));
    }
  });
}
