import 'package:flutter/widgets.dart';

import 'package:amiludo/l10n/app_localizations.dart';

final _fallback = lookupAppLocalizations(const Locale('en'));

extension ContextL10n on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ?? _fallback;
}
