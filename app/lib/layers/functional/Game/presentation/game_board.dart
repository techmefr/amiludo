import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/player_panel.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        const SizedBox(height: Space.lg),
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
        const SizedBox(height: Space.lg),
        ResponsiveGrid(
          minimumWidth: MediaQuery.sizeOf(context).width < 760 ? 150 : 280,
          children: [
            for (var i = 0; i < g.players.length; i++)
              PlayerPanel(game: g, index: i, category: selected),
          ],
        ),
        const SizedBox(height: Space.lg),
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
          child: Text(context.l10n.gameGameToolsAndRules),
        ),
      if (game.finishedAt == null && game.pack!.scoring.isNotEmpty)
        for (final p in game.players)
          OutlinedButton(
            onPressed: () => context.push('/score/${p.id}'),
            child: Text('${context.l10n.templatesScoring} · ${p.name}'),
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
          label: Text(context.l10n.gameUndo),
        ),
        OutlinedButton.icon(
          onPressed: game.cursor < game.entries.length ? controller.redo : null,
          icon: const DeckIcon(Icons.redo, size: 18),
          label: Text(context.l10n.gameRedo),
        ),
        FilledButton.icon(
          onPressed: controller.nextTurn,
          icon: const DeckIcon(Icons.skip_next, size: 18),
          label: Text(context.l10n.gameNextPlayer),
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
      SectionHeading(context.l10n.gameGameLog),
      DeckPanel(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (game.appliedEntries.isEmpty)
              Text(context.l10n.gameReadyForYourFirstMove),
            for (final e in game.appliedEntries.toList().reversed.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
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
      context.l10n.gameGameNotes,
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
        context.l10n.gameNotesGoals,
        action: IconButton(
          tooltip: context.l10n.gameEditNotes,
          onPressed: () => _edit(context),
          icon: const DeckIcon(Icons.edit_note),
        ),
      ),
      DeckPanel(
        child: Text(
          game.notes.isEmpty
              ? context.l10n.gameYourStrategyObjectivesAndNotes
              : game.notes,
        ),
      ),
    ],
  );
}
