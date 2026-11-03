import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveShelfGameUseCase {
  SaveShelfGameUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(ShelfGame game) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(shelf: [game, ...data.shelf.where((g) => g.id != game.id)]),
    );
  }
}
