import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/technical/Network/remote_config.dart';

class AccountGatewayImpl implements AccountGateway {
  @override
  bool get available => RemoteConfig.configured;

  GoTrueClient get _auth {
    if (!available) throw const AccountUnavailable();
    return RemoteConfig.client.auth;
  }

  Account? _read(User? user) => user == null
      ? null
      : Account(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['name'] as String? ?? user.email ?? '',
        );

  @override
  Account? get current => available ? _read(_auth.currentUser) : null;

  @override
  Stream<Account?> watch() => available
      ? _auth.onAuthStateChange.map((event) => _read(event.session?.user))
      : const Stream.empty();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (error) {
      throw AccountFailure(error.message);
    }
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) => _guard(() async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    return response.session != null;
  });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> resetPassword(String email) =>
      _guard(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> signOut() => _guard(_auth.signOut);
}
