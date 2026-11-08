import 'dart:math';

enum OracleLikelihood {
  unlikely(25),
  even(50),
  likely(75);

  const OracleLikelihood(this.base);
  final int base;
}

enum OracleAnswer { yes, no, exceptionalYes, exceptionalNo }

const minChaos = 1, maxChaos = 9, defaultChaos = 5;

class OracleVerdict {
  const OracleVerdict(this.roll, this.answer, {required this.event});
  final int roll;
  final OracleAnswer answer;
  final bool event;

  bool get positive =>
      answer == OracleAnswer.yes || answer == OracleAnswer.exceptionalYes;
}

int oracleChance(OracleLikelihood likelihood, int chaos) =>
    (likelihood.base + (chaos - defaultChaos) * 5).clamp(5, 95);

OracleVerdict judgeOracle(int roll, OracleLikelihood likelihood, int chaos) {
  final chance = oracleChance(likelihood, chaos);
  final yes = roll <= chance;
  final exceptional = yes
      ? roll <= chance ~/ 5
      : roll > 100 - (100 - chance) ~/ 5;
  final answer = switch ((yes, exceptional)) {
    (true, true) => OracleAnswer.exceptionalYes,
    (true, false) => OracleAnswer.yes,
    (false, true) => OracleAnswer.exceptionalNo,
    (false, false) => OracleAnswer.no,
  };
  final doubles = roll < 100 && roll % 11 == 0 && roll ~/ 11 <= chaos;
  return OracleVerdict(roll, answer, event: doubles);
}

OracleVerdict askOracle(
  Random random,
  OracleLikelihood likelihood,
  int chaos,
) => judgeOracle(random.nextInt(100) + 1, likelihood, chaos);
