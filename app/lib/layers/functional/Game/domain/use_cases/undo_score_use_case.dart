import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class UndoScoreUseCase {
  UndoScoreUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call() {
    final data = _workspace.current;
    return _workspace.save(data.withGame(data.current!.undo()));
  }
}
