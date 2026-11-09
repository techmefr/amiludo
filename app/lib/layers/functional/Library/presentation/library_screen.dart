import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/bookshelf.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/library_stats.dart';
import 'package:amiludo/layers/functional/Library/presentation/game_cards.dart';
import 'package:amiludo/layers/functional/Library/presentation/library_stats_bar.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_sheet.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  String? genre;
  bool cards = false;
  bool neverPlayed = false;

  bool _matches(ShelfGame game, LibraryStats stats) =>
      game.name.toLowerCase().contains(query.toLowerCase()) &&
      (genre == null || game.genres.contains(genre)) &&
      (!neverPlayed || stats.neverPlayed.contains(game.id));

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<LibraryCubit>().state.games;
    final stats = context.read<LibraryCubit>().statsFor(context.watch<LibraryCubit>().state);
    final games = shelf.where((g) => _matches(g, stats)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: context.l10n.libraryGameShelf,
          title: context.l10n.libraryMyGames,
          subtitle: context.l10n.libraryBoxesStoredOnThisDevice(shelf.length),
          action: FilledButton(
            onPressed: () => context.push('/library/edit/new'),
            child: Text(context.l10n.libraryAddAGame),
          ),
        ),
        const _LibraryActions(),
        const SizedBox(height: 24),
        if (shelf.isNotEmpty) ...[
          _LibraryFilters(
            genre: genre,
            onQuery: (v) => setState(() => query = v),
            onGenre: (v) => setState(() => genre = v),
          ),
          const SizedBox(height: 16),
          LibraryStatsBar(
            stats: stats,
            neverPlayedOnly: neverPlayed,
            onToggle: (v) => setState(() => neverPlayed = v),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.view_week_outlined),
                label: Text(context.l10n.libraryViewShelf),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.grid_view_outlined),
                label: Text(context.l10n.libraryViewCards),
              ),
            ],
            selected: {cards},
            onSelectionChanged: (v) => setState(() => cards = v.first),
          ),
          const SizedBox(height: 24),
        ],
        if (games.isEmpty)
          EmptyPanel(
            icon: Icons.collections_bookmark_outlined,
            illustration: shelf.isEmpty
                ? 'assets/illustrations/shelf-empty.png'
                : 'assets/illustrations/no-game.png',
            title: shelf.isEmpty
                ? context.l10n.libraryEmptyShelves
                : context.l10n.libraryNoGameFound,
            message: context.l10n.libraryStoreYourBoxesHereTo,
          )
        else
          AnimatedSwitcher(
            duration: Motion.of(context, Motion.base),
            child: cards
                ? GameCards(
                    key: const ValueKey('cards'),
                    games: games,
                    onOpen: (game) => showShelfGameSheet(context, game),
                  )
                : Bookshelf(
                    key: const ValueKey('shelf'),
                    games: games,
                    onOpen: (game) => showShelfGameSheet(context, game),
                  ),
          ),
      ],
    );
  }
}

class _LibraryActions extends StatelessWidget {
  const _LibraryActions();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      FilledButton.tonal(
        onPressed: () => context.push('/library/scan'),
        child: Text(context.l10n.libraryScanBox),
      ),
      OutlinedButton(
        onPressed: () => context.push('/library/tonight'),
        child: Text(context.l10n.libraryWhatToPlay),
      ),
      OutlinedButton(
        onPressed: () => context.push('/share/receive'),
        child: Text(context.l10n.libraryReceiveByQr),
      ),
      OutlinedButton(
        onPressed: () => context.push('/share'),
        child: Text(context.l10n.libraryShareASession),
      ),
      TextButton(
        onPressed: () => context.go('/templates'),
        child: Text(context.l10n.libraryPacksAndTemplates),
      ),
    ],
  );
}

class _LibraryFilters extends StatelessWidget {
  const _LibraryFilters({
    required this.genre,
    required this.onQuery,
    required this.onGenre,
  });

  final String? genre;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onGenre;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        decoration: InputDecoration(
          labelText: context.l10n.librarySearchAGame,
          prefixIcon: const Center(
            widthFactor: 1,
            heightFactor: 1,
            child: DeckIcon(Icons.search, size: 20),
          ),
        ),
        onChanged: onQuery,
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final g in gameGenres)
            FilterChip(
              label: Text(
                tr(context, gameGenreLabels[g]!.$1, gameGenreLabels[g]!.$2),
              ),
              selected: genre == g,
              onSelected: (on) => onGenre(on ? g : null),
            ),
        ],
      ),
    ],
  );
}
