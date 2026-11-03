import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveCharacterUseCase {
  SaveCharacterUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(GameCharacter character) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        characters: [
          character,
          ...data.characters.where((c) => c.id != character.id),
        ],
      ),
    );
  }
}
