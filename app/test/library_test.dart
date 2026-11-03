import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_friend_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_reviews_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/remove_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/suggest_games_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';

import 'fakes.dart';

const coop = ShelfGame(
  id: 'coop',
  name: 'Pandemic',
  genres: ['coop', 'strategy'],
  minutes: 45,
);
const bluff = ShelfGame(
  id: 'bluff',
  name: 'Skull',
  genres: ['bluff', 'party'],
  minPlayers: 3,
  maxPlayers: 6,
  minutes: 20,
);
const epic = ShelfGame(
  id: 'epic',
  name: 'Twilight Imperium',
  genres: ['strategy'],
  minPlayers: 3,
  maxPlayers: 6,
  minutes: 240,
);

void main() {
  _suggestionTests();
  _friendTests();
  _storageTests();
}

void _suggestionTests() {
  test('suggestions respect player count, tastes, length and refusals', () {
    final gateway = MemoryWorkspace(
      const Workspace(
        shelf: [coop, bluff, epic],
        friends: [
          Friend(id: 'a', name: 'Alex', avoidedGenres: ['bluff']),
          Friend(id: 'b', name: 'Léa', maxMinutes: 90),
          Friend(id: 'c', name: 'Sam', refusedGameIds: ['coop']),
        ],
      ),
    );
    final suggest = SuggestGamesUseCase(gateway);
    expect(suggest(['a']).map((s) => s.game.id), ['coop']);
    expect(suggest(['b', 'c']).map((s) => s.game.id), ['bluff']);
    expect(suggest(['a', 'b']).map((s) => s.game.id), ['coop']);
    expect(suggest(['a', 'b', 'c']).map((s) => s.game.id), isEmpty);
  });

  test('guest reviews and liked genres rank suggestions', () async {
    final gateway = MemoryWorkspace(
      const Workspace(
        shelf: [coop, bluff],
        friends: [
          Friend(id: 'a', name: 'Alex', likedGenres: ['party']),
          Friend(id: 'b', name: 'Léa'),
        ],
      ),
    );
    await SaveReviewsUseCase(gateway)('s1', const [
      GameReview(
        id: 'r1',
        sessionId: 's1',
        reviewer: 'Léa',
        stars: 5,
        gameTitle: 'Pandemic',
      ),
    ]);
    final ranked = SuggestGamesUseCase(gateway)(['a', 'b']);
    expect(ranked.first.game.id, 'coop');
    expect(ranked.first.averageStars, 5);
    expect(ranked.last.score, 3.5);
  });
}

void _friendTests() {
  test('reviews replace the same reviewer for the same game', () async {
    final gateway = MemoryWorkspace();
    final save = SaveReviewsUseCase(gateway);
    const first = GameReview(
      id: '1',
      sessionId: 's',
      reviewer: 'Alex',
      stars: 2,
    );
    const second = GameReview(
      id: '2',
      sessionId: 's',
      reviewer: 'alex',
      stars: 4,
    );
    await save('s', [first]);
    await save('s', [second]);
    expect(gateway.current.reviews.map((r) => r.stars), [4]);
  });

  test('friend names stay unique', () async {
    final gateway = MemoryWorkspace();
    final save = SaveFriendUseCase(gateway);
    await save(const Friend(id: '1', name: 'Alex'));
    expect(
      () => save(const Friend(id: '2', name: 'alex')),
      throwsFormatException,
    );
  });

  test('removing a shelf game cleans friends refusals', () async {
    final gateway = MemoryWorkspace(
      const Workspace(
        shelf: [coop],
        friends: [
          Friend(id: 'a', name: 'Alex', refusedGameIds: ['coop']),
        ],
      ),
    );
    await RemoveShelfGameUseCase(gateway)('coop');
    expect(gateway.current.shelf, isEmpty);
    expect(gateway.current.friends.single.refusedGameIds, isEmpty);
  });
}

void _storageTests() {
  test('workspace backups without shelf, friends or memories still load', () {
    final legacy =
        Map<String, dynamic>.from(jsonDecode(const Workspace().export()) as Map)
          ..removeWhere(
            (k, _) => ['shelf', 'friends', 'reviews', 'memories'].contains(k),
          );
    final restored = Workspace.fromJson(legacy);
    expect(restored.shelf, isEmpty);
    expect(restored.friends, isEmpty);
    final full = const Workspace(
      shelf: [coop],
      friends: [Friend(id: 'a', name: 'A')],
    );
    final again = Workspace.fromJson(
      Map<String, dynamic>.from(jsonDecode(full.export()) as Map),
    );
    expect(again.shelf.single.name, 'Pandemic');
    expect(again.friends.single.name, 'A');
  });

  test('invalid shelf games are rejected', () {
    expect(
      () => ShelfGame.fromJson({'id': 'x', 'name': ' ', 'minPlayers': 2}),
      throwsFormatException,
    );
    expect(
      () => ShelfGame.fromJson({
        'id': 'x',
        'name': 'Ok',
        'minPlayers': 5,
        'maxPlayers': 2,
      }),
      throwsFormatException,
    );
  });
}
