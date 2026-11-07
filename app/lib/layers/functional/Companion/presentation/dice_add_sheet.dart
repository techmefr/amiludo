import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const diceListSides = [...standardSides, 100];
const diceMoreSides = [2, 3, 5, 16, 24, 30, 60, 1000];

Future<void> showDiceAddSheet(
  BuildContext context,
  DiceTraySettings settings,
  ValueChanged<DiceTraySettings> onChanged,
) => showDeckSheet<void>(
  context: context,
  title: context.l10n.diceTrayAddDie,
  builder: (_) => DiceAddList(
    settings: settings,
    onChanged: onChanged,
    library: DieStudio.maybeOf(context)?.state.designs ?? const [],
  ),
);

class DiceAddList extends StatefulWidget {
  const DiceAddList({
    super.key,
    required this.settings,
    required this.onChanged,
    this.library = const [],
  });
  final List<DieDesign> library;
  final DiceTraySettings settings;
  final ValueChanged<DiceTraySettings> onChanged;

  @override
  State<DiceAddList> createState() => _DiceAddListState();
}

class _DiceAddListState extends State<DiceAddList> {
  late List<DiceSpec> dice = [...widget.settings.dice];

  int countOf(bool Function(DiceSpec) match) => dice.where(match).length;

  void change(List<DiceSpec> next) {
    setState(() => dice = next);
    widget.onChanged(DiceTraySettings(dice: next));
  }

  void add(DiceSpec spec) {
    if (dice.length < maxTrayDice) change([...dice, spec]);
  }

  void remove(bool Function(DiceSpec) match) {
    final at = dice.lastIndexWhere(match);
    if (at >= 0) change([...dice]..removeAt(at));
  }

  Widget row(String label, DiceSpec spec, bool Function(DiceSpec) match) {
    final l = context.l10n;
    final count = countOf(match);
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          tooltip: l.diceTrayRemoveDie,
          onPressed: count == 0 ? null : () => remove(match),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: Space.xl,
          child: Text('$count', textAlign: TextAlign.center),
        ),
        IconButton(
          tooltip: l.diceTrayAddDie,
          onPressed: dice.length >= maxTrayDice ? null : () => add(spec),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final library = widget.library;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l.diceTrayCount(dice.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final sides in diceListSides)
          row(
            'd$sides',
            DiceSpec(sides: sides),
            (d) => d.sides == sides && !d.custom && d.design == null,
          ),
        const SizedBox(height: Space.md),
        Text(l.diceMoreDice, style: Theme.of(context).textTheme.labelLarge),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final sides in diceMoreSides)
              ActionChip(
                label: Text('+ d$sides'),
                onPressed: dice.length >= maxTrayDice
                    ? null
                    : () => add(DiceSpec(sides: sides)),
              ),
            for (final d in dice.where(
              (d) =>
                  diceMoreSides.contains(d.sides) && !d.custom && d.design == null,
            ))
              InputChip(
                label: Text(d.name),
                deleteButtonTooltipMessage: l.diceTrayRemoveDie,
                onDeleted: () => change([...dice]..remove(d)),
              ),
          ],
        ),
        if (library.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Text(l.diceMyDice, style: Theme.of(context).textTheme.labelLarge),
          for (final d in library)
            row(d.name, DiceSpec.fromDesign(d), (s) => s.design?.id == d.id),
        ],
        const SizedBox(height: Space.lg),
      ],
    );
  }
}
