import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveShelfGameUseCase {
  RemoveShelfGameUseCase(this._workspace, this._friends);

  final WorkspaceGateway _workspace;
  final FriendsGateway _friends;

  Future<void> call(String id) async {
    final data = _workspace.current;
    final circle = _friends.current;
    await _workspace.save(
      data.copyWith(shelf: data.shelf.where((g) => g.id != id).toList()),
    );
    await _friends.save(
      circle.copyWith(
        friends: [
          for (final f in circle.friends)
            f.withOpinion(id, GameOpinion.neutral),
        ],
      ),
    );
  }
}
