import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ToggleFavoriteToolUseCase {
  ToggleFavoriteToolUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String tool) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        favorites: data.favorites.contains(tool)
            ? data.favorites.where((t) => t != tool).toList()
            : [...data.favorites, tool],
      ),
    );
  }
}
