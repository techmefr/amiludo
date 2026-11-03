import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';

class WatchAccountUseCase {
  WatchAccountUseCase(this._accounts);

  final AccountGateway _accounts;

  bool get available => _accounts.available;

  Account? get current => _accounts.current;

  Stream<Account?> call() => _accounts.watch();
}
