import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';

class PlayerRecord {
  const PlayerRecord(this.name, this.played, this.wins);
  final String name;
  final int played, wins;

  double get rate => played == 0 ? 0 : wins / played;
}

class GameRecord {
  const GameRecord(this.title, this.plays);
  final String title;
  final int plays;
}

Iterable<GameSession> _finished(Iterable<GameSession> games) =>
    games.where((g) => g.finishedAt != null);

List<PlayerRecord> playerRecords(Iterable<GameSession> games) {
  final played = <String, int>{}, wins = <String, int>{};
  for (final game in _finished(games)) {
    final winners = game.cooperative
        ? const <Player>[]
        : game.winners;
    for (final player in game.players) {
      played.update(player.name, (n) => n + 1, ifAbsent: () => 1);
    }
    for (final player in winners) {
      wins.update(player.name, (n) => n + 1, ifAbsent: () => 1);
    }
  }
  return [
    for (final name in played.keys)
      PlayerRecord(name, played[name]!, wins[name] ?? 0),
  ]..sort((a, b) {
      final byWins = b.wins.compareTo(a.wins);
      return byWins != 0 ? byWins : b.played.compareTo(a.played);
    });
}

List<GameRecord> gameRecords(Iterable<GameSession> games) {
  final plays = <String, int>{};
  for (final game in _finished(games)) {
    plays.update(game.title, (n) => n + 1, ifAbsent: () => 1);
  }
  return [
    for (final entry in plays.entries) GameRecord(entry.key, entry.value),
  ]..sort((a, b) => b.plays.compareTo(a.plays));
}
