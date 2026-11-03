import 'package:amiludo/layers/functional/Memories/domain/entities/game_memory.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveMemoryUseCase {
  SaveMemoryUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(GameMemory memory) =>
      _workspace.save(_workspace.current.withMemory(memory));
}
