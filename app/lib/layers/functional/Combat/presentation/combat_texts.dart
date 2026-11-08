import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

extension CombatTexts on BuildContext {
  String combatCondition(String key) {
    final l = l10n;
    return switch (key) {
      'blinded' => l.combatCondBlinded,
      'charmed' => l.combatCondCharmed,
      'frightened' => l.combatCondFrightened,
      'hidden' => l.combatCondHidden,
      'paralyzed' => l.combatCondParalyzed,
      'poisoned' => l.combatCondPoisoned,
      'prone' => l.combatCondProne,
      'stunned' => l.combatCondStunned,
      _ => key,
    };
  }
}
