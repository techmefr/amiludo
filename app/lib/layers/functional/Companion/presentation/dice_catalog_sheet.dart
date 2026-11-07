import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_preview.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const catalogSides = [2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 30, 60, 100, 1000];

Future<void> showDiceCatalogSheet(
  BuildContext context, {
  required List<String> favorites,
  required List<DieDesign> library,
  required ValueChanged<DiceSpec> onAdd,
  required ValueChanged<String> onFavorite,
  ValueChanged<DieDesign>? onEdit,
}) => showDeckSheet<void>(
  context: context,
  title: context.l10n.diceSeeMore,
  builder: (_) => DiceCatalogGrid(
    favorites: favorites,
    library: library,
    onAdd: onAdd,
    onFavorite: onFavorite,
    onEdit: onEdit,
  ),
);

class DiceCatalogGrid extends StatefulWidget {
  const DiceCatalogGrid({
    super.key,
    required this.favorites,
    required this.onAdd,
    required this.onFavorite,
    this.library = const [],
    this.onEdit,
  });
  final List<String> favorites;
  final List<DieDesign> library;
  final ValueChanged<DiceSpec> onAdd;
  final ValueChanged<String> onFavorite;
  final ValueChanged<DieDesign>? onEdit;

  @override
  State<DiceCatalogGrid> createState() => _DiceCatalogGridState();
}

class _DiceCatalogGridState extends State<DiceCatalogGrid> {
  late final Set<String> starred = {...widget.favorites};
  bool onlyFavorites = false;

  void star(String key) {
    setState(
      () => starred.contains(key) ? starred.remove(key) : starred.add(key),
    );
    widget.onFavorite(key);
  }

  Widget tile(DiceSpec spec, {DieDesign? design}) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final on = starred.contains(spec.key);
    return Card(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.md),
              onTap: () => widget.onAdd(spec),
              child: Center(
                child: design == null
                    ? Text(spec.name, style: theme.textTheme.headlineSmall)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DiePreview(design: design, size: 48),
                          Text(spec.name, overflow: TextOverflow.ellipsis),
                        ],
                      ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: on ? l.diceFavoriteRemove : l.diceFavoriteAdd,
              visualDensity: VisualDensity.compact,
              onPressed: () => star(spec.key),
              icon: Icon(on ? Icons.bookmark : Icons.bookmark_border),
            ),
          ),
          if (design != null && widget.onEdit != null)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                tooltip: l.diceEdit,
                visualDensity: VisualDensity.compact,
                onPressed: () => widget.onEdit!(design),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = <_Entry>[
      for (final s in catalogSides) _Entry(DiceSpec(sides: s)),
      for (final d in widget.library) _Entry(DiceSpec.fromDesign(d), d),
    ].where((e) => !onlyFavorites || starred.contains(e.spec.key));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterChip(
          avatar: const Icon(Icons.bookmark_border),
          label: Text(l.diceFavorites),
          selected: onlyFavorites,
          onSelected: (v) => setState(() => onlyFavorites = v),
        ),
        const SizedBox(height: Space.md),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Space.sm,
          crossAxisSpacing: Space.sm,
          childAspectRatio: 1.1,
          children: [for (final e in entries) tile(e.spec, design: e.design)],
        ),
      ],
    );
  }
}

class _Entry {
  const _Entry(this.spec, [this.design]);

  final DiceSpec spec;
  final DieDesign? design;
}
