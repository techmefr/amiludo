import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

Future<void> showShelfGameSheet(BuildContext context, ShelfGame game) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => BlocProvider.value(
        value: context.read<LibraryCubit>(),
        child: _ShelfGameSheet(game: game),
      ),
    );

List<GameTemplate> linkedTemplates(Workspace data, ShelfGame game) => [
  ...GameTemplate.builtIn,
  ...data.templates,
].where((t) => game.templateIds.contains(t.id)).toList();

class _ShelfGameSheet extends StatelessWidget {
  const _ShelfGameSheet({required this.game});

  final ShelfGame game;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LibraryCubit>();
    final data = cubit.state;
    final theme = Theme.of(context);
    final templates = linkedTemplates(data, game);
    final plays = data.games
        .where(
          (g) =>
              g.title.toLowerCase() == game.name.toLowerCase() ||
              (g.pack != null && game.templateIds.contains(g.pack!.id)),
        )
        .length;
    final stars = averageStars(
      cubit.circle.reviews.where(
        (r) => r.concerns(game.name, game.templateIds),
      ),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game.name, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '${game.minPlayers}-${game.maxPlayers} ${tr(context, 'joueurs', 'players')} · ${game.minutes} min · $plays ${tr(context, 'parties', 'plays')}${stars == null ? '' : ' · ${stars.toStringAsFixed(1)} ★'}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in game.genres)
                  Chip(
                    label: Text(
                      tr(
                        context,
                        gameGenreLabels[g]!.$1,
                        gameGenreLabels[g]!.$2,
                      ),
                    ),
                  ),
                for (final t in templates)
                  Chip(
                    avatar: const DeckIcon(Icons.style_outlined, size: 16),
                    label: Text(t.name),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _SheetActions(game: game, templates: templates),
          ],
        ),
      ),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({required this.game, required this.templates});

  final ShelfGame game;
  final List<GameTemplate> templates;

  Future<void> _remove(BuildContext context) async {
    final cubit = context.read<LibraryCubit>();
    final navigator = Navigator.of(context);
    if (await confirm(
      context,
      tr(context, 'Retirer ce jeu ?', 'Remove this game?'),
      game.name,
    )) {
      await cubit.remove(game.id);
      navigator.pop();
    }
  }

  void _open(BuildContext context, String route, {Object? extra}) {
    Navigator.of(context).pop();
    context.push(route, extra: extra);
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      FilledButton(
        onPressed: () => _open(
          context,
          GameSetupRequest.path,
          extra: GameSetupRequest(
            template: templates.isEmpty
                ? GameTemplate(id: 'shelf-${game.id}', name: game.name)
                : templates.first,
          ),
        ),
        child: Text(tr(context, 'Jouer', 'Play')),
      ),
      OutlinedButton(
        onPressed: () => _open(context, '/share?game=${game.id}'),
        child: Text(tr(context, 'Partager en QR', 'Share by QR')),
      ),
      OutlinedButton(
        onPressed: () => _open(context, '/library/edit/${game.id}'),
        child: Text(tr(context, 'Modifier', 'Edit')),
      ),
      IconButton(
        tooltip: tr(context, 'Retirer de la ludothèque', 'Remove from shelf'),
        onPressed: () => _remove(context),
        icon: const DeckIcon(Icons.delete_outline),
      ),
    ],
  );
}
