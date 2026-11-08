import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_card.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_category_tile.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_hero_card.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ToolsHome extends StatelessWidget {
  const ToolsHome({
    super.key,
    required this.favorites,
    required this.lastTool,
    required this.onOpen,
    required this.onFavorite,
    required this.onMove,
    required this.onCategory,
    this.category,
    this.onAdd,
  });
  final List<String> favorites;
  final String? lastTool;
  final void Function(String id) onOpen, onFavorite, onCategory;
  final String? category;
  final void Function(String tool, String before) onMove;
  final void Function(BrickEntry entry)? onAdd;

  String get _hero => heroTool(lastTool: lastTool, favorites: favorites);
  List<String> get _pinned => pinnedTools(favorites, _hero);

  ToolCard _card(BuildContext context, String id, {Key? key, int? slot}) {
    final pinned = _pinned;
    final entry = brickEntries.firstWhere((e) => e.id == id);
    return ToolCard(
      key: key ?? ValueKey(id),
      id: id,
      favorite: favorites.contains(id),
      onFavorite: () => onFavorite(id),
      onOpen: () => onOpen(id),
      onAdd: onAdd == null ? null : () => onAdd!(entry),
      onMoveEarlier: slot == null || slot == 0
          ? null
          : () => onMove(id, pinned[slot - 1]),
      onMoveLater: slot == null || slot >= pinned.length - 1
          ? null
          : () => onMove(pinned[slot + 1], id),
    );
  }

  Widget _row(
    BuildContext context,
    List<Widget> cards, {
    bool reorder = false,
  }) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final height =
        ToolCard.previewHeight + Space.xl * 2 + 88 * (scale < 1 ? 1 : scale);
    final behavior = ScrollConfiguration.of(context).copyWith(
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      },
    );
    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: behavior,
        child: reorder
            ? ReorderableListView(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                proxyDecorator: (child, _, _) => child,
                onReorderItem: _reorder,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    ReorderableDelayedDragStartListener(
                      key: cards[i].key,
                      index: i,
                      child: Padding(
                        padding: const EdgeInsets.only(right: Space.md),
                        child: cards[i],
                      ),
                    ),
                ],
              )
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: Space.md),
                itemBuilder: (_, i) => cards[i],
              ),
      ),
    );
  }

  void _reorder(int from, int to) {
    final pinned = _pinned;
    final target = to;
    if (target == from) return;
    final rest = [...pinned]..removeAt(from);
    onMove(pinned[from], target >= rest.length ? '' : rest[target]);
  }

  Widget _title(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: Space.xl, bottom: Space.sm),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    ),
  );

  Widget _menu(BuildContext context) => ResponsiveGrid(
    minimumWidth: 280,
    children: [
      for (final shelf in toolShelves)
        if (shelf.tools.isNotEmpty)
          ToolCategoryTile(shelf: shelf, onOpen: () => onCategory(shelf.id)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final open = category == null ? null : toolShelf(category!);
    if (open != null) {
      return Wrap(
        spacing: Space.md,
        runSpacing: Space.md,
        children: [for (final id in open.tools) _card(context, id)],
      );
    }
    final hero = _hero, pinned = _pinned;
    final inner = [
      for (var i = 0; i < pinned.length; i++)
        _card(context, pinned[i], slot: i),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToolHeroCard(
          id: hero,
          resume: lastTool == hero,
          onOpen: () => onOpen(hero),
        ),
        if (pinned.isNotEmpty) ...[
          _title(context, context.toolShelfLabel('pinned')),
          _row(context, inner, reorder: true),
        ],
        const SizedBox(height: Space.xl),
        _menu(context),
      ],
    );
  }
}
