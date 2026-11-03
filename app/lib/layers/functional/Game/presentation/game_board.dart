import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/player_panel.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key, required this.game});
  final GameSession game;
  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  String? category;
  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final selected = g.categories.contains(category)
        ? category!
        : g.categories.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (g.pack != null) _PackShortcuts(game: g),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in g.categories)
              ChoiceChip(
                label: Text(c),
                selected: selected == c,
                onSelected: (_) => setState(() => category = c),
              ),
          ],
        ),
        const SizedBox(height: 20),
        ResponsiveGrid(
          minimumWidth: MediaQuery.sizeOf(context).width < 760 ? 150 : 280,
          children: [
            for (var i = 0; i < g.players.length; i++)
              PlayerPanel(game: g, index: i, category: selected),
          ],
        ),
        const SizedBox(height: 20),
        if (g.finishedAt == null) _TurnControls(game: g),
        _GameLog(game: g),
        _GameNotes(game: g),
      ],
    );
  }
}

class _PackShortcuts extends StatelessWidget {
  const _PackShortcuts({required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      if (game.finishedAt != null)
        OutlinedButton(
          onPressed: () => context.push('/pack/${game.pack!.id}?session=1'),
          child: Text(
            tr(context, 'Outils et règles du jeu', 'Game tools and rules'),
          ),
        ),
      if (game.finishedAt == null && game.pack!.scoring.isNotEmpty)
        for (final p in game.players)
          OutlinedButton(
            onPressed: () => context.push('/score/${p.id}'),
            child: Text('${tr(context, 'Décompte', 'Scoring')} · ${p.name}'),
          ),
    ],
  );
}

class _TurnControls extends StatelessWidget {
  const _TurnControls({required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameCubit>();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: game.cursor > 0 ? controller.undo : null,
          icon: const DeckIcon(Icons.undo, size: 18),
          label: Text(tr(context, 'Annuler', 'Undo')),
        ),
        OutlinedButton.icon(
          onPressed: game.cursor < game.entries.length ? controller.redo : null,
          icon: const DeckIcon(Icons.redo, size: 18),
          label: Text(tr(context, 'Rétablir', 'Redo')),
        ),
        FilledButton.icon(
          onPressed: controller.nextTurn,
          icon: const DeckIcon(Icons.skip_next, size: 18),
          label: Text(tr(context, 'Au suivant', 'Next player')),
        ),
      ],
    );
  }
}

class _GameLog extends StatelessWidget {
  const _GameLog({required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(tr(context, 'Le fil de la partie', 'Game log')),
      DeckPanel(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (game.appliedEntries.isEmpty)
              Text(
                tr(
                  context,
                  'Les compteurs sont prêts. À vous de jouer.',
                  'Ready for your first move.',
                ),
              ),
            for (final e in game.appliedEntries.toList().reversed.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${game.players.firstWhere((p) => p.id == e.playerId).name} · ${e.value > 0 ? '+' : ''}${numberText(e.value)} / ${e.category} / M${e.round}',
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _GameNotes extends StatelessWidget {
  const _GameNotes({required this.game});
  final GameSession game;

  Future<void> _edit(BuildContext context) async {
    final controller = context.read<GameCubit>();
    final notes = await textPrompt(
      context,
      tr(context, 'Notes de partie', 'Game notes'),
      initial: game.notes,
      multiline: true,
    );
    if (notes != null) await controller.saveGame(game.copyWith(notes: notes));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(
        tr(context, 'Notes & objectifs', 'Notes & goals'),
        action: IconButton(
          tooltip: tr(context, 'Modifier les notes', 'Edit notes'),
          onPressed: () => _edit(context),
          icon: const DeckIcon(Icons.edit_note),
        ),
      ),
      DeckPanel(
        child: Text(
          game.notes.isEmpty
              ? tr(
                  context,
                  'Votre stratégie, vos objectifs, les petits détails à retenir.',
                  'Your strategy, objectives and notes.',
                )
              : game.notes,
        ),
      ),
    ],
  );
}
