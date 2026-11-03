import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveCharacterUseCase {
  RemoveCharacterUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String id) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        characters: data.characters.where((c) => c.id != id).toList(),
      ),
    );
  }
}
