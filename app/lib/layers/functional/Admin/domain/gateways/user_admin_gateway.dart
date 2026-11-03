import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';

abstract class UserAdminGateway {
  bool get available;

  Future<List<ManagedUser>> list();

  Future<ManagedUser> invite({required String email, required String name});

  Future<ManagedUser> setAdmin(String id, {required bool admin});

  Future<ManagedUser> setBlocked(String id, {required bool blocked});

  Future<void> remove(String id);
}
