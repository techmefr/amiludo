import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_rarity.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

extension CardPackLabels on BuildContext {
  String rarityLabel(CardRarity rarity) => switch (rarity) {
    CardRarity.common => l10n.cpRarityCommon,
    CardRarity.rare => l10n.cpRarityRare,
    CardRarity.holo => l10n.cpRarityHolo,
    CardRarity.ultra => l10n.cpRarityUltra,
  };

  String issueLabel(RulesIssue issue) => switch (issue) {
    RulesIssue.noPlayers => l10n.cpIssueNoPlayers,
    RulesIssue.noDecks => l10n.cpIssueNoDecks,
    RulesIssue.poolTooSmall => l10n.cpIssuePoolTooSmall,
    RulesIssue.keepAbovePack => l10n.cpIssueKeepAbovePack,
    RulesIssue.keepInvalid => l10n.cpIssueKeepInvalid,
  };
}

IconData rarityIcon(CardRarity rarity) => switch (rarity) {
  CardRarity.common => Icons.circle_outlined,
  CardRarity.rare => Icons.diamond_outlined,
  CardRarity.holo => Icons.auto_awesome,
  CardRarity.ultra => Icons.stars,
};

double rarityWeight(CardRarity rarity) => switch (rarity) {
  CardRarity.common => .2,
  CardRarity.rare => .5,
  CardRarity.holo => .8,
  CardRarity.ultra => .98,
};
