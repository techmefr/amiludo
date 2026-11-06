import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/card_painter.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_card_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_header.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/detail_panel.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/effects.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/flip_card.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/swipe_table.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/table_gestures.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const hiddenFromScore = 3;

class ChroniclesDiscover extends StatefulWidget {
  const ChroniclesDiscover({
    super.key,
    required this.data,
    required this.run,
    this.refusal,
  });
  final ChroniclesData data;
  final ChroniclesRun run;
  final Refusal? refusal;

  @override
  State<ChroniclesDiscover> createState() => _ChroniclesDiscoverState();
}

class _ChroniclesDiscoverState extends State<ChroniclesDiscover> {
  String? flipped;

  String message(BuildContext context) => widget.refusal == Refusal.quota
      ? context.l10n.chroniclesRefusedQuota
      : context.l10n.chroniclesRefusedConflict;

  void feel() {
    final s = ChroniclesSettings.maybeOf(context);
    if (s == null) return;
    DeviceFeedback.tap(sound: s.sound, haptics: s.haptics);
  }

  void decide(VoidCallback action) {
    feel();
    action();
  }

  Widget back(BuildContext context, Color color) => Semantics(
    button: true,
    label: context.l10n.chroniclesFlip,
    child: AspectRatio(
      aspectRatio: cardAspect,
      child: Halo(
        color: color,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: color, width: 3),
          ),
          child: const DeckIcon(Icons.auto_stories_outlined, size: 56),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final card = widget.run.current!;
    final cubit = context.read<ChroniclesCubit>();
    final rarity = widget.data.rarity(card.rarity);
    final color = rarityColor(rarity.score);
    final hidden = rarity.score >= hiddenFromScore && flipped != card.id;
    final height = tableHeight(MediaQuery.sizeOf(context));
    final face = ChroniclesCardFace(
      key: ValueKey('card-${card.id}'),
      card: card,
      score: rarity.score,
      label: widget.data.labelOf(card),
      rarityName: rarity.name,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChroniclesHeader(data: widget.data, run: widget.run),
        Text('${widget.run.position + 1} / ${widget.run.booster.length}'),
        const SizedBox(height: Space.md),
        Center(
          child: SizedBox(
            height: height,
            child: AspectRatio(
              aspectRatio: cardAspect,
              child: SwipeTable(
                key: ValueKey('table-${card.id}'),
                enabled: !hidden,
                onKeep: () => decide(cubit.keep),
                onPass: () => decide(cubit.pass),
                onTap: () => hidden
                    ? setState(() {
                        feel();
                        flipped = card.id;
                      })
                    : showChroniclesDetail(context, card, widget.data),
                child: Burst(
                  trigger: flipped ?? '',
                  color: color,
                  child: FlipCard(
                    faceUp: !hidden,
                    front: face,
                    back: InkWell(
                      key: const ValueKey('flip'),
                      onTap: () => setState(() {
                        feel();
                        flipped = card.id;
                      }),
                      child: back(context, color),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Text(
          context.l10n.chroniclesSwipeHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (widget.refusal != null)
          Semantics(
            liveRegion: true,
            child: Text(
              message(context),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('pass'),
              onPressed: hidden ? null : () => decide(cubit.pass),
              icon: const DeckIcon(Icons.close),
              label: Text(context.l10n.chroniclesPass),
            ),
            FilledButton.icon(
              key: const ValueKey('keep'),
              onPressed: hidden ? null : () => decide(cubit.keep),
              icon: const DeckIcon(Icons.check),
              label: Text(context.l10n.chroniclesKeep),
            ),
          ],
        ),
      ],
    );
  }
}
