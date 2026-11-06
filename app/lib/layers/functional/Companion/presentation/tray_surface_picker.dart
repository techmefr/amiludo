import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TraySurfacePicker extends StatelessWidget {
  const TraySurfacePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = {
      SurfaceMaterial.wood: l.diceTrayWood,
      SurfaceMaterial.felt: l.diceTrayFelt,
      SurfaceMaterial.glass: l.diceTrayGlass,
    };
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l.diceTraySurface),
        for (final m in SurfaceMaterial.values)
          ChoiceChip(
            label: Text(labels[m]!),
            selected: m.name == value,
            onSelected: (_) => onChanged(m.name),
          ),
      ],
    );
  }
}
