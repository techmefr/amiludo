import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveGameUseCase {
  SaveGameUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(GameSession game) =>
      _workspace.save(_workspace.current.withGame(game));
}
