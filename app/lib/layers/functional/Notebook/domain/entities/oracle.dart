import 'dart:convert';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';

enum Likelihood { veryUnlikely, unlikely, even, likely, veryLikely }

enum SceneOutcome { expected, altered, interrupted }

class OracleAnswer {
  const OracleAnswer({
    required this.roll,
    required this.chance,
    required this.yes,
    required this.exceptional,
    required this.event,
  });
  final int roll, chance;
  final bool yes, exceptional, event;
}

class OracleTables {
  OracleTables(this._data);
  factory OracleTables.decode(String source) =>
      OracleTables(jsonDecode(source) as Map<String, dynamic>);

  final Map<String, dynamic> _data;

  List<String> list(String key) => List<String>.from(_data[key] as List);
}

const _baseChance = {
  Likelihood.veryUnlikely: 15,
  Likelihood.unlikely: 30,
  Likelihood.even: 50,
  Likelihood.likely: 70,
  Likelihood.veryLikely: 85,
};

const defaultChaos = 5;

class Oracle {
  Oracle(this.tables, {RandomTools? random})
    : _random = random ?? RandomTools();

  final OracleTables tables;
  final RandomTools _random;

  static int chanceOf(Likelihood likelihood, int chaos) =>
      (_baseChance[likelihood]! + (chaos.clamp(1, 9) - defaultChaos) * 4).clamp(
        5,
        95,
      );

  String _pick(String key) {
    final values = tables.list(key);
    return values[_random.integer(0, values.length - 1)];
  }

  OracleAnswer ask(Likelihood likelihood, int chaos) {
    final chance = chanceOf(likelihood, chaos);
    final roll = _random.integer(1, 100);
    final yes = roll <= chance;
    final margin = yes ? chance : 100 - chance;
    final distance = yes ? roll : 101 - roll;
    final doubled = roll % 11 == 0 && roll ~/ 11 <= chaos.clamp(1, 9);
    return OracleAnswer(
      roll: roll,
      chance: chance,
      yes: yes,
      exceptional: distance <= margin ~/ 5,
      event: doubled,
    );
  }

  SceneOutcome sceneCheck(int chaos) {
    final roll = _random.integer(1, 10);
    if (roll > chaos.clamp(1, 9)) return SceneOutcome.expected;
    return roll.isOdd ? SceneOutcome.altered : SceneOutcome.interrupted;
  }

  String meaning() => '${_pick('action')} · ${_pick('theme')}';

  String descriptors() => '${_pick('descriptor')} · ${_pick('aspect')}';

  String randomEvent() => '${_pick('eventFocus')}: ${meaning()}';

  String reaction() {
    final total = _random.dice(6, 2).fold(0, (a, b) => a + b);
    final level = switch (total) {
      <= 3 => 0,
      <= 5 => 1,
      <= 8 => 2,
      <= 10 => 3,
      _ => 4,
    };
    return tables.list('reaction')[level];
  }

  String discovery() => _pick('discovery');

  String complication() => _pick('complication');
}
