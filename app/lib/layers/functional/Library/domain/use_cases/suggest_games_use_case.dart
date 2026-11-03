import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class GameSuggestion {
  const GameSuggestion(this.game, this.score, this.averageStars);

  final ShelfGame game;
  final double score;
  final double? averageStars;
}

class SuggestGamesUseCase {
  SuggestGamesUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  List<GameSuggestion> call(List<String> friendIds) {
    final data = _workspace.current;
    final guests = data.friends.where((f) => friendIds.contains(f.id)).toList();
    final players = guests.length + 1;
    final suggestions = [
      for (final game in data.shelf)
        if (_acceptable(game, guests, players))
          _rate(game, guests, data.reviews),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return suggestions;
  }

  bool _acceptable(ShelfGame game, List<Friend> guests, int players) {
    if (guests.isNotEmpty && !game.fits(players)) return false;
    for (final friend in guests) {
      if (friend.refusedGameIds.contains(game.id)) return false;
      if (friend.avoidedGenres.any(game.genres.contains)) return false;
      if (friend.maxMinutes > 0 && game.minutes > friend.maxMinutes) {
        return false;
      }
    }
    return true;
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
    return GameSuggestion(game, guestAverage + liked * .5, average);
  }
}
