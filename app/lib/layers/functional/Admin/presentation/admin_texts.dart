import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

String adminErrorText(BuildContext context, AdminError error) =>
    switch (error) {
      AdminError.forbidden => tr(
        context,
        'Réservé aux administrateurs : reconnectez-vous si vous venez d’obtenir le rôle.',
        'Admins only: sign in again if you just got the role.',
      ),
      AdminError.invalidEmail => tr(
        context,
        'E-mail invalide',
        'Invalid email',
      ),
      AdminError.self => tr(
        context,
        'Impossible sur votre propre compte.',
        'Not possible on your own account.',
      ),
      AdminError.rejected => tr(
        context,
        'Le serveur a refusé l’opération.',
        'The server refused the operation.',
      ),
      AdminError.unavailable => tr(
        context,
        'Serveur non configuré',
        'No server configured',
      ),
      AdminError.unreachable => tr(
        context,
        'Connexion impossible',
        'Could not connect',
      ),
    };

String adminNoticeText(
  BuildContext context,
  AdminNotice notice,
) => switch (notice) {
  AdminNotice.invited => tr(context, 'Invitation envoyée', 'Invitation sent'),
  AdminNotice.updated => tr(context, 'Compte mis à jour', 'Account updated'),
  AdminNotice.removed => tr(context, 'Compte supprimé', 'Account deleted'),
};

String lastSeenText(BuildContext context, ManagedUser user) {
  final texts = MaterialLocalizations.of(context);
  final at = user.lastSignInAt?.toLocal();
  if (at == null) {
    return tr(context, 'Jamais connecté', 'Never signed in');
  }
  return tr(
    context,
    'Dernière connexion : ${texts.formatMediumDate(at)}',
    'Last sign-in: ${texts.formatMediumDate(at)}',
  );
}
