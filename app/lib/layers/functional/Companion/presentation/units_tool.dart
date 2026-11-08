import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/activation.dart';
import 'package:amiludo/layers/functional/Companion/presentation/name_dialog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class UnitsTool extends StatefulWidget {
  const UnitsTool({super.key, this.random});
  final Random? random;

  @override
  State<UnitsTool> createState() => _UnitsToolState();
}

class _UnitsToolState extends State<UnitsTool> {
  late final Random random = widget.random ?? Random();
  ActivationRound round = const ActivationRound();
  int? next;
  final tool = toolThemeFor('units');

  Future<void> _add() async {
    final l = context.l10n;
    final name = await showNameDialog(
      context,
      title: l.unitsAdd,
      label: l.unitsName,
    );
    if (name != null) setState(() => round = round.add(name));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final pick = next;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            round.finished
                ? l.unitsAllDone
                : (pick == null || pick >= round.units.length
                      ? l.unitsDrawHint
                      : l.unitsNext(round.units[pick])),
            textAlign: TextAlign.center,
            style: theme.headlineSmall,
          ),
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final (i, unit) in round.units.indexed)
              InputChip(
                label: Text(unit),
                selected: round.done.contains(i),
                showCheckmark: true,
                deleteButtonTooltipMessage: l.unitsRemove(unit),
                onPressed: () => setState(() => round = round.toggle(i)),
                onDeleted: () => setState(() {
                  round = round.remove(i);
                  next = null;
                }),
              ),
            ActionChip(
              avatar: const DeckIcon(Icons.add, size: 18),
              label: Text(l.unitsAdd),
              onPressed: _add,
            ),
          ],
        ),
        const SizedBox(height: Space.xl),
        Wrap(
          spacing: Space.sm,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: round.remaining.isEmpty
                  ? null
                  : () {
                      tool.signal();
                      setState(() => next = round.draw(random));
                    },
              icon: const DeckIcon(Icons.shuffle),
              label: Text(l.unitsDraw),
            ),
            TextButton.icon(
              onPressed: () => setState(() {
                round = round.newRound();
                next = null;
              }),
              icon: const DeckIcon(Icons.restart_alt),
              label: Text(l.unitsNewRound),
            ),
          ],
        ),
      ],
    );
  }
}
