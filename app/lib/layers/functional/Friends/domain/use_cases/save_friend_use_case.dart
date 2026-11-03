import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveFriendUseCase {
  SaveFriendUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(Friend friend) {
    final data = _workspace.current;
    final duplicate = data.friends.any(
      (f) =>
          f.id != friend.id &&
          f.name.toLowerCase() == friend.name.trim().toLowerCase(),
    );
    if (duplicate) throw FriendError.duplicate;
    return _workspace.save(
      data.copyWith(
        friends: [
          ...data.friends.where((f) => f.id != friend.id),
          friend,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
      ),
    );
  }
}
