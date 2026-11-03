import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';

class SaveStyleProfileUseCase {
  SaveStyleProfileUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String name) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(
        profiles: [...data.profiles, StyleProfile(name, data.appearance)],
      ),
    );
  }
}
