import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class GameSuggestion {
  const GameSuggestion(
    this.game,
    this.score,
    this.averageStars, {
    this.wishedBy = const [],
    this.lovedBy = const [],
  });

  final ShelfGame game;
  final double score;
  final double? averageStars;
  final List<String> wishedBy, lovedBy;
}

class SuggestGamesUseCase {
  SuggestGamesUseCase(this._library, this._friends);

  final LibraryGateway _library;
  final FriendsGateway _friends;

  List<GameSuggestion> call(List<String> friendIds, {int minutes = 0}) {
    final circle = _friends.current;
    final guests = circle.friends
        .where((f) => friendIds.contains(f.id))
        .toList();
    final players = guests.length + 1;
    final suggestions = [
      for (final game in _library.current.games)
        if (minutes <= 0 || game.minutes <= minutes)
          if (_acceptable(game, guests, players))
            _rate(game, guests, circle.reviews),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return suggestions;
  }

  bool _acceptable(ShelfGame game, List<Friend> guests, int players) {
    if (guests.isNotEmpty && !game.fits(players)) return false;
    return guests.every((friend) => _accepts(friend, game));
  }

  bool _accepts(Friend friend, ShelfGame game) {
    final opinion = friend.opinionOf(game.id);
    if (opinion == GameOpinion.refused) return false;
    if (opinion != GameOpinion.neutral) return true;
    if (friend.avoidedGenres.any(game.genres.contains)) return false;
    return friend.maxMinutes <= 0 || game.minutes <= friend.maxMinutes;
  }

  GameSuggestion _rate(
    ShelfGame game,
    List<Friend> guests,
    List<GameReview> reviews,
  ) {
    final names = guests.map((f) => f.name.toLowerCase()).toSet();
    final concerned = reviews
        .where((r) => r.concerns(game.name, game.templateIds))
        .toList();
    final byGuests = concerned.where(
      (r) => names.contains(r.reviewer.toLowerCase()),
    );
    final average = averageStars(concerned);
    final guestAverage = averageStars(byGuests) ?? average ?? 3;
    final liked = guests.fold<int>(
      0,
      (sum, f) => sum + f.likedGenres.where(game.genres.contains).length,
    );
    List<String> who(GameOpinion opinion) => [
      for (final f in guests)
        if (f.opinionOf(game.id) == opinion) f.name,
    ];
    final wishedBy = who(GameOpinion.wished);
    final lovedBy = who(GameOpinion.loved);
    final score =
        guestAverage + liked * .5 + wishedBy.length * 1.5 + lovedBy.length;
    return GameSuggestion(
      game,
      score,
      average,
      wishedBy: wishedBy,
      lovedBy: lovedBy,
    );
  }
}
