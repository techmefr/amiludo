import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/icon_catalog.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DieIconPicker extends StatefulWidget {
  const DieIconPicker({super.key, required this.selected, required this.onPick});
  final String selected;
  final ValueChanged<String> onPick;

  @override
  State<DieIconPicker> createState() => _DieIconPickerState();
}

class _DieIconPickerState extends State<DieIconPicker> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ids = searchIcons(query);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.diceIconSearch,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: Space.sm),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: Space.xs,
              runSpacing: Space.xs,
              children: [
                for (final id in ids)
                  Semantics(
                    button: true,
                    selected: id == widget.selected,
                    label: id,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      onTap: () => widget.onPick(id),
                      child: Container(
                        width: Targets.minimum,
                        height: Targets.minimum,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(
                            color: id == widget.selected
                                ? scheme.primary
                                : scheme.outlineVariant,
                            width: id == widget.selected ? 2 : 1,
                          ),
                        ),
                        child: ExcludeSemantics(child: CatalogIcon(id)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
