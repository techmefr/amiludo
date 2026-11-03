import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ReadWorkspaceUseCase {
  ReadWorkspaceUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Workspace call() => _workspace.current;
}
