String checkedEmail(String email) {
  final clean = email.trim().toLowerCase();
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(clean)) {
    throw const FormatException('E-mail invalide');
  }
  return clean;
}

String checkedPassword(String password) {
  if (password.length < 8 || password.length > 128) {
    throw const FormatException('Mot de passe : 8 caractères minimum');
  }
  return password;
}

String checkedName(String name) {
  final clean = name.trim();
  if (clean.isEmpty || clean.length > 40) {
    throw const FormatException('Prénom invalide');
  }
  return clean;
}
