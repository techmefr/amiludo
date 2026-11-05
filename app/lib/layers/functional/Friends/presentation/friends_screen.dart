import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/presentation/cubit/friends_cubit.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
          eyebrow: context.l10n.friendsAroundTheTable,
          title: context.l10n.friendsMyFriends,
          subtitle: context.l10n.friendsTheirTastesAndReviewsTo,
          action: FilledButton(
            onPressed: () => context.push('/friends/edit/new'),
            child: Text(context.l10n.friendsAddAFriend),
          ),
        ),
        if (data.friends.isEmpty)
          EmptyPanel(
            title: context.l10n.friendsNobodyYet,
            message: context.l10n.friendsAddYourGamePartnersAnd,
          )
        else
          ResponsiveGrid(
            minimumWidth: 280,
            children: [for (final f in data.friends) _FriendCard(friend: f)],
          ),
        if (recent.isNotEmpty) ...[
          SectionHeading(context.l10n.friendsLatestReviews),
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
                tooltip: context.l10n.templatesEdit,
                onPressed: () => context.push('/friends/edit/${friend.id}'),
                icon: const DeckIcon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (friend.likedGenres.isNotEmpty)
            Text(
              '${context.l10n.friendsLikes2} : ${friend.likedGenres.map((g) => genreLabel(context, g)).join(', ')}',
            ),
          if (friend.avoidedGenres.isNotEmpty)
            Text(
              '${context.l10n.friendsDislikes2} : ${friend.avoidedGenres.map((g) => genreLabel(context, g)).join(', ')}',
            ),
          if (friend.maxMinutes > 0)
            Text(
              '${context.l10n.friendsGamesUpTo} ${friend.maxMinutes} min max',
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
      label: context.l10n.friendsStarsOutOf5(review.stars),
      child: ExcludeSemantics(
        child: Text('★' * review.stars + '☆' * (5 - review.stars)),
      ),
    ),
  );
}
