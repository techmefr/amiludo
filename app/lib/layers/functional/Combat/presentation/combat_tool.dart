import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';
import 'package:amiludo/layers/functional/Combat/domain/entities/encounter.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_add_sheet.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_header.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combatant_card.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combatant_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class CombatTool extends StatefulWidget {
  const CombatTool({
    super.key,
    this.initial = const Encounter(),
    this.onChanged,
    this.npcNames = const [],
    this.random,
    this.roller,
  });
  final Encounter initial;
  final ValueChanged<Encounter>? onChanged;
  final List<String> npcNames;
  final RandomTools? random;
  final DieRoller? roller;

  @override
  State<CombatTool> createState() => _CombatToolState();
}

class _CombatToolState extends State<CombatTool> {
  late Encounter encounter = widget.initial;
  late final RandomTools random = widget.random ?? RandomTools();
  final tool = toolThemeFor('combat');

  void _commit(Encounter next) {
    setState(() => encounter = next);
    widget.onChanged?.call(next);
  }

  int _roll(int sides) => random.integer(1, sides);

  void _start() {
    tool.signal();
    _commit(encounter.rollMissing(_roll).start());
  }

  void _next() {
    tool.signal();
    _commit(encounter.next());
  }

  Future<void> _add() async {
    final made = await showCombatAddSheet(context, npcNames: widget.npcNames);
    if (made == null) return;
    _commit(encounter.addGroup(made.model, made.count));
  }

  Future<void> _open(Combatant combatant) async {
    final remove = await showCombatantSheet(
      context,
      combatant: combatant,
      roller: widget.roller,
      onChange: (change) => _commit(encounter.update(combatant.id, change)),
    );
    if (remove == true) _commit(encounter.remove(combatant.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final line = encounter.ordered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CombatHeader(
          encounter: encounter,
          tool: tool,
          onAdd: _add,
          onStart: _start,
          onNext: _next,
          onRoll: () => _commit(encounter.rollAll(_roll)),
          onReset: () => _commit(encounter.reset()),
        ),
        const SizedBox(height: Space.lg),
        if (line.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Text(l.combatEmpty, textAlign: TextAlign.center),
          ),
        for (final c in line)
          Padding(
            key: ValueKey(c.id),
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: CombatantCard(
              combatant: c,
              active: c.id == encounter.turnId,
              tool: tool,
              onOpen: () => _open(c),
              onHit: (delta) =>
                  _commit(encounter.update(c.id, (x) => x.hit(delta))),
            ),
          ),
      ],
    );
  }
}
