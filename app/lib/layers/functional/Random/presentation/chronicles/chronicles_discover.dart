import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/presentation/card_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_header.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_mapping.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const hiddenFromScore = 3;
const tableWidth = 280.0;

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

  Widget faceDown(BuildContext context, String id) => Semantics(
    button: true,
    label: context.l10n.chroniclesFlip,
    child: InkWell(
      key: const ValueKey('flip'),
      borderRadius: BorderRadius.circular(Radii.lg),
      onTap: () => setState(() => flipped = id),
      child: Container(
        height: tableWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: const DeckIcon(Icons.auto_stories_outlined, size: 56),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final card = widget.run.current!;
    final cubit = context.read<ChroniclesCubit>();
    final rarity = widget.data.rarity(card.rarity);
    final hidden = rarity.score >= hiddenFromScore && flipped != card.id;
    final label = '${widget.data.labelOf(card)} · ${rarity.name}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChroniclesHeader(data: widget.data, run: widget.run),
        Text('${widget.run.position + 1} / ${widget.run.booster.length}'),
        const SizedBox(height: Space.md),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: tableWidth),
            child: hidden
                ? faceDown(context, card.id)
                : CardFace(
                    key: ValueKey('card-${card.id}'),
                    card: characterCardOf(card),
                    type: label,
                  ),
          ),
        ),
        const SizedBox(height: Space.lg),
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
              onPressed: hidden ? null : cubit.pass,
              icon: const DeckIcon(Icons.close),
              label: Text(context.l10n.chroniclesPass),
            ),
            FilledButton.icon(
              key: const ValueKey('keep'),
              onPressed: hidden ? null : cubit.keep,
              icon: const DeckIcon(Icons.check),
              label: Text(context.l10n.chroniclesKeep),
            ),
          ],
        ),
      ],
    );
  }
}
