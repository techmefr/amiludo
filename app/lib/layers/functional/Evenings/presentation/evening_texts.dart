import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

String eveningWhen(BuildContext context, DateTime startsAt) {
  final local = startsAt.toLocal();
  final texts = MaterialLocalizations.of(context);
  return '${texts.formatFullDate(local)} · ${texts.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
}

String answerLabel(BuildContext context, RsvpAnswer answer) => switch (answer) {
  RsvpAnswer.yes => tr(context, 'Je viens', 'I’m in'),
  RsvpAnswer.maybe => tr(context, 'Peut-être', 'Maybe'),
  RsvpAnswer.no => tr(context, 'Pas cette fois', 'Not this time'),
};

String seatsLine(BuildContext context, Evening evening) {
  final going = evening.going.length + 1;
  final waiting = evening.waitlist.length;
  final base = evening.seats <= 0
      ? tr(context, '$going inscrits', '$going going')
      : tr(
          context,
          '$going/${evening.seats} places',
          '$going/${evening.seats} seats',
        );
  return waiting == 0
      ? base
      : tr(context, '$base · $waiting en attente', '$base · $waiting waiting');
}

String eveningErrorText(BuildContext context, Object error) => switch (error) {
  EveningError.hostOnly => tr(context, 'Réservé à l’hôte', 'Host only'),
  AccountError.signInRequired => tr(
    context,
    'Connectez-vous d’abord',
    'Sign in first',
  ),
  AccountUnavailable() => tr(
    context,
    'Serveur non configuré',
    'No server configured',
  ),
  FormatException(:final message) => message,
  _ => tr(
    context,
    'Action impossible : vérifiez la connexion et votre compte.',
    'Could not do it: check the connection and your account.',
  ),
};
