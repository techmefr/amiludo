import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const brickColors = [
  0xFF3D7BD9,
  0xFFD94A4A,
  0xFFE0A526,
  0xFF3FA66B,
  0xFF8A65D8,
];

Future<CounterSettings?> showBrickSettings(
  BuildContext context,
  CounterSettings settings,
) => showDeckSheet<CounterSettings>(
  context: context,
  title: context.l10n.brickSettings,
  builder: (_) => BrickSettingsForm(settings: settings),
);

class BrickSettingsForm extends StatefulWidget {
  const BrickSettingsForm({super.key, required this.settings});
  final CounterSettings settings;

  @override
  State<BrickSettingsForm> createState() => _BrickSettingsFormState();
}

String _text(double? v) => v == null
    ? ''
    : v == v.roundToDouble()
    ? v.toInt().toString()
    : v.toString();

double? _number(TextEditingController c) =>
    double.tryParse(c.text.trim().replaceAll(',', '.'));

class _BrickSettingsFormState extends State<BrickSettingsForm> {
  late final name = TextEditingController(text: widget.settings.name);
  late final minimum = TextEditingController(
    text: _text(widget.settings.minimum),
  );
  late final maximum = TextEditingController(
    text: _text(widget.settings.maximum),
  );
  late final start = TextEditingController(text: _text(widget.settings.start));
  late final step = TextEditingController(text: _text(widget.settings.step));
  late int color = widget.settings.color;
  late CounterDisplay display = widget.settings.display;

  @override
  void dispose() {
    for (final c in [name, minimum, maximum, start, step]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget field(TextEditingController c, String label, {bool numeric = true}) =>
      TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : TextInputType.text,
      );

  String colorLabel(int value) {
    final l = context.l10n;
    return switch (value) {
      0xFFD94A4A => l.brickColorRed,
      0xFFE0A526 => l.brickColorGold,
      0xFF3FA66B => l.brickColorGreen,
      0xFF8A65D8 => l.brickColorViolet,
      _ => l.brickColorBlue,
    };
  }

  String displayLabel(CounterDisplay d) {
    final l = context.l10n;
    return switch (d) {
      CounterDisplay.bar => l.brickDisplayBar,
      CounterDisplay.hearts => l.brickDisplayHearts,
      CounterDisplay.pips => l.brickDisplayPips,
      CounterDisplay.number => l.brickDisplayNumber,
    };
  }

  void apply() {
    final low = _number(minimum), high = _number(maximum);
    final next = {
      ...widget.settings.toJson(),
      'name': name.text.trim(),
      'start': _number(start) ?? widget.settings.start,
      'step': (_number(step) ?? widget.settings.step).abs(),
      'color': color,
      'display': display.name,
    }..removeWhere((k, _) => k == 'minimum' || k == 'maximum');
    if (low != null) next['minimum'] = low;
    if (high != null) next['maximum'] = high;
    Navigator.of(context).pop(CounterSettings.fromJson(next));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const gap = SizedBox(height: Space.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field(name, l.brickSettingName, numeric: false),
        gap,
        field(start, l.brickSettingStart),
        gap,
        field(minimum, l.brickSettingMinimum),
        gap,
        field(maximum, l.brickSettingMaximum),
        gap,
        field(step, l.brickSettingStep),
        gap,
        Text(l.brickSettingColor),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final value in brickColors)
              ChoiceChip(
                avatar: CircleAvatar(backgroundColor: Color(value)),
                label: Text(colorLabel(value)),
                selected: color == value,
                onSelected: (_) => setState(() => color = value),
              ),
          ],
        ),
        gap,
        Text(l.brickSettingDisplay),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final d in CounterDisplay.values)
              ChoiceChip(
                label: Text(displayLabel(d)),
                selected: display == d,
                onSelected: (_) => setState(() => display = d),
              ),
          ],
        ),
        const SizedBox(height: Space.xl),
        FilledButton(onPressed: apply, child: Text(l.brickSettingsApply)),
      ],
    );
  }
}
