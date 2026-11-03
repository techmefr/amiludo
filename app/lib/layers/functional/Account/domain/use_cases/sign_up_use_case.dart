import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/account_rules.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SignUpUseCase {
  SignUpUseCase(this._accounts, this._workspace);

  final AccountGateway _accounts;
  final WorkspaceGateway _workspace;

  Future<bool> call({
    required String email,
    required String password,
    required String name,
  }) async {
    final cleanName = checkedName(name);
    final confirmed = await _accounts.signUp(
      email: checkedEmail(email),
      password: checkedPassword(password),
      name: cleanName,
    );
    final data = _workspace.current;
    if (data.nickname.isEmpty) {
      await _workspace.save(data.copyWith(nickname: cleanName));
    }
    return confirmed;
  }
}
