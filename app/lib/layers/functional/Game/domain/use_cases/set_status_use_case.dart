import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SetStatusUseCase {
  SetStatusUseCase(this._workspace);

  static const maxStacks = 99;

  final WorkspaceGateway _workspace;

  Future<void> call(String playerId, String status, int stacks) {
    final data = _workspace.current;
    final game = data.current;
    if (game == null) throw StateError('Aucune partie en cours');
    return _workspace.save(
      data.withGame(
        game.updatePlayer(
          playerId,
          (p) => p.withStatus(status, stacks.clamp(0, maxStacks)),
        ),
      ),
    );
  }
}
