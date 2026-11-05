import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

String accountErrorText(
  BuildContext context,
  AccountError error,
) => switch (error) {
  AccountError.invalidEmail => context.l10n.accountInvalidEmail,
  AccountError.invalidPassword => context.l10n.accountPasswordAtLeast8Characters,
  AccountError.invalidName => context.l10n.accountInvalidName,
  AccountError.invalidCode => context.l10n.accountInvalidCodeTypeTheDigits,
  AccountError.signInRequired => context.l10n.accountSignInFirst,
  AccountError.rejected => context.l10n.accountTheServerRefusedCheckThe,
  AccountError.unavailable => context.l10n.accountNoServerConfigured,
  AccountError.unreachable => context.l10n.accountCouldNotConnect,
};
