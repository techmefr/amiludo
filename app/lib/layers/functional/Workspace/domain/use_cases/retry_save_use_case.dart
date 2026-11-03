import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RetrySaveUseCase {
  RetrySaveUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call() => _workspace.save(_workspace.current);
}
