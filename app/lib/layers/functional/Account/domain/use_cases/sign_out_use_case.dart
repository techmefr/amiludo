import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';

class SignOutUseCase {
  SignOutUseCase(this._accounts);

  final AccountGateway _accounts;

  Future<void> call() => _accounts.signOut();
}
