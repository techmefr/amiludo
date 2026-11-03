class Account {
  const Account({
    required this.id,
    required this.email,
    required this.name,
    this.admin = false,
  });

  final String id, email, name;
  final bool admin;
}

enum AccountError implements Exception {
  invalidEmail,
  invalidPassword,
  invalidName,
  invalidCode,
  signInRequired,
  rejected,
  unavailable,
  unreachable,
}

class AccountFailure implements Exception {
  const AccountFailure(this.message);

  final String message;
}

class AccountUnavailable implements Exception {
  const AccountUnavailable();
}
