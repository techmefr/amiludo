import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';

const minVoters = 2, maxVoters = 20, maxChoices = 12;

List<String> parseChoices(String text) =>
    parseOptions(text).toSet().take(maxChoices).toList();

class SecretVote {
  const SecretVote({
    required this.question,
    required this.choices,
    required this.voters,
    this.ballots = const [],
  });

  final String question;
  final List<String> choices;
  final int voters;
  final List<int> ballots;

  bool get closed => ballots.length >= voters;

  int get turn => closed ? voters : ballots.length + 1;

  SecretVote cast(int choice) {
    if (closed || choice < 0 || choice >= choices.length) return this;
    return SecretVote(
      question: question,
      choices: choices,
      voters: voters,
      ballots: [...ballots, choice],
    );
  }

  List<int> get tally => [
    for (var i = 0; i < choices.length; i++)
      ballots.where((b) => b == i).length,
  ];

  List<int> get winners {
    final counts = tally;
    final best = counts.fold(0, (a, b) => a > b ? a : b);
    if (best == 0) return const [];
    return [
      for (var i = 0; i < counts.length; i++)
        if (counts[i] == best) i,
    ];
  }

  bool get tied => winners.length > 1;
}
