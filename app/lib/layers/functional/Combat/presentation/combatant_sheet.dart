import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef CombatantChange = void Function(Combatant Function(Combatant));

typedef DieRoller = Future<int?> Function(BuildContext context, String name);

Future<bool?> showCombatantSheet(
  BuildContext context, {
  required Combatant combatant,
  required CombatantChange onChange,
  DieRoller? roller,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) =>
      CombatantSheet(combatant: combatant, onChange: onChange, roller: roller),
);

class CombatantSheet extends StatefulWidget {
  const CombatantSheet({
    super.key,
    required this.combatant,
    required this.onChange,
    this.roller,
  });
  final Combatant combatant;
  final CombatantChange onChange;
  final DieRoller? roller;

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

  Future<void> _roll() async {
    final result = await widget.roller!(context, shown.name);
    if (!mounted || result == null) return;
    final total = result + shown.bonus;
    initiative.text = '$total';
    _apply((c) => c.copyWith(initiative: total));
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
            if (widget.roller != null) ...[
              const SizedBox(height: Space.sm),
              OutlinedButton.icon(
                onPressed: _roll,
                icon: const DeckIcon(Icons.casino_outlined),
                label: Text(l.combatRollDie),
              ),
            ],
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
