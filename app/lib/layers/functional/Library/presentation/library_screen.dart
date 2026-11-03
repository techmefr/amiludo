import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/bookshelf.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_sheet.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  String? genre;

  bool _matches(ShelfGame game) =>
      game.name.toLowerCase().contains(query.toLowerCase()) &&
      (genre == null || game.genres.contains(genre));

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<LibraryCubit>().state.games;
    final games = shelf.where(_matches).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(context, 'Ludothèque', 'Game shelf'),
          title: tr(context, 'Mes jeux', 'My games'),
          subtitle: tr(
            context,
            '${shelf.length} boîtes rangées sur cet appareil.',
            '${shelf.length} boxes stored on this device.',
          ),
          action: FilledButton(
            onPressed: () => context.push('/library/edit/new'),
            child: Text(tr(context, 'Ajouter un jeu', 'Add a game')),
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
          const SizedBox(height: 24),
        ],
        if (games.isEmpty)
          EmptyPanel(
            title: shelf.isEmpty
                ? tr(context, 'Étagères vides', 'Empty shelves')
                : tr(context, 'Aucun jeu trouvé', 'No game found'),
            message: tr(
              context,
              'Rangez vos boîtes ici pour retrouver vos jeux, vos packs et vos avis.',
              'Store your boxes here to find your games, packs and reviews.',
            ),
          )
        else
          Bookshelf(
            games: games,
            onOpen: (game) => showShelfGameSheet(context, game),
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
      OutlinedButton(
        onPressed: () => context.push('/library/tonight'),
        child: Text(tr(context, 'On joue à quoi ce soir ?', 'What to play?')),
      ),
      OutlinedButton(
        onPressed: () => context.push('/share/receive'),
        child: Text(tr(context, 'Recevoir par QR', 'Receive by QR')),
      ),
      OutlinedButton(
        onPressed: () => context.push('/share'),
        child: Text(tr(context, 'Partager une session', 'Share a session')),
      ),
      TextButton(
        onPressed: () => context.go('/templates'),
        child: Text(tr(context, 'Packs et modèles', 'Packs and templates')),
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
          labelText: tr(context, 'Chercher un jeu', 'Search a game'),
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
