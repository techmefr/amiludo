import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/account_rules.dart';

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._accounts);

  final AccountGateway _accounts;

  Future<void> call(String email) =>
      _accounts.resetPassword(checkedEmail(email));
}
