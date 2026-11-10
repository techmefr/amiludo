import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/appearance_item.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class AvatarPieceGrid extends StatelessWidget {
  const AvatarPieceGrid({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onPick,
    required this.slotLabel,
  });
  final List<AppearanceItem> items;
  final String? selectedId;
  final ValueChanged<AppearanceItem?> onPick;
  final String slotLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        ChoiceChip(
          label: Text(context.l10n.avatarNone),
          selected: selectedId == null,
          onSelected: (_) => onPick(null),
        ),
        for (var i = 0; i < items.length; i++)
          Semantics(
            button: true,
            selected: items[i].id == selectedId,
            label: '$slotLabel ${i + 1}',
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.md),
              onTap: () => onPick(items[i]),
              child: Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(Space.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(
                    width: items[i].id == selectedId ? 3 : 1,
                    color: items[i].id == selectedId
                        ? scheme.accentInk
                        : scheme.outlineVariant,
                  ),
                ),
                child: Image.asset(
                  'assets/${items[i].variants.values.first.layers.first.src}.png',
                  excludeFromSemantics: true,
                  cacheWidth: 128,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
