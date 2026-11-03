class Account {
  const Account({required this.id, required this.email, required this.name});

  final String id, email, name;
}

class AccountFailure implements Exception {
  const AccountFailure(this.message);

  final String message;
}

class AccountUnavailable implements Exception {
  const AccountUnavailable();
}
