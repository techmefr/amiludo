import 'dart:math';

class RandomTools {
  RandomTools({Random? random}) : _random = random ?? Random.secure();
  final Random _random;
  int integer(int minimum, int maximum) {
    if (maximum < minimum || maximum - minimum > 1000000000) {
      throw ArgumentError('Intervalle invalide');
    }
    return minimum + _random.nextInt(maximum - minimum + 1);
  }

  T pick<T>(List<T> values) {
    if (values.isEmpty) throw ArgumentError('Liste vide');
    return values[_random.nextInt(values.length)];
  }

  List<T> shuffled<T>(Iterable<T> values) {
    final result = values.toList();
    for (var i = result.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }
    return result;
  }

  List<List<T>> teams<T>(List<T> players, int count) {
    if (count < 1 || count > players.length) {
      throw ArgumentError('Nombre d’équipes invalide');
    }
    final result = List.generate(count, (_) => <T>[]);
    final randomized = shuffled(players);
    for (var i = 0; i < randomized.length; i++) {
      result[i % count].add(randomized[i]);
    }
    return result;
  }

  List<int> dice(
    int faces,
    int count, {
    Set<int> locked = const {},
    List<int> previous = const [],
  }) {
    if (faces < 2 || faces > 1000 || count < 1 || count > 50) {
      throw ArgumentError('Dés invalides');
    }
    return List.generate(
      count,
      (i) => locked.contains(i) && i < previous.length
          ? previous[i]
          : integer(1, faces),
    );
  }

  T weighted<T>(List<T> values, List<int> weights) {
    if (values.isEmpty ||
        values.length != weights.length ||
        weights.any((w) => w < 0) ||
        weights.fold(0, (a, b) => a + b) < 1) {
      throw ArgumentError('Poids invalides');
    }
    var point = _random.nextInt(weights.fold(0, (a, b) => a + b));
    for (var i = 0; i < values.length; i++) {
      point -= weights[i];
      if (point < 0) return values[i];
    }
    throw StateError('Tirage impossible');
  }

  DiceExpression evaluate(String expression) {
    final match = RegExp(
      r'^\s*(\d{1,2})?d(\d{1,4})(?:\s*([+-])\s*(\d{1,6}))?\s*$',
      caseSensitive: false,
    ).firstMatch(expression);
    if (match == null) {
      throw const FormatException('Utilisez par exemple 2d6+3');
    }
    final count = int.parse(match[1] ?? '1'), faces = int.parse(match[2]!);
    final modifier = int.parse(match[4] ?? '0') * (match[3] == '-' ? -1 : 1);
    final rolls = dice(faces, count);
    return DiceExpression(rolls, modifier);
  }
}

class DiceExpression {
  const DiceExpression(this.rolls, this.modifier);
  final List<int> rolls;
  final int modifier;
  int get total => rolls.fold(0, (a, b) => a + b) + modifier;
}
