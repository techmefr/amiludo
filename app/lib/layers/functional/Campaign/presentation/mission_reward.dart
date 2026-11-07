import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_progress.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_art.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class MissionReward extends StatelessWidget {
  const MissionReward({
    super.key,
    required this.mission,
    required this.progress,
  });

  final Mission mission;
  final CampaignProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final next = progress.next;
    return DeckPanel(
      highlight: true,
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DeckIcon(
                  missionBadgeIcon(mission.id),
                  size: TypeScale.display,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.campaignBadgeEarned,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        missionTexts(l, mission.id).badge,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress.finished) ...[
              const SizedBox(height: Space.lg),
              Text(l.campaignFinale(campaignUniverse)),
            ],
            const SizedBox(height: Space.lg),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                if (next != null)
                  FilledButton(
                    onPressed: () =>
                        context.pushReplacement('/campaign/${next.id}'),
                    child: Text(l.campaignNext),
                  ),
                OutlinedButton(
                  onPressed: () => context.go('/campaign'),
                  child: Text(l.campaignToList),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
