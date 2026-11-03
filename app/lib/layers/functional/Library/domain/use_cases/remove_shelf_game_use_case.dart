import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveShelfGameUseCase {
  RemoveShelfGameUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String id) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        shelf: data.shelf.where((g) => g.id != id).toList(),
        friends: [
          for (final f in data.friends) f.withOpinion(id, GameOpinion.neutral),
        ],
      ),
    );
  }
}
