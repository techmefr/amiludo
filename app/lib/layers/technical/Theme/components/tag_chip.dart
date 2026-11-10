import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/layout_tokens.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: Rows.chip),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    ),
  );
}
