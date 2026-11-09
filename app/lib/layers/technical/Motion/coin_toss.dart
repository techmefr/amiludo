import 'dart:math';

import 'package:flutter/animation.dart';

class CoinToss {
  const CoinToss({required this.heads, this.turns = 4, this.reduced = false});

  final bool heads;
  final int turns;
  final bool reduced;

  static const double landing = .78;
  static const double bounceHeight = .16;

  double get target => (reduced ? 1 : turns) * 2 * pi + (heads ? 0 : pi);

  double angle(double t) {
    final phase = (t / landing).clamp(0.0, 1.0);
    return target * Curves.easeOutQuad.transform(phase);
  }

  double lift(double t) {
    if (reduced) return 0;
    if (t < landing) {
      final u = t / landing;
      return 4 * u * (1 - u);
    }
    final u = (t - landing) / (1 - landing);
    return bounceHeight * 4 * u * (1 - u);
  }

  bool showsHeads(double t) => cos(angle(t)) >= 0;
}
