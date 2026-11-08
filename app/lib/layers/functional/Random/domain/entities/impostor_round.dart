import 'dart:math';

const minImpostorPlayers = 3, maxImpostorPlayers = 12;

class ImpostorRound {
  const ImpostorRound({
    required this.word,
    required this.players,
    required this.impostor,
    this.seen = 0,
  });

  factory ImpostorRound.deal(String word, int players, Random random) =>
      ImpostorRound(
        word: word.trim(),
        players: players,
        impostor: random.nextInt(players),
      );

  final String word;
  final int players, impostor, seen;

  bool get done => seen >= players;

  int get turn => done ? players : seen + 1;

  bool get holderIsImpostor => seen == impostor;

  ImpostorRound advance() => done
      ? this
      : ImpostorRound(
          word: word,
          players: players,
          impostor: impostor,
          seen: seen + 1,
        );
}
