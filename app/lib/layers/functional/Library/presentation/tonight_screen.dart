import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Library/domain/use_cases/suggest_games_use_case.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_sheet.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class TonightScreen extends StatefulWidget {
  const TonightScreen({super.key});

  @override
  State<TonightScreen> createState() => _TonightScreenState();
}

class _TonightScreenState extends State<TonightScreen> {
  final guests = <String>{};

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LibraryCubit>();
    final friends = cubit.state.friends;
    final suggestions = cubit.suggest(guests.toList());
    return FullPage(
      title: tr(context, 'On joue à quoi ce soir ?', 'What to play tonight?'),
      fallback: '/library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'Qui est là ?', 'Who is here?'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (friends.isEmpty)
            TextButton(
              onPressed: () => context.go('/friends'),
              child: Text(tr(context, 'Ajouter des amis', 'Add friends')),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in friends)
                FilterChip(
                  avatar: CircleAvatar(backgroundColor: Color(f.color)),
                  label: Text(f.name),
                  selected: guests.contains(f.id),
                  onSelected: (on) => setState(
                    () => on ? guests.add(f.id) : guests.remove(f.id),
                  ),
                ),
            ],
          ),
          SectionHeading(
            tr(
              context,
              '${suggestions.length} jeux pour ${guests.length + 1} joueurs',
              '${suggestions.length} games for ${guests.length + 1} players',
            ),
          ),
          if (suggestions.isEmpty)
            EmptyPanel(
              title: tr(context, 'Rien ne convient', 'Nothing fits'),
              message: tr(
                context,
                'Ajoutez des jeux ou assouplissez les goûts de vos amis.',
                'Add games or relax your friends’ tastes.',
              ),
            ),
          for (final s in suggestions) _SuggestionTile(suggestion: s),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion});

  final GameSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final game = suggestion.game;
    final stars = suggestion.averageStars;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DeckPanel(
        padding: 8,
        child: ListTile(
          leading: Container(width: 10, height: 44, color: Color(game.color)),
          title: Text(game.name),
          subtitle: Text(
            '${game.minPlayers}-${game.maxPlayers} · ${game.minutes} min${stars == null ? '' : ' · ${stars.toStringAsFixed(1)} ★'}',
          ),
          trailing: const DeckIcon(Icons.chevron_right),
          onTap: () => showShelfGameSheet(context, game),
        ),
      ),
    );
  }
}
