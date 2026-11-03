import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class LoadWorkspaceUseCase {
  LoadWorkspaceUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<Workspace> call() => _workspace.load();
}
