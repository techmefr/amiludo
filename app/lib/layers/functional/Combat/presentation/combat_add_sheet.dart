import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/technical/Theme/tokens/type_roles.dart';
import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef NewCombatants = ({Combatant model, int count});

Future<NewCombatants?> showCombatAddSheet(
  BuildContext context, {
  List<String> npcNames = const [],
}) => showModalBottomSheet<NewCombatants>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => CombatAddSheet(npcNames: npcNames),
);

class CombatAddSheet extends StatefulWidget {
  const CombatAddSheet({super.key, this.npcNames = const []});
  final List<String> npcNames;

  @override
  State<CombatAddSheet> createState() => _CombatAddSheetState();
}

class _CombatAddSheetState extends State<CombatAddSheet> {
  final name = TextEditingController();
  final hp = TextEditingController();
  final bonus = TextEditingController(text: '0');
  int count = 1;
  bool player = false;

  @override
  void dispose() {
    name.dispose();
    hp.dispose();
    bonus.dispose();
    super.dispose();
  }

  void _submit() {
    final clean = name.text.trim();
    if (clean.isEmpty) return;
    final life = int.tryParse(hp.text) ?? 0;
    Navigator.pop(context, (
      model: Combatant(
        id: newCombatId(),
        name: clean,
        bonus: int.tryParse(bonus.text) ?? 0,
        hp: life,
        maxHp: life,
        player: player,
      ),
      count: player ? 1 : count,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final digits = [FilteringTextInputFormatter.allow(RegExp(r'-?\d*'))];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.npcNames.isNotEmpty) ...[
              Text(
                l.combatFromNpcs,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Space.sm),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  for (final npc in widget.npcNames)
                    ActionChip(
                      label: Text(npc),
                      onPressed: () => setState(() => name.text = npc),
                    ),
                ],
              ),
              const SizedBox(height: Space.lg),
            ],
            TextField(
              controller: name,
              autofocus: widget.npcNames.isEmpty,
              decoration: InputDecoration(labelText: l.combatName),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hp,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: InputDecoration(labelText: l.combatHp),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: TextField(
                    controller: bonus,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    inputFormatters: digits,
                    decoration: InputDecoration(labelText: l.combatBonus),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.combatPlayer),
              value: player,
              onChanged: (v) => setState(() => player = v),
            ),
            if (!player)
              Row(
                children: [
                  Expanded(child: Text(l.combatCount)),
                  IconButton(
                    tooltip: l.combatFewer,
                    onPressed: count > 1
                        ? () => setState(() => count--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$count', style: TypeRoles.sectionTitle(context)),
                  IconButton(
                    tooltip: l.combatMore,
                    onPressed: count < 20
                        ? () => setState(() => count++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            const SizedBox(height: Space.md),
            FilledButton(onPressed: _submit, child: Text(l.combatAdd)),
          ],
        ),
      ),
    );
  }
}
