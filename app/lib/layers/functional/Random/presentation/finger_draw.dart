import 'package:flutter/painting.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';

class FingerDraw {
  const FingerDraw({
    this.winners = const {},
    this.ranks = const {},
    this.groups = const {},
  });
  final Set<int> winners;
  final Map<int, int> ranks, groups;
}

const int maxFingerWinners = 5;
const int maxFingerGroups = 4;

int fingerWinnerLimit(int fingers) => (fingers - 1).clamp(1, maxFingerWinners);

int fingerGroupLimit(int fingers) => fingers.clamp(2, maxFingerGroups);

FingerDraw drawFingers({
  required Iterable<int> pointers,
  required FingerMode mode,
  required int winners,
  required int groups,
  required RandomTools random,
}) {
  final order = random.shuffled(pointers);
  return switch (mode) {
    FingerMode.first => FingerDraw(
      winners: order
          .take(winners.clamp(1, fingerWinnerLimit(order.length)))
          .toSet(),
    ),
    FingerMode.rank => FingerDraw(
      ranks: {for (final (i, p) in order.indexed) p: i + 1},
    ),
    FingerMode.groups => FingerDraw(
      groups: {
        for (final (i, p) in order.indexed)
          p: i % groups.clamp(1, fingerGroupLimit(order.length)) + 1,
      },
    ),
  };
}

int? nearestFinger(Iterable<int> ids, Map<int, Offset> at, Offset point) => ids
    .where((id) => (at[id]! - point).distance < fingerRingSize / 2)
    .firstOrNull;
