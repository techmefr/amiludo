import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/turn_track.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_palette.dart';
import 'package:amiludo/layers/functional/Companion/presentation/name_dialog.dart';
import 'package:amiludo/layers/functional/Companion/presentation/turn_stone.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class TurnsTool extends StatefulWidget {
  const TurnsTool({super.key, required this.names});
  final List<String> names;

  @override
  State<TurnsTool> createState() => _TurnsToolState();
}

class _TurnsToolState extends State<TurnsTool> {
  TurnTrack? track;
  final List<TurnTrack> history = [];
  final tool = toolThemeFor('turns');

  TurnTrack get current => track!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = context.l10n;
    track ??= TurnTrack(
      players: widget.names,
      phases: [l.turnPhaseDraw, l.turnPhaseMain, l.turnPhaseEnd],
    );
  }

  void _apply(TurnTrack next) {
    if (identical(next, current)) return;
    tool.signal();
    setState(() {
      history.add(current);
      track = next;
    });
  }

  Future<void> _addPhase() async {
    final l = context.l10n;
    final name = await showNameDialog(
      context,
      title: l.turnAddPhase,
      label: l.turnPhaseName,
    );
    if (name != null) _apply(current.addPhase(name));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final accent = playerTints[current.player % playerTints.length];
    final name = current.players[current.player];
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            label:
                '${l.turnRound(current.round)}, ${l.turnPlays(name)}',
            child: ExcludeSemantics(
              child: StoneSlab(
                accent: accent,
                child: Padding(
                  padding: const EdgeInsets.all(Space.xl),
                  child: Column(
                    children: [
                      Text(
                        l.turnRound(current.round),
                        style: theme.titleMedium?.copyWith(
                          color: StonePalette.gold,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          name,
                          style: stoneNumerals(TypeScale.display * 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final (i, label) in current.phases.indexed)
                TurnStone(
                  label: label,
                  index: i + 1,
                  accent: accent,
                  state: i < current.phase
                      ? TurnStoneState.past
                      : (i == current.phase
                            ? TurnStoneState.active
                            : TurnStoneState.upcoming),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          FilledButton.icon(
            onPressed: () => _apply(current.advance()),
            icon: const DeckIcon(Icons.arrow_forward),
            label: Text(
              current.lastPhase ? l.gameNextPlayer : l.turnNextPhase,
            ),
          ),
          const SizedBox(height: Space.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.sm,
            children: [
              TextButton.icon(
                onPressed: history.isEmpty
                    ? null
                    : () => setState(() => track = history.removeLast()),
                icon: const DeckIcon(Icons.undo),
                label: Text(l.gameUndo),
              ),
              TextButton.icon(
                onPressed: () => _apply(current.nextPlayer()),
                icon: const DeckIcon(Icons.skip_next_outlined),
                label: Text(l.turnSkipPlayer),
              ),
              TextButton.icon(
                onPressed: _addPhase,
                icon: const DeckIcon(Icons.add),
                label: Text(l.turnAddPhase),
              ),
              if (current.phases.length > 1)
                PopupMenuButton<int>(
                  tooltip: l.turnRemovePhase,
                  onSelected: (i) => _apply(current.removePhase(i)),
                  itemBuilder: (_) => [
                    for (final (i, label) in current.phases.indexed)
                      PopupMenuItem(value: i, child: Text(label)),
                  ],
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: Targets.minimum,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.md),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const DeckIcon(Icons.remove),
                          const SizedBox(width: Space.sm),
                          Flexible(child: Text(l.turnRemovePhase)),
                        ],
                      ),
                    ),
                  ),
                ),
              TextButton.icon(
                onPressed: () => _apply(current.restart()),
                icon: const DeckIcon(Icons.restart_alt),
                label: Text(l.appearanceReset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
