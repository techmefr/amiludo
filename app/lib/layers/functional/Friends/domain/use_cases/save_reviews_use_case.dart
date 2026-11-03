import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveReviewsUseCase {
  SaveReviewsUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String sessionId, List<GameReview> reviews) {
    final data = _workspace.current;
    final reviewers = reviews.map((r) => r.reviewer.toLowerCase()).toSet();
    return _workspace.save(
      data.copyWith(
        reviews: [
          ...data.reviews.where(
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
