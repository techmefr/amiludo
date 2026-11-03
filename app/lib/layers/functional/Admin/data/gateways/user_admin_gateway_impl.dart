import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/domain/gateways/user_admin_gateway.dart';
import 'package:amiludo/layers/technical/Network/remote_config.dart';

class UserAdminGatewayImpl implements UserAdminGateway {
  static const function = 'admin-users';

  @override
  bool get available => RemoteConfig.configured;

  Future<Map<String, dynamic>> _call(Map<String, Object?> body) async {
    if (!available) throw AdminError.unavailable;
    try {
      final response = await RemoteConfig.client.functions.invoke(
        function,
        body: body,
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (error) {
      final details = error.details;
      final code = details is Map ? details['error'] : null;
      throw switch ((error.status, code)) {
        (401 || 403, _) => AdminError.forbidden,
        (_, 'self') => AdminError.self,
        (_, 'invalid_email') => AdminError.invalidEmail,
        _ => AdminError.rejected,
      };
    }
  }

  ManagedUser _user(Map<String, dynamic> data) =>
      ManagedUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));

  @override
  Future<List<ManagedUser>> list() async {
    final data = await _call({'action': 'list'});
    return [
      for (final user in data['users'] as List)
        ManagedUser.fromJson(Map<String, dynamic>.from(user as Map)),
    ];
  }

  @override
  Future<ManagedUser> invite({
    required String email,
    required String name,
  }) async => _user(
    await _call({
      'action': 'invite',
      'email': email,
      'name': name,
      'redirectTo': RemoteConfig.authRedirect,
    }),
  );

  @override
  Future<ManagedUser> setAdmin(String id, {required bool admin}) async =>
      _user(await _call({'action': 'role', 'id': id, 'admin': admin}));

  @override
  Future<ManagedUser> setBlocked(String id, {required bool blocked}) async =>
      _user(await _call({'action': 'block', 'id': id, 'blocked': blocked}));

  @override
  Future<void> remove(String id) => _call({'action': 'delete', 'id': id});
}
