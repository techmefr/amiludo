import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/badge_strip.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/cubit/campaign_cubit.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_card.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final progress = context.watch<CampaignCubit>().state;
    return FullPage(
      title: l.campaignTitle,
      fallback: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.campaignSubtitle(campaignUniverse),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Space.lg),
          Text(
            l.campaignProgress(progress.doneCount, campaignMissions.length),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: Space.sm),
          LinearProgressIndicator(
            value: progress.doneCount / campaignMissions.length,
            minHeight: Space.sm,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          const SizedBox(height: Space.xl),
          for (final mission in campaignMissions)
            MissionCard(
              mission: mission,
              done: progress.isDone(mission.id),
              unlocked: progress.isUnlocked(mission),
              onTap: () => context.push('/campaign/${mission.id}'),
            ),
          SectionHeading(l.campaignBadges),
          BadgeStrip(progress: progress),
          if (progress.finished) ...[
            const SizedBox(height: Space.lg),
            DeckPanel(
              highlight: true,
              child: Text(l.campaignFinale(campaignUniverse)),
            ),
            const SizedBox(height: Space.md),
            TextButton(
              onPressed: context.read<CampaignCubit>().reset,
              child: Text(l.campaignReset),
            ),
          ],
        ],
      ),
    );
  }
}
