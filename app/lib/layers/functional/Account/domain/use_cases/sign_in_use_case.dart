import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/account_rules.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SignInUseCase {
  SignInUseCase(this._accounts, this._workspace);

  final AccountGateway _accounts;
  final WorkspaceGateway _workspace;

  Future<void> call({required String email, required String password}) async {
    await _accounts.signIn(email: checkedEmail(email), password: password);
    final account = _accounts.current;
    final data = _workspace.current;
    if (account != null && data.nickname.isEmpty) {
      await _workspace.save(data.copyWith(nickname: account.name));
    }
  }
}
