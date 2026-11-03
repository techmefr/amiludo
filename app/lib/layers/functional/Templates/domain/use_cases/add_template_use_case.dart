import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class AddTemplateUseCase {
  AddTemplateUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(GameTemplate template) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        templates: [
          template,
          ...data.templates.where((t) => t.id != template.id),
        ],
      ),
    );
  }
}
