import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/change_password_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/send_sign_in_link_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/verify_email_code_use_case.dart';

import 'network_fakes.dart';

void main() {
  test('a sign-in link goes to a cleaned email', () async {
    final accounts = FakeAccounts();
    await SendSignInLinkUseCase(accounts)('  Lea@Example.org ');
    expect(accounts.links, ['lea@example.org']);
    expect(
      () => SendSignInLinkUseCase(accounts)('not-an-email'),
      throwsA(AccountError.invalidEmail),
    );
  });

  test('the emailed code signs in and must be digits', () async {
    final accounts = FakeAccounts();
    final verify = VerifyEmailCodeUseCase(accounts);
    expect(
      () => verify(email: 'lea@example.org', code: 'abc'),
      throwsA(AccountError.invalidCode),
    );
    expect(accounts.current, isNull);
    await verify(email: 'lea@example.org', code: '1234 5678');
    expect(accounts.current?.email, 'lea@example.org');
  });

  test('changing the password needs a session and a strong password', () async {
    final accounts = FakeAccounts();
    final change = ChangePasswordUseCase(accounts);
    expect(() => change('longenough'), throwsA(AccountError.signInRequired));
    accounts.current = const Account(id: 'u', email: 'a@b.co', name: 'A');
    expect(() => change('short'), throwsA(AccountError.invalidPassword));
    await change('longenough');
    expect(accounts.passwords, ['longenough']);
  });
}
