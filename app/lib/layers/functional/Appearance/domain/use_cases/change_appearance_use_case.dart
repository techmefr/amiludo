import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';

class ChangeAppearanceUseCase {
  ChangeAppearanceUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(Appearance appearance) =>
      _workspace.save(_workspace.current.copyWith(appearance: appearance));
}
