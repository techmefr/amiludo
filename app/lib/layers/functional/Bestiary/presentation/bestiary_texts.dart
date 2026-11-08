import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Bestiary/domain/entities/creature.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

extension BestiaryTexts on BuildContext {
  String creatureKindLabel(CreatureKind kind) => switch (kind) {
    CreatureKind.npc => l10n.bestiaryNpc,
    CreatureKind.monster => l10n.bestiaryMonster,
    CreatureKind.treasure => l10n.bestiaryTreasure,
  };
}

IconData creatureKindIcon(CreatureKind kind) => switch (kind) {
  CreatureKind.npc => Icons.person_outline,
  CreatureKind.monster => Icons.pest_control_outlined,
  CreatureKind.treasure => Icons.diamond_outlined,
};
