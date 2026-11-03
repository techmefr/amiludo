import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/presentation/cubit/friends_cubit.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

String genreLabel(BuildContext context, String genre) => tr(
  context,
  gameGenreLabels[genre]?.$1 ?? genre,
  gameGenreLabels[genre]?.$2 ?? genre,
);

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<FriendsCubit>().state;
    final recent = [...data.reviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(context, 'Autour de la table', 'Around the table'),
          title: tr(context, 'Mes amis', 'My friends'),
          subtitle: tr(
            context,
            'Leurs goûts, leurs avis, pour choisir le bon jeu.',
            'Their tastes and reviews, to pick the right game.',
          ),
          action: FilledButton(
            onPressed: () => context.push('/friends/edit/new'),
            child: Text(tr(context, 'Ajouter un ami', 'Add a friend')),
          ),
        ),
        if (data.friends.isEmpty)
          EmptyPanel(
            title: tr(context, 'Personne pour l’instant', 'Nobody yet'),
            message: tr(
              context,
              'Ajoutez vos partenaires de jeu et ce qu’ils aiment.',
              'Add your game partners and what they like.',
            ),
          )
        else
          ResponsiveGrid(
            minimumWidth: 280,
            children: [for (final f in data.friends) _FriendCard(friend: f)],
          ),
        if (recent.isNotEmpty) ...[
          SectionHeading(tr(context, 'Derniers avis', 'Latest reviews')),
          for (final r in recent.take(12)) _ReviewTile(review: r),
        ],
      ],
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DeckPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(friend.color),
                child: Text(friend.name.characters.first.toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(friend.name, style: theme.textTheme.titleLarge),
              ),
              IconButton(
                tooltip: tr(context, 'Modifier', 'Edit'),
                onPressed: () => context.push('/friends/edit/${friend.id}'),
                icon: const DeckIcon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (friend.likedGenres.isNotEmpty)
            Text(
              '${tr(context, 'Aime', 'Likes')} : ${friend.likedGenres.map((g) => genreLabel(context, g)).join(', ')}',
            ),
          if (friend.avoidedGenres.isNotEmpty)
            Text(
              '${tr(context, 'N’aime pas', 'Dislikes')} : ${friend.avoidedGenres.map((g) => genreLabel(context, g)).join(', ')}',
            ),
          if (friend.maxMinutes > 0)
            Text(
              '${tr(context, 'Parties de', 'Games up to')} ${friend.maxMinutes} min max',
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final GameReview review;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text('${review.reviewer} · ${review.gameTitle}'),
    subtitle: review.comment.isEmpty ? null : Text(review.comment),
    trailing: Semantics(
      label: tr(
        context,
        '${review.stars} étoiles sur 5',
        '${review.stars} stars out of 5',
      ),
      child: ExcludeSemantics(
        child: Text('★' * review.stars + '☆' * (5 - review.stars)),
      ),
    ),
  );
}
