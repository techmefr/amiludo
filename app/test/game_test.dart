import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/layers/functional/Game/domain/game.dart';
import 'package:table_companion/layers/functional/Workspace/domain/workspace.dart';

GameSession example({
  bool low = false,
  bool cooperative = false,
  double target = 0,
}) => GameSession(
  id: 'test',
  title: 'Partie',
  players: const [
    Player(id: 'a', name: 'Camille', color: 0),
    Player(id: 'b', name: 'Alex', color: 1),
  ],
  createdAt: 100,
  categories: const ['Points', 'Bonus'],
  lowestWins: low,
  cooperative: cooperative,
  target: target,
);
void main() {
  test('scores stay scoped to player, round and category', () {
    var game = example().addScore('a', 5, 'Points').addScore('a', 2.5, 'Bonus');
    game = game
        .copyWith(round: 2)
        .addScore('a', -1, 'Points')
        .addScore('b', 10, 'Points');
    expect(game.score('a'), 6.5);
    expect(game.score('a', inRound: 1), 7.5);
    expect(game.score('a', category: 'Points'), 4);
    expect(game.score('b'), 10);
  });
  test('undo, redo and branching preserve the applied journal', () {
    var game = example().addScore('a', 1, 'Points').addScore('b', 5, 'Bonus');
    game = game.undo();
    expect(game.score('b'), 0);
    expect(game.redo().score('b'), 5);
    game = game.addScore('a', 3, 'Points');
    expect(game.cursor, 2);
    expect(game.entries.length, 2);
    expect(game.score('b'), 0);
    expect(game.redo().score('a'), 4);
  });
  test('ties, low scores and cooperative objectives are explicit', () {
    final game = example(low: true)
        .addScore('a', 5, 'Points')
        .addScore('b', 5, 'Points');
    expect(game.winners.length, 2);
    expect(game.addScore('a', -2, 'Bonus').winners.single.id, 'a');
    expect(
      example(
        cooperative: true,
        target: 10,
      ).addScore('a', 4, 'Points').addScore('b', 6, 'Points').objectiveReached,
      isTrue,
    );
  });
  test('turn rotation wraps in both directions', () {
    expect(example().nextTurn(reverse: true).activeIndex, 1);
    expect(example().nextTurn().nextTurn().activeIndex, 0);
  });
  test('invalid edits cannot enter the score journal', () {
    expect(
      () => example().addScore('missing', 1, 'Points'),
      throwsArgumentError,
    );
    expect(
      () => example().addScore('a', double.nan, 'Points'),
      throwsArgumentError,
    );
    expect(() => example().addScore('a', 1, 'missing'), throwsArgumentError);
    expect(
      () => example().copyWith(finishedAt: 200).addScore('a', 1, 'Points'),
      throwsStateError,
    );
  });
  test('JSON preserves undo/redo, resources, notes and result data', () {
    final game = example()
        .addScore('a', 3, 'Points')
        .undo()
        .copyWith(
          notes: 'Objectif libre',
          players: const [
            Player(id: 'a', name: 'Camille', color: 0, resources: {'Vies': 10}),
            Player(id: 'b', name: 'Alex', color: 1),
          ],
        );
    final imported = GameSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(game.toJson()))),
    );
    expect(imported.cursor, 0);
    expect(imported.redo().score('a'), 3);
    expect(imported.players.first.resources['Vies'], 10);
    expect(imported.notes, 'Objectif libre');
  });
  test('malformed references and unsupported backup versions are rejected', () {
    final json = example().addScore('a', 2, 'Points').toJson();
    (json['entries'] as List).first['playerId'] = 'missing';
    expect(() => GameSession.fromJson(json), throwsFormatException);
    expect(
      () => Workspace.fromJson({'format': 'table-companion', 'version': 99}),
      throwsFormatException,
    );
  });
  test('backup round trip preserves current game and style', () {
    final workspace = Workspace(games: [example()], currentId: 'test');
    final imported = Workspace.fromJson(
      Map<String, dynamic>.from(jsonDecode(workspace.export())),
    );
    expect(imported.current!.title, 'Partie');
    expect(imported.appearance.skin, 'cyber');
  });
  test('CSV includes every round and escapes quotes', () {
    final game = example()
        .addScore('a', 3, 'Points')
        .copyWith(round: 2)
        .addScore('b', 4, 'Bonus');
    expect(game.toCsv(), contains('"Manche 2"'));
    expect(game.toCsv(), contains('"Camille";"3";"0";"3"'));
  });
}
