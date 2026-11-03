enum RandomInputError implements Exception {
  invalidBounds,
  emptyBag,
  roleCount,
  wheelSize,
  wheelWeight,
}

class NumberBounds {
  const NumberBounds(this.minimum, this.maximum);

  factory NumberBounds.parse(String minimum, String maximum) {
    final low = int.tryParse(minimum.trim()),
        high = int.tryParse(maximum.trim());
    if (low == null || high == null || high < low || high - low > maxSpan) {
      throw RandomInputError.invalidBounds;
    }
    return NumberBounds(low, high);
  }

  static const maxSpan = 1000000000;

  final int minimum, maximum;
}

class WheelOptions {
  const WheelOptions(this.labels, this.weights);

  factory WheelOptions.parse(String text) {
    final entries = parseOptions(text);
    if (entries.length < minOptions || entries.length > maxOptions) {
      throw RandomInputError.wheelSize;
    }
    final labels = <String>[], weights = <int>[];
    for (final entry in entries) {
      final parts = entry.split(':');
      final weight = parts.length == 2 ? int.tryParse(parts.last.trim()) : 1;
      if (parts.length > 2 ||
          weight == null ||
          weight < 1 ||
          weight > maxWeight) {
        throw RandomInputError.wheelWeight;
      }
      labels.add(parts.first.trim());
      weights.add(weight);
    }
    return WheelOptions(labels, weights);
  }

  static const minOptions = 2, maxOptions = 50, maxWeight = 1000000;

  final List<String> labels;
  final List<int> weights;
}

List<String> parseOptions(String text) => text
    .split(RegExp(r'[,\n]'))
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

List<String> parseBag(String text) {
  final tokens = parseOptions(text);
  if (tokens.isEmpty) throw RandomInputError.emptyBag;
  return tokens;
}

List<String> parseRoles(String text, int players) {
  final roles = parseOptions(text);
  if (roles.isEmpty || roles.length != players) {
    throw RandomInputError.roleCount;
  }
  return roles;
}

List<String> starterRoles(int players, String lead, String rest) =>
    List.generate(players, (i) => i == 0 ? lead : rest);
