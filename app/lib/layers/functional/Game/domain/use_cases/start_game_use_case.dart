import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class StartGameUseCase {
  StartGameUseCase(this._workspace, this._time);

  static const _colors = [
    0xffe9ad8d,
    0xffbdb2e3,
    0xffc1da84,
    0xffe1c476,
    0xff8ac6d4,
    0xffe7a0c5,
  ];

  final WorkspaceGateway _workspace;
  final MonotonicTime _time;

  Future<void> call(String title, List<String> names, GameTemplate template) {
    if (names.isEmpty ||
        names.length > 32 ||
        names.map((n) => n.trim()).toSet().length != names.length ||
        names.any((n) => n.trim().isEmpty || n.length > 40)) {
      throw GameError.invalidPlayers;
    }
    final data = _workspace.current;
    final id = newId();
    final players = [
      for (var i = 0; i < names.length; i++)
        Player(
          id: '$id-$i',
          name: names[i].trim(),
          color: _colors[i % _colors.length],
          resources: template.resources,
        ),
    ];
    final current = GameSession(
      id: id,
      title: title.trim().isEmpty ? template.name : title.trim(),
      pack: template,
      players: players,
      categories: template.categories,
      target: template.target,
      lowestWins: template.lowestWins,
      cooperative: template.cooperative,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    return _workspace.save(
      data.copyWith(
        games: [current, ...data.games],
        currentId: id,
        sessionClocks: data.clocksAt(_time.now),
        reverse: false,
        playerNames: names,
        clock: GameClock(
          remainingMs: template.seconds * 1000,
          durationMs: template.seconds * 1000,
        ),
        banks: {
          ...data.banks,
          for (final p in players) p.id: template.seconds * 1000,
        },
        bankMode: template.id == 'duel',
      ),
    );
  }
}
