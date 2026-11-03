import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class EraseWorkspaceUseCase {
  EraseWorkspaceUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call() => _workspace.save(const Workspace());
}
