import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/tally_board.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tally_card.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const _cardWidth = 300.0;

class TallyTool extends StatefulWidget {
  const TallyTool({super.key, required this.names});
  final List<String> names;

  @override
  State<TallyTool> createState() => _TallyToolState();
}

class _TallyToolState extends State<TallyTool> {
  TallyBoard? board;
  final List<TallyBoard> history = [];
  final tool = toolThemeFor('tally');

  TallyBoard get current => board!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    board ??= TallyBoard.begin(widget.names, [context.l10n.tallyResources]);
  }

  void _apply(TallyBoard next) {
    if (identical(next, current)) return;
    setState(() {
      history.add(current);
      board = next;
    });
  }

  Future<void> _add() async {
    final l = context.l10n;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.tallyAddCounter),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.tallyCounterName),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l.tallyAddCounter),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null) _apply(current.add(name));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (c, name) in current.counters.indexed)
                InputChip(
                  label: Text(name),
                  deleteButtonTooltipMessage: l.tallyRemoveCounter(name),
                  onDeleted: () => _apply(current.remove(c)),
                ),
              ActionChip(
                avatar: const DeckIcon(Icons.add, size: 18),
                label: Text(l.tallyAddCounter),
                onPressed: _add,
              ),
              TextButton.icon(
                onPressed: history.isEmpty
                    ? null
                    : () => setState(() => board = history.removeLast()),
                icon: const DeckIcon(Icons.undo),
                label: Text(l.gameUndo),
              ),
              TextButton.icon(
                onPressed: () => _apply(current.cleared()),
                icon: const DeckIcon(Icons.restart_alt),
                label: Text(l.appearanceReset),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          if (current.counters.isEmpty)
            Text(l.tallyEmpty, style: Theme.of(context).textTheme.bodyLarge)
          else
            LayoutBuilder(
              builder: (context, box) {
                final columns = (box.maxWidth / _cardWidth).floor().clamp(1, 4);
                final width =
                    (box.maxWidth - (columns - 1) * Space.md) / columns;
                return Wrap(
                  spacing: Space.md,
                  runSpacing: Space.md,
                  children: [
                    for (final (p, name) in current.players.indexed)
                      SizedBox(
                        width: width,
                        child: TallyCard(
                          name: name,
                          counters: current.counters,
                          values: current.values[p],
                          accent: tool.accent,
                          onBump: (c, delta) {
                            tool.signal();
                            _apply(current.bump(p, c, delta));
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
