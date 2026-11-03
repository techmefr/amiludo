import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class WatchSaveFailuresUseCase {
  WatchSaveFailuresUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Stream<bool> call() => _workspace.saveFailures;
}
