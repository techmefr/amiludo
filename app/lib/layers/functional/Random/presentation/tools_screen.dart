import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/presentation/add_brick_sheet.dart';
import 'package:amiludo/layers/functional/Random/presentation/brick_tile.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key, this.initialTool, this.addBrick});
  final String? initialTool;
  final Future<void> Function(String templateId, Brick brick)? addBrick;
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String category = 'all', query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialTool != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) open(widget.initialTool!);
      });
    }
  }

  void open(String id) => context.push('/tools/$id');

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
    final favorites = context.watch<RandomCubit>().state.favorites;
    final shown = filterBricks(
      brickEntries,
      category: category,
      favorites: favorites.toSet(),
      query: query,
      title: context.toolTitle,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: context.l10n.randomYourToolboxWithinReach,
          title: context.l10n.randomOneToolReadyToPlay,
          subtitle: context.l10n.randomPlayersAreSharedAcrossTools,
        ),
        TextField(
          onChanged: (v) => setState(() => query = v),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.brickLibrarySearch,
            prefixIcon: const DeckIcon(Icons.search),
          ),
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final c in brickCategories)
              ChoiceChip(
                label: Text(context.toolCategoryLabel(c)),
                selected: category == c,
                onSelected: (_) => setState(() => category = c),
              ),
          ],
        ),
        const SizedBox(height: Space.xl),
        if (shown.isEmpty)
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
