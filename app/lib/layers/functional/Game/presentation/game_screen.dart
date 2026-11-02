import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../../../technical/Theme/deck_theme.dart';
import '../../../technical/Files/file_transfer.dart';
import '../../Workspace/workspace_controller.dart';
import '../../Workspace/presentation/game_setup.dart';
import '../../Timer/presentation/timer_panel.dart';
import '../domain/game.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? category;
  @override
  Widget build(BuildContext context) {
    final ws = ref.watch(workspaceProvider).requireValue,
        g = ws.current,
        controller = ref.read(workspaceProvider.notifier),
        theme = Theme.of(context);
    if (g == null) {
      return EmptyPanel(
        title: tr(context, 'Votre table vous attend', 'Your table awaits'),
        message: tr(
          context,
          'Créez une partie pour compter les points et suivre les tours.',
          'Create a game to track scores and turns.',
        ),
        action: FilledButton(
          onPressed: () => showNewGame(context, ref),
          child: Text(tr(context, 'Créer une partie', 'Create game')),
        ),
      );
    }
    if (!g.categories.contains(category)) category = g.categories.first;
    Future<void> customScore(Player p) async {
      final value = await textPrompt(
        context,
        '${tr(context, 'Points pour', 'Points for')} ${p.name}',
        initial: '0',
        label: tr(
          context,
          'Valeur positive ou négative',
          'Positive or negative value',
        ),
      );
      if (value == null) return;
      final number = double.tryParse(value.replaceAll(',', '.'));
      if (number == null || !number.isFinite || number.abs() > 1000000000) {
        if (context.mounted) {
          notify(context, tr(context, 'Valeur invalide', 'Invalid value'));
        }
        return;
      }
      await controller.score(p.id, number, category!);
    }

    Future<void> resource(Player p) async {
      final key = await textPrompt(
        context,
        tr(context, 'Nom du compteur', 'Counter name'),
        initial: 'Vies',
      );
      if (key == null || key.trim().isEmpty || !context.mounted) return;
      final value = await textPrompt(
        context,
        '${p.name} / $key',
        initial: numberText(p.resources[key] ?? 0),
      );
      if (value == null) return;
      final amount = double.tryParse(value.replaceAll(',', '.'));
      if (amount == null || !amount.isFinite) {
        if (context.mounted) notify(context, 'Valeur invalide');
        return;
      }
      await controller.game(
        g.copyWith(
          players: g.players
              .map(
                (player) => player.id == p.id
                    ? player.withResource(key, amount)
                    : player,
              )
              .toList(),
        ),
      );
    }

    final board = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (g.pack != null)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.push('/pack/${g.pack!.id}?session=1'),
                child: const Text('Outils et règles du jeu'),
              ),
              if (g.finishedAt == null && g.pack!.scoring.isNotEmpty)
                for (final p in g.players)
                  OutlinedButton(
                    onPressed: () => context.push('/score/${p.id}'),
                    child: Text('Décompte · ${p.name}'),
                  ),
            ],
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: g.categories
              .map(
                (c) => ChoiceChip(
                  label: Text(c),
                  selected: category == c,
                  onSelected: (_) => setState(() => category = c),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        ResponsiveGrid(
          minimumWidth: MediaQuery.sizeOf(context).width < 760 ? 150 : 280,
          children: [
            for (var i = 0; i < g.players.length; i++)
              DeckPanel(
                highlight: i == g.activeIndex,
                padding: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(g.players[i].color),
                          foregroundColor: const Color(0xff151515),
                          child: Text(g.players[i].name.characters.first),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            g.players[i].name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (i == g.activeIndex)
                          Tooltip(
                            message: tr(
                              context,
                              'Joueur actif',
                              'Active player',
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      numberText(g.score(g.players[i].id)),
                      style: TextStyle(
                        fontFamily: theme.extension<DeckStyle>()!.headingFont,
                        fontSize: 64,
                        height: 1.1,
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${tr(context, 'Manche', 'Round')} ${g.round} : ${numberText(g.score(g.players[i].id, inRound: g.round))}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    if (g.finishedAt == null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final value in [-1, 1, 5])
                            SizedBox(
                              width: 56,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => controller.score(
                                  g.players[i].id,
                                  value.toDouble(),
                                  category!,
                                ),
                                child: Text('${value > 0 ? '+' : ''}$value'),
                              ),
                            ),
                          IconButton(
                            tooltip: tr(
                              context,
                              'Valeur libre',
                              'Custom value',
                            ),
                            onPressed: () => customScore(g.players[i]),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                    if (g.players[i].resources.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          children: g.players[i].resources.entries
                              .map(
                                (e) => ActionChip(
                                  label: Text(
                                    '${e.key} ${numberText(e.value)}',
                                  ),
                                  onPressed: g.finishedAt == null
                                      ? () => resource(g.players[i])
                                      : null,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    if (g.finishedAt == null)
                      TextButton.icon(
                        onPressed: () => resource(g.players[i]),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(tr(context, 'Compteur', 'Counter')),
                      ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (g.finishedAt == null)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: g.cursor > 0 ? () => controller.undo() : null,
                icon: const Icon(Icons.undo, size: 18),
                label: Text(tr(context, 'Annuler', 'Undo')),
              ),
              OutlinedButton.icon(
                onPressed: g.cursor < g.entries.length
                    ? () => controller.redo()
                    : null,
                icon: const Icon(Icons.redo, size: 18),
                label: Text(tr(context, 'Rétablir', 'Redo')),
              ),
              FilledButton.icon(
                onPressed: () => controller.nextTurn(),
                icon: const Icon(Icons.skip_next, size: 18),
                label: Text(tr(context, 'Au suivant', 'Next player')),
              ),
            ],
          ),
        SectionHeading(tr(context, 'Le fil de la partie', 'Game log')),
        DeckPanel(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (g.appliedEntries.isEmpty)
                Text(
                  tr(
                    context,
                    'Les compteurs sont prêts. À vous de jouer.',
                    'Ready for your first move.',
                  ),
                ),
              for (final e in g.appliedEntries.toList().reversed.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${g.players.firstWhere((p) => p.id == e.playerId).name} · ${e.value > 0 ? '+' : ''}${numberText(e.value)} / ${e.category} / M${e.round}',
                  ),
                ),
            ],
          ),
        ),
        SectionHeading(
          tr(context, 'Notes & objectifs', 'Notes & goals'),
          action: IconButton(
            tooltip: tr(context, 'Modifier les notes', 'Edit notes'),
            onPressed: () async {
              final notes = await textPrompt(
                context,
                tr(context, 'Notes de partie', 'Game notes'),
                initial: g.notes,
                multiline: true,
              );
              if (notes != null) {
                await controller.game(g.copyWith(notes: notes));
              }
            },
            icon: const Icon(Icons.edit_note),
          ),
        ),
        DeckPanel(
          child: Text(
            g.notes.isEmpty
                ? tr(
                    context,
                    'Votre stratégie, vos objectifs, les petits détails à retenir.',
                    'Your strategy, objectives and notes.',
                  )
                : g.notes,
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: g.finishedAt == null
              ? tr(
                  context,
                  'Partie en cours / données locales',
                  'Active game / local data',
                )
              : tr(context, 'Partie terminée', 'Completed game'),
          title: g.title,
          subtitle:
              '${g.players.length} ${tr(context, 'joueurs', 'players')} · ${tr(context, 'Manche', 'Round')} ${g.round} · ${g.cooperative
                  ? tr(context, 'Coopération', 'Cooperative')
                  : g.lowestWins
                  ? tr(context, 'Le moins de points gagne', 'Lowest score wins')
                  : tr(context, 'Le plus de points gagne', 'Highest score wins')}',
          action: OutlinedButton(
            onPressed: () =>
                FileTransfer.shareText(g.export(), 'partie-${g.id}.json'),
            child: Text(tr(context, 'Exporter', 'Export')),
          ),
        ),
        if (g.target > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: DeckPanel(
              highlight: g.objectiveReached,
              padding: 16,
              child: Text(
                '${g.objectiveReached ? '✓ ' : ''}${tr(context, 'Objectif', 'Target')} : ${numberText(g.target)}${g.cooperative ? ' / ${numberText(g.players.fold<double>(0, (sum, p) => sum + g.score(p.id)))}' : ''}',
              ),
            ),
          ),
        if (g.finishedAt == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => controller.nextRound(),
                  child: Text(tr(context, 'Manche suivante', 'Next round')),
                ),
                OutlinedButton.icon(
                  onPressed: () => controller.saveWorkspace(
                    ws.copyWith(reverse: !ws.reverse),
                  ),
                  icon: Icon(
                    ws.reverse ? Icons.rotate_left : Icons.rotate_right,
                    size: 18,
                  ),
                  label: Text(
                    tr(context, 'Sens de rotation', 'Turn direction'),
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    if (await confirm(
                      context,
                      tr(context, 'Terminer la partie ?', 'Finish game?'),
                      tr(
                        context,
                        'Les scores seront conservés dans votre historique.',
                        'Scores will be kept in your history.',
                      ),
                    )) {
                      await controller.finish();
                      if (context.mounted) context.go('/history');
                    }
                  },
                  child: Text(tr(context, 'Terminer', 'Finish')),
                ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth > 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: board),
                    const SizedBox(width: 24),
                    const SizedBox(width: 280, child: TimerPanel()),
                  ],
                )
              : Column(
                  children: [
                    board,
                    const SizedBox(height: 24),
                    if (g.finishedAt == null) const TimerPanel(),
                  ],
                ),
        ),
        if (g.finishedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: FilledButton(
              onPressed: () => showNewGame(
                context,
                ref,
                names: g.players.map((p) => p.name).toList(),
              ),
              child: Text(tr(context, 'La revanche', 'Play again')),
            ),
          ),
      ],
    );
  }
}
