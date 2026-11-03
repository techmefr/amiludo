import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/account_rules.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase(this._accounts);

  final AccountGateway _accounts;

  Future<void> call(String password) {
    final checked = checkedPassword(password);
    if (_accounts.current == null) throw AccountError.signInRequired;
    return _accounts.changePassword(checked);
  }
}
