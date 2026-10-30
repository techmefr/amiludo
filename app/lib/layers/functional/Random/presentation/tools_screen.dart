import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Theme/deck_icons.dart';
import '../../Workspace/workspace_controller.dart';
import '../domain/tool_catalog.dart';
import 'dice_tool.dart';
import 'finger_tool.dart';
import 'random_tool.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key, this.initialTool});
  final String? initialTool;
  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
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
    if (id == 'scores') {
      context.go('/game');
      return;
    }
    if (id == 'timer') {
      context.go('/timer');
      return;
    }
    final ws = ref.read(workspaceProvider).requireValue,
        names =
            ws.current?.players.map((p) => p.name).toList() ?? ws.playerNames;
    final child = switch (id) {
      'dice' => const DiceTool(),
      'picker' => FingerTool(names: names),
      _ => RandomTool(id: id, names: names),
    };
    await showFormDialog<void>(
      context: context,
      builder: (dialog) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 800),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                child: SingleChildScrollView(child: child),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  tooltip: tr(context, 'Fermer', 'Close'),
                  onPressed: () => Navigator.pop(dialog),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(workspaceProvider).requireValue;
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            toolIcon(t.id),
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: tr(context, 'Favori', 'Favorite'),
                            onPressed: () => ref
                                .read(workspaceProvider.notifier)
                                .toggleFavorite(t.id),
                            icon: Icon(
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
                        t.title.toUpperCase(),
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
