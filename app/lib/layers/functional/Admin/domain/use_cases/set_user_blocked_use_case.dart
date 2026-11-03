import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/domain/gateways/user_admin_gateway.dart';

class SetUserBlockedUseCase {
  SetUserBlockedUseCase(this._users, this._accounts);

  final UserAdminGateway _users;
  final AccountGateway _accounts;

  Future<ManagedUser> call(ManagedUser user) {
    if (user.id == _accounts.current?.id) throw AdminError.self;
    return _users.setBlocked(user.id, blocked: !user.blocked);
  }
}
