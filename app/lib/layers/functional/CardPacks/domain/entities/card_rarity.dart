import 'dart:math';

enum CardRarity {
  common,
  rare,
  holo,
  ultra;

  bool get foil => this == holo || this == ultra;

  static CardRarity roll(Random random) {
    final n = random.nextInt(100);
    if (n < 60) return common;
    if (n < 85) return rare;
    if (n < 96) return holo;
    return ultra;
  }

  static CardRarity named(Object? name) => values.firstWhere(
    (r) => r.name == name,
    orElse: () => common,
  );
}
