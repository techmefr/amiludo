import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key, this.initialTool});
  final String? initialTool;
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String category = 'Tous';
  @override
  void initState() {
    super.initState();
    if (widget.initialTool != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) open(widget.initialTool!);
      });
    }
  }

  Future<void> open(String id) async {
    context.push('/tools/$id');
  }

  Widget toolCard(ToolDefinition t, bool favorite) => DeckPanel(
    padding: 20,
    color: toolSurface(context, t.id),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: GameArt(tool: t.id, height: 112)),
            IconButton(
              tooltip: context.l10n.randomFavorite,
              onPressed: () => context.read<RandomCubit>().toggleFavorite(t.id),
              icon: DeckIcon(
                favorite ? Icons.star : Icons.star_outline,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(t.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(t.subtitle),
        const SizedBox(height: 16),
        const Spacer(),
        OutlinedButton(
          onPressed: () => open(t.id),
          child: Text(context.l10n.workspaceOpen),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<RandomCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: context.l10n.randomYourToolboxWithinReach,
          title: context.l10n.randomOneToolReadyToPlay,
          subtitle: context.l10n.randomPlayersAreSharedAcrossTools,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Tous', 'Hasard', 'Partie', 'Temps']
              .map(
                (c) => ChoiceChip(
                  label: Text(c),
                  selected: category == c,
                  onSelected: (_) => setState(() => category = c),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        ResponsiveGrid(
          minimumWidth: 210,
          children: toolDefinitions
              .where((t) => category == 'Tous' || t.category == category)
              .map((t) => toolCard(t, ws.favorites.contains(t.id)))
              .toList(),
        ),
      ],
    );
  }
}
