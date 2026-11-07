import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/cubit/campaign_cubit.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_art.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_choice.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_reward.dart';
import 'package:amiludo/layers/functional/Campaign/presentation/mission_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({
    super.key,
    required this.mission,
    required this.actions,
  });

  final Mission mission;
  final Map<MissionAction, WidgetBuilder> actions;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int? choice;

  Mission get mission => widget.mission;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final progress = context.watch<CampaignCubit>().state;
    final texts = missionTexts(l, mission.id);
    final done = progress.isDone(mission.id);
    final ready = !mission.hasChoice || choice != null;
    return FullPage(
      title: texts.title,
      fallback: '/campaign',
      child: !progress.isUnlocked(mission)
          ? EmptyPanel(
              icon: Icons.lock_outline,
              title: texts.title,
              message: l.campaignLocked,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MissionArt(mission: mission, height: 96),
                const SizedBox(height: Space.lg),
                Text(texts.story, style: theme.textTheme.bodyLarge),
                const SizedBox(height: Space.lg),
                DeckPanel(
                  padding: Space.lg,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeckIcon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.campaignConcept,
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(texts.lesson),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SectionHeading(l.campaignYourTurn),
                Text(texts.task),
                const SizedBox(height: Space.lg),
                widget.actions[mission.action]!(context),
                if (mission.hasChoice)
                  MissionChoiceStep(
                    selected: done ? progress.choices[mission.id] : choice,
                    onSelected: (value) => setState(() => choice = value),
                  ),
                const SizedBox(height: Space.xl),
                if (done)
                  MissionReward(mission: mission, progress: progress)
                else
                  FilledButton(
                    onPressed: ready
                        ? () => context.read<CampaignCubit>().complete(
                            mission,
                            choice: choice,
                          )
                        : null,
                    child: Text(l.campaignComplete),
                  ),
              ],
            ),
    );
  }
}
