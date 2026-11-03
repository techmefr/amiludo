import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';

class SaveReviewsUseCase {
  SaveReviewsUseCase(this._friends);

  final FriendsGateway _friends;

  Future<void> call(String sessionId, List<GameReview> reviews) {
    final circle = _friends.current;
    final reviewers = reviews.map((r) => r.reviewer.toLowerCase()).toSet();
    return _friends.save(
      circle.copyWith(
        reviews: [
          ...circle.reviews.where(
            (r) =>
                r.sessionId != sessionId ||
                !reviewers.contains(r.reviewer.toLowerCase()),
          ),
          ...reviews,
        ],
      ),
    );
  }
}
