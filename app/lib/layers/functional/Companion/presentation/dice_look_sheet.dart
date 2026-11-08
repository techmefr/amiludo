import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<void> showDiceLookSheet(
  BuildContext context, {
  required String skin,
  required String table,
  required ValueChanged<String> onSkin,
  required ValueChanged<String> onTable,
}) => showDeckSheet<void>(
  context: context,
  title: context.l10n.diceLook,
  builder: (_) => DiceLookPicker(
    skin: skin,
    table: table,
    onSkin: onSkin,
    onTable: onTable,
  ),
);

String skinLabel(AppLocalizations l, String id) => switch (id) {
  'matte' => l.diceSkinMatte,
  'gold' => l.diceSkinGold,
  'wood' => l.diceSkinWood,
  'crystal' => l.diceSkinCrystal,
  'glass' => l.diceSkinGlass,
  'cream' => l.diceSkinCream,
  'violet' => l.diceSkinViolet,
  _ => l.diceSkinClassic,
};

String tableLabel(AppLocalizations l, String id) => switch (id) {
  'dark' => l.diceTableDark,
  'light' => l.diceTableLight,
  'wood' => l.diceTableWood,
  'blue' => l.diceTableBlue,
  'red' => l.diceTableRed,
  _ => l.diceTableFelt,
};

class DiceLookPicker extends StatefulWidget {
  const DiceLookPicker({
    super.key,
    required this.skin,
    required this.table,
    required this.onSkin,
    required this.onTable,
  });
  final String skin, table;
  final ValueChanged<String> onSkin, onTable;

  @override
  State<DiceLookPicker> createState() => _DiceLookPickerState();
}

class _DiceLookPickerState extends State<DiceLookPicker> {
  late String skin = widget.skin, table = widget.table;

  Widget tile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Widget preview,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap,
        child: Container(
          width: 76,
          padding: const EdgeInsets.all(Space.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: ExcludeSemantics(
            child: Column(
              children: [
                preview,
                const SizedBox(height: Space.xs),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.diceLookSkin, style: theme.titleSmall),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final s in DieSkin.all)
              tile(
                label: skinLabel(l, s.id),
                selected: s.id == skin,
                onTap: () {
                  setState(() => skin = s.id);
                  widget.onSkin(s.id);
                },
                preview: Die3dView(
                  spec: const DiceSpec(sides: 6),
                  value: 5,
                  skin: s,
                  size: 44,
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Text(l.diceLookTable, style: theme.titleSmall),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final t in TableTheme.all)
              tile(
                label: tableLabel(l, t.id),
                selected: t.id == table,
                onTap: () {
                  setState(() => table = t.id);
                  widget.onTable(t.id);
                },
                preview: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.sm),
                    gradient: RadialGradient(colors: [t.center, t.edge]),
                    border: Border.all(color: t.rim, width: Space.xs),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
      ],
    );
  }
}
