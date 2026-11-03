import 'package:amiludo/layers/functional/Account/domain/use_cases/account_rules.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveNicknameUseCase {
  SaveNicknameUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String name) {
    final data = _workspace.current;
    return _workspace.save(data.copyWith(nickname: checkedName(name)));
  }
}
