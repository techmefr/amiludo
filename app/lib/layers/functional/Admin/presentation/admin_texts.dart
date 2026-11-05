import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Admin/domain/entities/managed_user.dart';
import 'package:amiludo/layers/functional/Admin/presentation/cubit/admin_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

String adminErrorText(BuildContext context, AdminError error) =>
    switch (error) {
      AdminError.forbidden => context.l10n.adminAdminsOnlySignInAgain,
      AdminError.invalidEmail => context.l10n.accountInvalidEmail,
      AdminError.self => context.l10n.adminNotPossibleOnYourOwn,
      AdminError.rejected => context.l10n.adminTheServerRefusedTheOperation,
      AdminError.unavailable => context.l10n.accountNoServerConfigured,
      AdminError.unreachable => context.l10n.accountCouldNotConnect,
    };

String adminNoticeText(BuildContext context, AdminNotice notice) =>
    switch (notice) {
      AdminNotice.invited => context.l10n.adminInvitationSent,
      AdminNotice.updated => context.l10n.adminAccountUpdated,
      AdminNotice.removed => context.l10n.adminAccountDeleted,
    };

String lastSeenText(BuildContext context, ManagedUser user) {
  final texts = MaterialLocalizations.of(context);
  final at = user.lastSignInAt?.toLocal();
  if (at == null) {
    return context.l10n.adminNeverSignedIn;
  }
  return context.l10n.adminLastSignIn(texts.formatMediumDate(at));
}
