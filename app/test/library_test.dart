import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/friend_circle.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_friend_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_reviews_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
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
  test('shelf game keeps barcode, cover and status through json', () {
    const game = ShelfGame(
      id: 'x',
      name: 'Catan',
      barcode: '3770000000001',
      imageUrl: 'https://example.com/c.jpg',
      status: 'wishlist',
    );
    final back = ShelfGame.fromJson(
      jsonDecode(jsonEncode(game.toJson())) as Map<String, dynamic>,
    );
    expect(back.barcode, '3770000000001');
    expect(back.imageUrl, 'https://example.com/c.jpg');
    expect(back.status, 'wishlist');
  });
  test('old shelf data defaults to owned without barcode', () {
    final old = ShelfGame.fromJson({'id': 'a', 'name': 'Skull'});
    expect(old.status, 'owned');
    expect(old.barcode, '');
    expect(
      ShelfGame.fromJson({'id': 'a', 'name': 'S', 'status': 'x', 'barcode': '37-7 0'}).barcode,
      '3770',
    );
  });
  _suggestionTests();
  _opinionSuggestionTests();
  _friendTests();
  _storageTests();
}

void _suggestionTests() {
  test('suggestions respect player count, tastes, length and refusals', () {
    final gateway = MemoryShelf(const Shelf(games: [coop, bluff, epic]));
    final friends = MemoryFriends(
      const FriendCircle(
        friends: [
          Friend(id: 'a', name: 'Alex', avoidedGenres: ['bluff']),
          Friend(id: 'b', name: 'Léa', maxMinutes: 90),
          Friend(id: 'c', name: 'Sam', refusedGameIds: ['coop']),
        ],
      ),
    );
    final suggest = SuggestGamesUseCase(gateway, friends);
    expect(suggest(['a']).map((s) => s.game.id), ['coop']);
    expect(suggest(['b', 'c']).map((s) => s.game.id), ['bluff']);
    expect(suggest(['a', 'b']).map((s) => s.game.id), ['coop']);
    expect(suggest(['a', 'b', 'c']).map((s) => s.game.id), isEmpty);
  });

  test('guest reviews and liked genres rank suggestions', () async {
    final gateway = MemoryShelf(const Shelf(games: [coop, bluff]));
    final friends = MemoryFriends(
      const FriendCircle(
        friends: [
          Friend(id: 'a', name: 'Alex', likedGenres: ['party']),
          Friend(id: 'b', name: 'Léa'),
        ],
      ),
    );
    await SaveReviewsUseCase(friends)('s1', const [
      GameReview(
        id: 'r1',
        sessionId: 's1',
        reviewer: 'Léa',
        stars: 5,
        gameTitle: 'Pandemic',
      ),
    ]);
    final ranked = SuggestGamesUseCase(gateway, friends)(['a', 'b']);
    expect(ranked.first.game.id, 'coop');
    expect(ranked.first.averageStars, 5);
    expect(ranked.last.score, 3.5);
  });
}

void _opinionSuggestionTests() {
  test('a loved game overrides avoided genres and length limits', () {
    final gateway = MemoryShelf(const Shelf(games: [coop, bluff, epic]));
    final friends = MemoryFriends(
      const FriendCircle(
        friends: [
          Friend(
            id: 'a',
            name: 'Alex',
            avoidedGenres: ['bluff', 'strategy'],
            maxMinutes: 30,
            lovedGameIds: ['epic'],
          ),
          Friend(id: 'b', name: 'Léa'),
        ],
      ),
    );
    final ranked = SuggestGamesUseCase(gateway, friends)(['a', 'b']);
    expect(ranked.map((s) => s.game.id), ['epic']);
    expect(ranked.single.lovedBy, ['Alex']);
  });

  test('wishlists rank first and the time available filters', () {
    final gateway = MemoryShelf(const Shelf(games: [coop, bluff, epic]));
    final friends = MemoryFriends(
      const FriendCircle(
        friends: [
          Friend(id: 'a', name: 'Alex', wishedGameIds: ['epic']),
          Friend(id: 'b', name: 'Léa', likedGenres: ['party']),
        ],
      ),
    );
    final suggest = SuggestGamesUseCase(gateway, friends);
    final evening = suggest(['a', 'b']);
    expect(evening.first.game.id, 'epic');
    expect(evening.first.wishedBy, ['Alex']);
    expect(suggest(['a', 'b'], minutes: 60).map((s) => s.game.id), [
      'bluff',
      'coop',
    ]);
    expect(suggest([], minutes: 30).map((s) => s.game.id), ['bluff']);
  });
}

void _friendTests() {
  test('reviews replace the same reviewer for the same game', () async {
    final gateway = MemoryFriends();
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
    final gateway = MemoryFriends();
    final save = SaveFriendUseCase(gateway);
    await save(const Friend(id: '1', name: 'Alex'));
    expect(
      () => save(const Friend(id: '2', name: 'alex')),
      throwsA(FriendError.duplicate),
    );
  });

  test('removing a shelf game cleans friends refusals', () async {
    final gateway = MemoryShelf(const Shelf(games: [coop]));
    final friends = MemoryFriends(
      const FriendCircle(
        friends: [
          Friend(id: 'a', name: 'Alex', refusedGameIds: ['coop']),
        ],
      ),
    );
    await RemoveShelfGameUseCase(gateway, friends)('coop');
    expect(gateway.current.games, isEmpty);
    expect(friends.current.friends.single.refusedGameIds, isEmpty);
  });

  test('a game opinion is exclusive and survives a backup', () {
    final friend = const Friend(id: 'a', name: 'Alex')
        .withOpinion('coop', GameOpinion.wished)
        .withOpinion('coop', GameOpinion.loved);
    expect(friend.opinionOf('coop'), GameOpinion.loved);
    expect(friend.wishedGameIds, isEmpty);
    final restored = Friend.fromJson(
      jsonDecode(jsonEncode(friend.toJson())) as Map<String, dynamic>,
    );
    expect(restored.opinionOf('coop'), GameOpinion.loved);
    expect(
      Friend.fromJson({'id': 'b', 'name': 'Léa'}).opinionOf('coop'),
      GameOpinion.neutral,
    );
  });
}

void _storageTests() {
  test('workspace backups without shelf, friends or memories still load', () {
    final legacy =
        Map<String, dynamic>.from(jsonDecode(const Workspace().export()) as Map)
          ..removeWhere(
            (k, _) => ['shelf', 'friends', 'reviews', 'memories'].contains(k),
          );
    Workspace.fromJson(legacy);
    expect(Shelf.fromJson(legacy).games, isEmpty);
    expect(FriendCircle.fromJson(legacy).friends, isEmpty);
    const full = Shelf(games: [coop]);
    final again = Shelf.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(full.toJson())) as Map),
    );
    expect(again.games.single.name, 'Pandemic');
    const circle = FriendCircle(
      friends: [Friend(id: 'a', name: 'A')],
    );
    final circleAgain = FriendCircle.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(circle.toJson())) as Map),
    );
    expect(circleAgain.friends.single.name, 'A');
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
