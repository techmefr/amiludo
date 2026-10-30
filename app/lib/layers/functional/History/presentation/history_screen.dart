import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Files/file_transfer.dart';
import '../../Game/domain/game.dart';
import '../../Workspace/workspace_controller.dart';
import '../../Workspace/domain/workspace.dart';
import '../../Workspace/presentation/game_setup.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String query = '';
  Future<void> importGame() async {
    try {
      final text = await FileTransfer.openJson();
      if (text == null) return;
      final j = Map<String, dynamic>.from(jsonDecode(text) as Map);
      if (j['format'] != 'table-companion-game' || j['version'] != 1) {
        throw const FormatException('Format de partie incompatible');
      }
      final game = GameSession.fromJson(
            Map<String, dynamic>.from(j['game'] as Map),
          ),
          controller = ref.read(workspaceProvider.notifier);
      if (controller.data.games.any((g) => g.id == game.id)) {
        if (!mounted ||
            !await confirm(context, 'Remplacer cette partie ?', game.title)) {
          return;
        }
      }
      await controller.game(game);
      if (mounted) {
        notify(context, tr(context, 'Partie importée', 'Game imported'));
      }
    } catch (error) {
      if (mounted) notify(context, 'Import impossible : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(workspaceProvider).requireValue,
        controller = ref.read(workspaceProvider.notifier),
        theme = Theme.of(context);
    final games = ws.games
        .where(
          (g) =>
              ('${g.title} ${g.players.map((p) => p.name).join(' ')} ${DateTime.fromMillisecondsSinceEpoch(g.createdAt).toIso8601String()}')
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
        .toList();
    final completed = ws.games.where((g) => g.finishedAt != null).toList(),
        duration = completed.fold<int>(
          0,
          (sum, g) => sum + g.finishedAt! - g.createdAt,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(context, 'Les souvenirs restent', 'Keep the good times'),
          title: tr(context, 'Les bons moments', 'The good times'),
          subtitle: tr(
            context,
            'Vos parties, vos résultats. Sauvegardés sur cet appareil.',
            'Your games and results, saved on this device.',
          ),
          action: OutlinedButton(
            onPressed: importGame,
            child: Text(tr(context, 'Importer une partie', 'Import game')),
          ),
        ),
        ResponsiveGrid(
          minimumWidth: 200,
          children: [
            for (final (value, label) in [
              (
                '${completed.length}',
                tr(context, 'PARTIES TERMINÉES', 'COMPLETED GAMES'),
              ),
              (
                '${ws.games.where((g) => g.finishedAt == null).length}',
                tr(context, 'TABLES EN COURS', 'ACTIVE TABLES'),
              ),
              (
                '${(duration / 60000).round()}',
                tr(context, 'MINUTES DE JEU', 'MINUTES PLAYED'),
              ),
            ])
              DeckPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 12),
                    Text(label, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: tr(
              context,
              'Chercher un jeu, un joueur, une date',
              'Search a game, player or date',
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 24),
        if (games.isEmpty)
          EmptyPanel(
            title: tr(context, 'Aucun résultat', 'No games found'),
            message: tr(
              context,
              'Vos parties apparaissent ici dès leur création.',
              'Games appear here when created.',
            ),
          ),
        for (final g in games)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: DeckPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(g.title, style: theme.textTheme.headlineMedium),
                      Chip(
                        label: Text(
                          g.finishedAt == null
                              ? tr(context, 'En cours', 'Active')
                              : tr(context, 'Terminée', 'Complete'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateTime.fromMillisecondsSinceEpoch(g.createdAt).toLocal().toString().substring(0, 16)} · ${g.players.length} joueurs · ${g.round} manches',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  if (g.cooperative)
                    Text(
                      '${tr(context, 'Équipe', 'Team')} : ${numberText(g.players.fold<double>(0, (sum, p) => sum + g.score(p.id)))} / ${numberText(g.target)}',
                      style: theme.textTheme.titleLarge,
                    )
                  else
                    Text(
                      '${g.finishedAt == null ? tr(context, 'En tête', 'Leading') : tr(context, 'Victoire', 'Winner')} : ${g.winners.map((p) => p.name).join(' & ')}',
                      style: theme.textTheme.titleLarge,
                    ),
                  const SizedBox(height: 20),
                  for (final p in g.ranking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(p.name)),
                          Text(
                            '${numberText(g.score(p.id))} pts',
                            style: const TextStyle(fontFamily: 'IBMPlexMono'),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () async {
                          await controller.chooseGame(g.id);
                          if (context.mounted) context.go('/game');
                        },
                        child: Text(
                          g.finishedAt == null
                              ? tr(context, 'Reprendre', 'Resume')
                              : tr(context, 'Détail', 'Details'),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => showNewGame(
                          context,
                          ref,
                          names: g.players.map((p) => p.name).toList(),
                        ),
                        child: Text(tr(context, 'Revanche', 'Play again')),
                      ),
                      OutlinedButton(
                        onPressed: () => FileTransfer.shareText(
                          g.toCsv(),
                          'scores-${g.id}.csv',
                          mime: 'text/csv',
                        ),
                        child: const Text('CSV'),
                      ),
                      OutlinedButton(
                        onPressed: () => FileTransfer.shareText(
                          g.export(),
                          'partie-${g.id}.json',
                        ),
                        child: const Text('JSON'),
                      ),
                      IconButton(
                        tooltip: tr(
                          context,
                          'Supprimer la partie',
                          'Delete game',
                        ),
                        onPressed: () async {
                          if (await confirm(
                            context,
                            tr(
                              context,
                              'Supprimer cette partie ?',
                              'Delete this game?',
                            ),
                            tr(
                              context,
                              'Cette action supprime aussi les scores et les notes.',
                              'This also removes scores and notes.',
                            ),
                          )) {
                            await controller.deleteGame(g.id);
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        SectionHeading(
          tr(
            context,
            'Vos données vous appartiennent',
            'Your data belongs to you',
          ),
        ),
        DeckPanel(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => FileTransfer.shareText(
                  ws.export(),
                  'compagnon-sauvegarde.json',
                ),
                child: Text(
                  tr(context, 'Sauvegarder tout', 'Back up everything'),
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    final text = await FileTransfer.openJson();
                    if (text == null || !context.mounted) return;
                    if (!await confirm(
                      context,
                      tr(
                        context,
                        'Restaurer une sauvegarde ?',
                        'Restore backup?',
                      ),
                      tr(
                        context,
                        'La bibliothèque actuelle sera remplacée. Exportez-la avant de continuer si nécessaire.',
                        'Your current library will be replaced. Export it first if needed.',
                      ),
                    )) {
                      return;
                    }
                    await controller.importBackup(text);
                    if (context.mounted) {
                      notify(
                        context,
                        tr(context, 'Sauvegarde restaurée', 'Backup restored'),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      notify(context, 'Import impossible : $error');
                    }
                  }
                },
                child: Text(tr(context, 'Restaurer', 'Restore')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () async {
            if (await confirm(
              context,
              tr(context, 'Effacer toutes les données ?', 'Erase all data?'),
              tr(
                context,
                'Parties, modèles, profils et réglages seront supprimés de cet appareil. Cette action ne peut pas être annulée.',
                'Games, templates, profiles and settings will be removed from this device. This cannot be undone.',
              ),
            )) {
              await controller.saveWorkspace(const Workspace());
            }
          },
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text(
            tr(context, 'Effacer toutes mes données', 'Erase all my data'),
          ),
        ),
      ],
    );
  }
}
