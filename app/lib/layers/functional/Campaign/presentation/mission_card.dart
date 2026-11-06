import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_art.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.mission,
    required this.done,
    required this.unlocked,
    required this.onTap,
  });

  final Mission mission;
  final bool done, unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final texts = missionTexts(l, mission.id);
    final trailing = done
        ? Icons.check
        : unlocked
        ? Icons.chevron_right
        : Icons.lock_outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: DeckPanel(
        padding: Space.lg,
        highlight: unlocked && !done,
        child: InkWell(
          onTap: unlocked ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Targets.minimum),
            child: Row(
              children: [
                MissionArt(mission: mission),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(texts.title, style: theme.textTheme.titleMedium),
                      Text(
                        unlocked
                            ? l.campaignMinutes(mission.minutes)
                            : l.campaignLocked,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DeckIcon(trailing, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
