import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Library/domain/use_cases/suggest_games_use_case.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_sheet.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class TonightScreen extends StatefulWidget {
  const TonightScreen({super.key});

  @override
  State<TonightScreen> createState() => _TonightScreenState();
}

class _TonightScreenState extends State<TonightScreen> {
  final guests = <String>{};
  int minutes = 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LibraryCubit>();
    final friends = cubit.circle.friends;
    final suggestions = cubit.suggest(guests.toList(), minutes: minutes);
    return FullPage(
      title: context.l10n.libraryWhatToPlayTonight,
      fallback: '/library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.libraryWhoIsHere,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (friends.isEmpty)
            TextButton(
              onPressed: () => context.go('/friends'),
              child: Text(context.l10n.libraryAddFriends),
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
          SectionHeading(context.l10n.libraryTimeAvailable),
          Slider(
            max: 240,
            divisions: 16,
            value: minutes.toDouble(),
            label: minutes == 0
                ? context.l10n.libraryAllEvening
                : '$minutes min',
            semanticFormatterCallback: (v) =>
                v == 0 ? context.l10n.libraryAllEvening : '${v.round()} min',
            onChanged: (v) => setState(() => minutes = v.round()),
          ),
          SectionHeading(
            context.l10n.libraryGamesForPlayers(
              suggestions.length,
              guests.length + 1,
            ),
          ),
          if (suggestions.isEmpty)
            EmptyPanel(
              title: context.l10n.libraryNothingFits,
              message: context.l10n.libraryAddGamesOrRelaxYour,
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
            [
              '${game.minPlayers}-${game.maxPlayers} · ${game.minutes} min${stars == null ? '' : ' · ${stars.toStringAsFixed(1)} ★'}',
              if (suggestion.wishedBy.isNotEmpty)
                context.l10n.libraryWantedBy(suggestion.wishedBy.join(', ')),
              if (suggestion.lovedBy.isNotEmpty)
                context.l10n.libraryLovedBy(suggestion.lovedBy.join(', ')),
            ].join('\n'),
          ),
          trailing: const DeckIcon(Icons.chevron_right),
          onTap: () => showShelfGameSheet(context, game),
        ),
      ),
    );
  }
}
