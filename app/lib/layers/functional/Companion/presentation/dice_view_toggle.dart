import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DiceViewToggle extends StatelessWidget {
  const DiceViewToggle({
    super.key,
    required this.solid,
    required this.onChanged,
  });
  final bool solid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Semantics(
      container: true,
      label: l.diceTrayView,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChoiceChip(
            tooltip: l.diceTrayView,
            label: Text(l.diceTrayView2d),
            selected: !solid,
            onSelected: (_) => onChanged(false),
          ),
          const SizedBox(width: Space.xs),
          ChoiceChip(
            tooltip: l.diceTrayView,
            label: Text(l.diceTrayView3d),
            selected: solid,
            onSelected: (_) => onChanged(true),
          ),
        ],
      ),
    );
  }
}
