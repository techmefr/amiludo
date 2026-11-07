import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RememberToolUseCase {
  RememberToolUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String tool) {
    final data = _workspace.current;
    if (data.lastTool == tool) return Future.value();
    return _workspace.save(data.copyWith(lastTool: tool));
  }
}
