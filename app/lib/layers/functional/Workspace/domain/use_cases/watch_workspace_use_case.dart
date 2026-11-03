import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class WatchWorkspaceUseCase {
  WatchWorkspaceUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Stream<Workspace> call() => _workspace.changes;
}
