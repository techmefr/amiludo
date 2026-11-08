import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef CombatantChange = void Function(Combatant Function(Combatant));

Future<bool?> showCombatantSheet(
  BuildContext context, {
  required Combatant combatant,
  required CombatantChange onChange,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => CombatantSheet(combatant: combatant, onChange: onChange),
);

class CombatantSheet extends StatefulWidget {
  const CombatantSheet({
    super.key,
    required this.combatant,
    required this.onChange,
  });
  final Combatant combatant;
  final CombatantChange onChange;

  @override
  State<CombatantSheet> createState() => _CombatantSheetState();
}

class _CombatantSheetState extends State<CombatantSheet> {
  late Combatant shown = widget.combatant;
  late final name = TextEditingController(text: shown.name);
  late final initiative = TextEditingController(
    text: '${shown.initiative ?? ''}',
  );
  final amount = TextEditingController(text: '1');

  @override
  void dispose() {
    name.dispose();
    initiative.dispose();
    amount.dispose();
    super.dispose();
  }

  void _apply(Combatant Function(Combatant) change) {
    widget.onChange(change);
    setState(() => shown = change(shown));
  }

  int get _amount => (int.tryParse(amount.text) ?? 0).abs();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final digits = [FilteringTextInputFormatter.digitsOnly];
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
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l.combatName),
              onChanged: (v) {
                if (v.trim().isNotEmpty) _apply((c) => c.copyWith(name: v));
              },
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: initiative,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: InputDecoration(labelText: l.combatInitiative),
              onChanged: (v) {
                final value = int.tryParse(v);
                if (value != null) _apply((c) => c.copyWith(initiative: value));
              },
            ),
            if (shown.tracksHp) ...[
              const SizedBox(height: Space.lg),
              Text(
                '${l.combatHp}: ${shown.hp} / ${shown.maxHp}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Space.sm),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                decoration: InputDecoration(labelText: l.combatAmount),
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _apply((c) => c.hit(-_amount)),
                      icon: const DeckIcon(Icons.remove),
                      label: Text(l.combatDamage),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _apply((c) => c.hit(_amount)),
                      icon: const DeckIcon(Icons.add),
                      label: Text(l.combatHeal),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Space.lg),
            Text(
              l.combatConditions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final key in combatConditions)
                  FilterChip(
                    label: Text(context.combatCondition(key)),
                    selected: shown.conditions.contains(key),
                    onSelected: (_) => _apply((c) => c.toggled(key)),
                  ),
              ],
            ),
            const SizedBox(height: Space.lg),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const DeckIcon(Icons.close),
              label: Text(l.combatRemove),
            ),
          ],
        ),
      ),
    );
  }
}
