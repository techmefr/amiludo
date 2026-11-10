import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/functional/Random/presentation/add_brick_sheet.dart';
import 'package:amiludo/layers/functional/Random/presentation/brick_tile.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/tools_home.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/components/reveal_margin.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({
    super.key,
    this.initialTool,
    this.initialCategory,
    this.addBrick,
  });
  final String? initialTool, initialCategory;
  final Future<void> Function(String templateId, Brick brick)? addBrick;
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialTool != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) open(widget.initialTool!);
      });
    }
  }

  void openCategory(String id) {
    if (id == 'time') {
      open('timer');
      return;
    }
    context.push('/tools?category=$id');
  }

  void open(String id) {
    context.read<RandomCubit>().rememberTool(id);
    context.push('/tools/$id');
  }

  Future<void> add(BrickEntry entry) async {
    final templates = context.read<RandomCubit>().state.templates;
    final messenger = ScaffoldMessenger.of(context);
    final added = context.l10n.brickAdded;
    final id = await chooseCompanion(context, templates);
    if (id == null) return;
    await widget.addBrick!(id, entry.toBrick());
    messenger.showSnackBar(SnackBar(content: Text(added)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RandomCubit>().state;
    final favorites = state.favorites;
    final shown = filterBricks(
      brickEntries,
      category: 'all',
      favorites: favorites.toSet(),
      query: query,
      title: context.toolTitle,
    );
    final inCategory = toolShelf(widget.initialCategory ?? '') != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inCategory)
          DeckHeading(title: context.toolShelfLabel(widget.initialCategory!)),
        if (!inCategory)
          DeckHeading(
            eyebrow: context.l10n.randomYourToolboxWithinReach,
            title: context.l10n.randomOneToolReadyToPlay,
            subtitle: context.l10n.randomPlayersAreSharedAcrossTools,
          ),
        if (!inCategory) ...[
          TextField(
            onChanged: (v) => setState(() => query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.l10n.brickLibrarySearch,
              prefixIcon: const DeckIcon(Icons.search),
            ),
          ),
        ],
        const SizedBox(height: Space.xl),
        if (inCategory || query.trim().isEmpty)
          RevealMargin(
            top: Targets.minimum * 3,
            child: ToolsHome(
              favorites: favorites,
              lastTool: state.lastTool,
              onOpen: open,
              onFavorite: context.read<RandomCubit>().toggleFavorite,
              onMove: context.read<RandomCubit>().moveFavorite,
              onCategory: openCategory,
              category: widget.initialCategory,
              onAdd: widget.addBrick == null ? null : add,
            ),
          )
        else if (shown.isEmpty)
          Text(context.l10n.brickLibraryNone)
        else
          ResponsiveGrid(
            minimumWidth: 210,
            children: [
              for (final e in shown)
                BrickTile(
                  key: ValueKey(e.id),
                  entry: e,
                  favorite: favorites.contains(e.id),
                  onFavorite: () =>
                      context.read<RandomCubit>().toggleFavorite(e.id),
                  onOpen: () => open(e.id),
                  onAdd: widget.addBrick == null ? null : () => add(e),
                ),
            ],
          ),
      ],
    );
  }
}
