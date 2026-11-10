import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

const mapSwatchSize = 28.0;

class MapPaletteRow extends StatelessWidget {
  const MapPaletteRow({
    super.key,
    required this.selected,
    required this.onPick,
  });
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < mapPalette.length; i++)
          Semantics(
            button: true,
            selected: mapPalette[i] == selected,
            label: '${context.l10n.mapColor} ${i + 1}',
            child: InkResponse(
              onTap: () => onPick(mapPalette[i]),
              child: SizedBox.square(
                dimension: Targets.minimum,
                child: Center(
                  child: Container(
                    width: mapSwatchSize,
                    height: mapSwatchSize,
                    decoration: BoxDecoration(
                      color: Color(mapPalette[i]),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: mapPalette[i] == selected
                            ? scheme.accentInk
                            : scheme.outlineVariant,
                        width: mapPalette[i] == selected ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
