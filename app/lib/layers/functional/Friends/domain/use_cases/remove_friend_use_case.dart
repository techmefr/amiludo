import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveFriendUseCase {
  RemoveFriendUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String id) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(friends: data.friends.where((f) => f.id != id).toList()),
    );
  }
}
