import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/domain/gateways/user_admin_gateway.dart';

class ListUsersUseCase {
  ListUsersUseCase(this._users);

  final UserAdminGateway _users;

  bool get available => _users.available;

  Future<List<ManagedUser>> call() async {
    final users = await _users.list();
    return [...users]..sort((a, b) {
      if (a.admin != b.admin) return a.admin ? -1 : 1;
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
  }
}
