import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';

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

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<RandomCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(
            context,
            'La boîte à outils / à portée de main',
            'Your toolbox / within reach',
          ),
          title: tr(
            context,
            'Un outil, et c’est parti',
            'One tool. Ready to play.',
          ),
          subtitle: tr(
            context,
            'Vos joueurs sont partagés entre tous les outils. Les tirages utilisent le générateur sécurisé du système.',
            'Players are shared across tools. Random draws use the system secure generator.',
          ),
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
              .map(
                (t) => DeckPanel(
                  padding: 20,
                  color: toolSurface(context, t.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: GameArt(tool: t.id, height: 112)),
                          IconButton(
                            tooltip: tr(context, 'Favori', 'Favorite'),
                            onPressed: () => context
                                .read<RandomCubit>()
                                .toggleFavorite(t.id),
                            icon: DeckIcon(
                              ws.favorites.contains(t.id)
                                  ? Icons.star
                                  : Icons.star_outline,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(t.subtitle),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => open(t.id),
                        child: Text(tr(context, 'Ouvrir ↗', 'Open ↗')),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
