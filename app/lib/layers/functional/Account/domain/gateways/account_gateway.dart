import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';

abstract class AccountGateway {
  bool get available;

  Account? get current;

  Stream<Account?> watch();

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> resetPassword(String email);

  Future<void> signOut();
}
