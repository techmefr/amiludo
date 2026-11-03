import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SetResourceUseCase {
  SetResourceUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String playerId, String key, double value) {
    final name = key.trim();
    if (name.isEmpty || name.length > 40 || !value.isFinite) {
      throw const FormatException('Compteur invalide');
    }
    final data = _workspace.current;
    final game = data.current;
    if (game == null) throw StateError('Aucune partie en cours');
    return _workspace.save(
      data.withGame(
        game.updatePlayer(playerId, (p) => p.withResource(name, value)),
      ),
    );
  }
}
