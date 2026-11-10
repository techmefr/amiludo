import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/finger_draw.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_name_picker.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class FingerOptions extends StatelessWidget {
  const FingerOptions({
    super.key,
    required this.mode,
    required this.winners,
    required this.groups,
    required this.onWinners,
    required this.onGroups,
    required this.names,
    required this.chosen,
    required this.onPick,
  });
  final FingerMode mode;
  final int winners, groups;
  final ValueChanged<int> onWinners, onGroups;
  final List<String> names;
  final String? chosen;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mode == FingerMode.first)
              _Stepper(
                label: l.fingerWinners,
                value: winners,
                max: maxFingerWinners,
                onChanged: onWinners,
              ),
            if (mode == FingerMode.groups)
              _Stepper(
                label: l.fingerGroups,
                value: groups,
                min: 2,
                max: maxFingerGroups,
                onChanged: onGroups,
              ),
            FingerNamePicker(names: names, chosen: chosen, onPick: onPick),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.max,
    this.min = 1,
  });
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
          tooltip: l.fingerLess,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(Targets.minimum),
          ),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Semantics(
          liveRegion: true,
          child: SizedBox(
            width: Space.xxl,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        IconButton(
          tooltip: l.fingerMore,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(Targets.minimum),
          ),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
