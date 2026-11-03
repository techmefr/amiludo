import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/History/presentation/cubit/history_cubit.dart';
import 'package:amiludo/layers/functional/History/presentation/history_game_card.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String query = '';

  bool _matches(GameSession g) =>
      ('${g.title} ${g.players.map((p) => p.name).join(' ')} ${DateTime.fromMillisecondsSinceEpoch(g.createdAt).toIso8601String()}')
          .toLowerCase()
          .contains(query.toLowerCase());

  Future<void> importGame() async {
    final controller = context.read<HistoryCubit>();
    try {
      final text = await FileTransfer.openJson();
      if (text == null) return;
      final j = Map<String, dynamic>.from(jsonDecode(text) as Map);
      if (j['format'] != 'table-companion-game' || j['version'] != 1) {
        throw const FormatException('Format de partie incompatible');
      }
      final game = GameSession.fromJson(
        Map<String, dynamic>.from(j['game'] as Map),
      );
      if (controller.state.games.any((g) => g.id == game.id)) {
        if (!mounted ||
            !await confirm(context, 'Remplacer cette partie ?', game.title)) {
          return;
        }
      }
      await controller.saveGame(game);
      if (mounted) {
        notify(context, tr(context, 'Partie importée', 'Game imported'));
      }
    } catch (error) {
      if (mounted) notify(context, 'Import impossible : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = context.watch<HistoryCubit>().state;
    final games = ws.games.where(_matches).toList();
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
          action: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: importGame,
                child: Text(tr(context, 'Importer une partie', 'Import game')),
              ),
              OutlinedButton(
                onPressed: () => context.push('/memories/import'),
                child: Text(tr(context, 'Ouvrir une galerie', 'Open gallery')),
              ),
            ],
          ),
        ),
        _HistoryStats(workspace: ws),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: tr(
              context,
              'Chercher un jeu, un joueur, une date',
              'Search a game, player or date',
            ),
            prefixIcon: const Center(
              widthFactor: 1,
              heightFactor: 1,
              child: DeckIcon(Icons.search, size: 20),
            ),
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
        for (final g in games) HistoryGameCard(game: g),
        const _DataControls(),
      ],
    );
  }
}

class _HistoryStats extends StatelessWidget {
  const _HistoryStats({required this.workspace});
  final Workspace workspace;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phone = MediaQuery.sizeOf(context).width < 600;
    final completed = workspace.games.where((g) => g.finishedAt != null);
    final duration = completed.fold<int>(
      0,
      (sum, g) => sum + g.finishedAt! - g.createdAt,
    );
    final stats = [
      (
        '${completed.length}',
        tr(context, 'PARTIES TERMINÉES', 'COMPLETED GAMES'),
      ),
      (
        '${workspace.games.where((g) => g.finishedAt == null).length}',
        tr(context, 'TABLES EN COURS', 'ACTIVE TABLES'),
      ),
      (
        '${(duration / 60000).round()}',
        tr(context, 'MINUTES DE JEU', 'MINUTES PLAYED'),
      ),
    ];
    return ResponsiveGrid(
      minimumWidth: phone ? 96 : 200,
      children: [
        for (final (value, label) in stats)
          DeckPanel(
            padding: phone ? 14 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: phone ? 10 : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DataControls extends StatelessWidget {
  const _DataControls();

  Future<void> _restore(BuildContext context) async {
    final controller = context.read<HistoryCubit>();
    try {
      final text = await FileTransfer.openJson();
      if (text == null || !context.mounted) return;
      if (!await confirm(
        context,
        tr(context, 'Restaurer une sauvegarde ?', 'Restore backup?'),
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
        notify(context, tr(context, 'Sauvegarde restaurée', 'Backup restored'));
      }
    } catch (error) {
      if (context.mounted) notify(context, 'Import impossible : $error');
    }
  }

  Future<void> _erase(BuildContext context) async {
    final controller = context.read<HistoryCubit>();
    if (await confirm(
      context,
      tr(context, 'Effacer toutes les données ?', 'Erase all data?'),
      tr(
        context,
        'Parties, modèles, profils et réglages seront supprimés de cet appareil. Cette action ne peut pas être annulée.',
        'Games, templates, profiles and settings will be removed from this device. This cannot be undone.',
      ),
    )) {
      await controller.erase();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
                context.read<HistoryCubit>().exportBackup(),
                'compagnon-sauvegarde.json',
              ),
              child: Text(
                tr(context, 'Sauvegarder tout', 'Back up everything'),
              ),
            ),
            OutlinedButton(
              onPressed: () => _restore(context),
              child: Text(tr(context, 'Restaurer', 'Restore')),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      TextButton.icon(
        onPressed: () => _erase(context),
        icon: const DeckIcon(Icons.delete_forever_outlined),
        label: Text(
          tr(context, 'Effacer toutes mes données', 'Erase all my data'),
        ),
      ),
    ],
  );
}
