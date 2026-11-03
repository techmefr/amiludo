import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/account_rules.dart';

class VerifyEmailCodeUseCase {
  VerifyEmailCodeUseCase(this._accounts);

  final AccountGateway _accounts;

  Future<void> call({required String email, required String code}) =>
      _accounts.verifyCode(email: checkedEmail(email), code: checkedCode(code));
}
