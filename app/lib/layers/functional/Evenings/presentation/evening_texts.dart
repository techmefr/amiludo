import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

String eveningWhen(BuildContext context, DateTime startsAt) {
  final local = startsAt.toLocal();
  final texts = MaterialLocalizations.of(context);
  return '${texts.formatFullDate(local)} · ${texts.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
}

String answerLabel(BuildContext context, RsvpAnswer answer) => switch (answer) {
  RsvpAnswer.yes => context.l10n.eveningsIMIn,
  RsvpAnswer.maybe => context.l10n.eveningsMaybe,
  RsvpAnswer.no => context.l10n.eveningsNotThisTime,
};

String seatsLine(BuildContext context, Evening evening) {
  final going = evening.going.length + 1;
  final waiting = evening.waitlist.length;
  final base = evening.seats <= 0
      ? context.l10n.eveningsGoing2(going)
      : context.l10n.eveningsSeats(going, evening.seats);
  return waiting == 0
      ? base
      : context.l10n.eveningsWaiting(base, waiting);
}

String eveningErrorText(BuildContext context, Object error) => switch (error) {
  EveningError.hostOnly => context.l10n.eveningsHostOnly,
  AccountError.signInRequired => context.l10n.accountSignInFirst,
  AccountUnavailable() => context.l10n.accountNoServerConfigured,
  FormatException(:final message) => message,
  _ => context.l10n.eveningsCouldNotDoItCheck,
};
