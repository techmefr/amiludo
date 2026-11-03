import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

String accountErrorText(
  BuildContext context,
  AccountError error,
) => switch (error) {
  AccountError.invalidEmail => tr(context, 'E-mail invalide', 'Invalid email'),
  AccountError.invalidPassword => tr(
    context,
    'Mot de passe : 8 caractères minimum',
    'Password: at least 8 characters',
  ),
  AccountError.invalidName => tr(context, 'Prénom invalide', 'Invalid name'),
  AccountError.invalidCode => tr(
    context,
    'Code invalide : recopiez les chiffres de l’e-mail.',
    'Invalid code: type the digits from the email.',
  ),
  AccountError.signInRequired => tr(
    context,
    'Connectez-vous d’abord',
    'Sign in first',
  ),
  AccountError.rejected => tr(
    context,
    'Le serveur a refusé la demande : vérifiez l’e-mail et le mot de passe.',
    'The server refused: check the email and password.',
  ),
  AccountError.unavailable => tr(
    context,
    'Serveur non configuré',
    'No server configured',
  ),
  AccountError.unreachable => tr(
    context,
    'Connexion impossible',
    'Could not connect',
  ),
};
