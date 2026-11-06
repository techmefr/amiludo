import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

List<String> parseFaces(String text) => text
    .split(',')
    .map((f) => f.trim())
    .where((f) => f.isNotEmpty)
    .take(maxCustomFaces)
    .toList();

class DiceTrayControls extends StatelessWidget {
  const DiceTrayControls({
    super.key,
    required this.settings,
    required this.onChanged,
  });
  final DiceTraySettings settings;
  final ValueChanged<DiceTraySettings> onChanged;

  void add(DiceSpec spec) {
    if (settings.dice.length >= maxTrayDice) return;
    onChanged(DiceTraySettings(dice: [...settings.dice, spec]));
  }

  void removeAt(int index) => onChanged(
    DiceTraySettings(dice: [...settings.dice]..removeAt(index)),
  );

  Future<void> addCustom(BuildContext context) async {
    final spec = await showDeckSheet<DiceSpec>(
      context: context,
      title: context.l10n.diceTrayCustomDie,
      builder: (_) => const CustomDieForm(),
    );
    if (spec != null) add(spec);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final sides in standardSides)
          ActionChip(
            tooltip: l.diceTrayAddDie,
            label: Text('+ d$sides'),
            onPressed: () => add(DiceSpec(sides: sides)),
          ),
        ActionChip(
          tooltip: l.diceTrayAddDie,
          avatar: const Icon(Icons.add),
          label: Text(l.diceTrayCustomDie),
          onPressed: () => addCustom(context),
        ),
        for (var i = 0; i < settings.dice.length; i++)
          InputChip(
            label: Text(settings.dice[i].name),
            deleteButtonTooltipMessage: l.diceTrayRemoveDie,
            onDeleted: () => removeAt(i),
          ),
      ],
    );
  }
}

class CustomDieForm extends StatefulWidget {
  const CustomDieForm({super.key});

  @override
  State<CustomDieForm> createState() => _CustomDieFormState();
}

class _CustomDieFormState extends State<CustomDieForm> {
  final faces = TextEditingController();
  int color = facePalette.first;

  @override
  void dispose() {
    faces.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entered = parseFaces(faces.text);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: faces,
          autofocus: true,
          decoration: InputDecoration(labelText: l.diceTrayCustomFaces),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Space.lg),
        Text(l.diceTrayCustomColor),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final c in facePalette)
              IconButton(
                constraints: const BoxConstraints.tightFor(
                  width: Targets.minimum,
                  height: Targets.minimum,
                ),
                onPressed: () => setState(() => color = c),
                icon: Icon(
                  c == color ? Icons.check_circle : Icons.circle,
                  color: Color(c),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        FilledButton(
          onPressed: entered.length < 2
              ? null
              : () => Navigator.pop(context, DiceSpec.custom(entered, color)),
          child: Text(l.themeSave),
        ),
      ],
    );
  }
}
