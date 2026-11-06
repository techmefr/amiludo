import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Campaign/presentation/mission_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class MissionChoiceStep extends StatelessWidget {
  const MissionChoiceStep({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final choices = missionChoices(l);
    final chosen = selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(l.campaignChoose),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (var i = 0; i < choices.length; i++)
              ChoiceChip(
                label: Text(choices[i].label),
                selected: chosen == i,
                onSelected: (_) => onSelected(i),
              ),
          ],
        ),
        if (chosen != null) ...[
          const SizedBox(height: Space.md),
          Semantics(liveRegion: true, child: Text(choices[chosen].outcome)),
        ],
      ],
    );
  }
}
