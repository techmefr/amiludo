import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class AddScoreUseCase {
  AddScoreUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String player, double value, String category) {
    final data = _workspace.current;
    return _workspace.save(
      data.withGame(data.current!.addScore(player, value, category)),
    );
  }
}
