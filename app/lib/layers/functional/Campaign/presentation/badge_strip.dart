import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_art.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class BadgeStrip extends StatelessWidget {
  const BadgeStrip({super.key, required this.progress});

  final CampaignProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final earned = [
      for (final mission in campaignMissions)
        if (progress.isDone(mission.id)) mission,
    ];
    if (earned.isEmpty) return Text(l.campaignNoBadges);
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final mission in earned)
          Chip(
            avatar: DeckIcon(
              missionBadgeIcon(mission.id),
              color: scheme.accentInk,
            ),
            label: Text(missionTexts(l, mission.id).badge),
          ),
      ],
    );
  }
}
