import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ReorderFavoriteToolsUseCase {
  ReorderFavoriteToolsUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String tool, String before) {
    final data = _workspace.current;
    if (tool == before || !data.favorites.contains(tool)) return Future.value();
    final rest = data.favorites.where((t) => t != tool).toList();
    final at = rest.indexOf(before);
    rest.insert(at < 0 ? rest.length : at, tool);
    return _workspace.save(data.copyWith(favorites: rest));
  }
}
