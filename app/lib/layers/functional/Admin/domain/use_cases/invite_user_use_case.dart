import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/domain/gateways/user_admin_gateway.dart';

class InviteUserUseCase {
  InviteUserUseCase(this._users);

  final UserAdminGateway _users;

  Future<ManagedUser> call({required String email, String name = ''}) {
    final clean = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(clean)) {
      throw AdminError.invalidEmail;
    }
    final trimmed = name.trim();
    return _users.invite(
      email: clean,
      name: trimmed.length > 40 ? trimmed.substring(0, 40) : trimmed,
    );
  }
}
