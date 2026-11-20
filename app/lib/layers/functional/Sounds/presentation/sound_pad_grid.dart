import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/sound_colors.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SoundPadGrid extends StatelessWidget {
  const SoundPadGrid({
    super.key,
    required this.set,
    required this.pads,
    required this.sets,
  });

  final SoundSet set;
  final PadPlayer pads;
  final SoundSetUseCases sets;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = [
      for (final id in set.soundboard)
        if (set.entry(id) != null) set.entry(id)!,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.soundboardPads,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            OutlinedButton.icon(
              onPressed: pads.stopAll,
              icon: const DeckIcon(Icons.stop),
              label: Text(l.soundboardStopAll),
            ),
          ],
        ),
        Slider(
          value: set.soundboardVolume,
          label: l.soundboardPadsVolume,
          semanticFormatterCallback: (v) =>
              '${l.soundboardPadsVolume} ${(v * 100).round()}%',
          onChanged: (v) {
            pads.setVolume(v);
            sets.configure(set.id, soundboardVolume: v);
          },
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Text(l.soundboardPadsEmpty),
          )
        else
          ListenableBuilder(
            listenable: pads,
            builder: (context, _) => Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [for (final entry in entries) _pad(context, entry)],
            ),
          ),
      ],
    );
  }

  Widget _pad(BuildContext context, SoundEntry entry) {
    final active = pads.isActive(entry.id);
    final color = soundColor(context, entry.color);
    final on = soundColorOn(context, entry.color);
    return Semantics(
      button: true,
      toggled: entry.loop ? active : null,
      label: entry.name,
      child: SizedBox(
        width: 112,
        height: 104,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: active ? color : color.withValues(alpha: .75),
            foregroundColor: on,
            minimumSize: const Size.square(Targets.minimum),
            padding: const EdgeInsets.all(Space.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.md),
            ),
          ),
          onPressed: () => pads.trigger(set, entry),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DeckIcon(entry.loop ? Icons.repeat : Icons.play_arrow, color: on),
              Text(
                entry.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
