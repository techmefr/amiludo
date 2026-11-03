import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';

String checkedEmail(String email) {
  final clean = email.trim().toLowerCase();
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(clean)) {
    throw AccountError.invalidEmail;
  }
  return clean;
}

String checkedPassword(String password) {
  if (password.length < 8 || password.length > 128) {
    throw AccountError.invalidPassword;
  }
  return password;
}

String checkedCode(String code) {
  final clean = code.replaceAll(RegExp(r'\s'), '');
  if (!RegExp(r'^\d{6,10}$').hasMatch(clean)) throw AccountError.invalidCode;
  return clean;
}

String checkedName(String name) {
  final clean = name.trim();
  if (clean.isEmpty || clean.length > 40) {
    throw AccountError.invalidName;
  }
  return clean;
}
