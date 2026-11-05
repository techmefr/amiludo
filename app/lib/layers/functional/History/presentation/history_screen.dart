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
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        notify(context, context.l10n.historyGameImported);
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
          eyebrow: context.l10n.historyKeepTheGoodTimes,
          title: context.l10n.historyTheGoodTimes,
          subtitle: context.l10n.historyYourGamesAndResultsSaved,
          action: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: importGame,
                child: Text(context.l10n.historyImportGame),
              ),
              OutlinedButton(
                onPressed: () => context.push('/memories/import'),
                child: Text(context.l10n.historyOpenGallery),
              ),
            ],
          ),
        ),
        _HistoryStats(workspace: ws),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.historySearchAGamePlayerOr,
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
            icon: Icons.history,
            title: context.l10n.historyNoGamesFound,
            message: context.l10n.historyGamesAppearHereWhenCreated,
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
      ('${completed.length}', context.l10n.historyCompletedGames),
      (
        '${workspace.games.where((g) => g.finishedAt == null).length}',
        context.l10n.historyActiveTables,
      ),
      ('${(duration / 60000).round()}', context.l10n.historyMinutesPlayed),
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
        context.l10n.historyRestoreBackup,
        context.l10n.historyYourCurrentLibraryWillBe,
      )) {
        return;
      }
      await controller.importBackup(text);
      if (context.mounted) {
        notify(context, context.l10n.historyBackupRestored);
      }
    } catch (error) {
      if (context.mounted) notify(context, 'Import impossible : $error');
    }
  }

  Future<void> _erase(BuildContext context) async {
    final controller = context.read<HistoryCubit>();
    if (await confirm(
      context,
      context.l10n.historyEraseAllData,
      context.l10n.historyGamesTemplatesProfilesAndSettings,
    )) {
      await controller.erase();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.historyYourDataBelongsToYou),
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
              child: Text(context.l10n.historyBackUpEverything),
            ),
            OutlinedButton(
              onPressed: () => _restore(context),
              child: Text(context.l10n.historyRestore),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      TextButton.icon(
        onPressed: () => _erase(context),
        icon: const DeckIcon(Icons.delete_forever_outlined),
        label: Text(context.l10n.historyEraseAllMyData),
      ),
    ],
  );
}
