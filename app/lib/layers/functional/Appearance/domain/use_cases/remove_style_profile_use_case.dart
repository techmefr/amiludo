import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveStyleProfileUseCase {
  RemoveStyleProfileUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(int index) {
    final data = _workspace.current;
    return _workspace.save(
      data.copyWith(profiles: [...data.profiles]..removeAt(index)),
    );
  }
}
