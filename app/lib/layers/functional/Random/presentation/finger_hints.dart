import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

bool get fingerOnDesktopWeb =>
    kIsWeb &&
    const {
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);

String fingerHint(
  BuildContext context, {
  required bool drawn,
  required bool simulated,
  required bool touching,
}) {
  final l = context.l10n;
  if (drawn) return simulated ? l.fingerClickToRestart : l.fingerLiftToRestart;
  return touching ? l.randomChoosing : l.randomPlaceYourFingersHere;
}
