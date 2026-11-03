import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveTemplateUseCase {
  RemoveTemplateUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String id) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        templates: data.templates.where((t) => t.id != id).toList(),
      ),
    );
  }
}
