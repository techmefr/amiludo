import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/game_review.dart';
import 'package:amiludo/layers/functional/Friends/presentation/cubit/friends_cubit.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final stars = <String, int>{};
  final comments = <String, TextEditingController>{};
  GameSession? game;

  @override
  void initState() {
    super.initState();
    final data = context.read<FriendsCubit>().state;
    game = data.games.where((g) => g.id == widget.sessionId).firstOrNull;
    for (final p in game?.players ?? const <Player>[]) {
      final previous = data.reviews
          .where((r) => r.sessionId == widget.sessionId && r.reviewer == p.name)
          .firstOrNull;
      if (previous != null) stars[p.name] = previous.stars;
      comments[p.name] = TextEditingController(text: previous?.comment ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in comments.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(GameSession game) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await context.read<FriendsCubit>().saveReviews(game.id, [
      for (final MapEntry(key: name, value: value) in stars.entries)
        GameReview(
          id: '${game.id}-${newId()}',
          sessionId: game.id,
          reviewer: name,
          stars: value,
          gameTitle: game.title,
          templateId: game.pack?.id ?? '',
          comment: comments[name]!.text.trim(),
          createdAt: now,
        ),
    ]);
    if (mounted) {
      notify(context, tr(context, 'Avis enregistrés', 'Reviews saved'));
      context.go('/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = this.game;
    return FullPage(
      title: tr(context, 'Noter la partie', 'Rate the game'),
      fallback: '/history',
      child: game == null
          ? EmptyPanel(
              title: tr(context, 'Partie introuvable', 'Game not found'),
              message: tr(
                context,
                'Elle a peut-être été supprimée.',
                'It may have been deleted.',
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                for (final p in game.players)
                  _PlayerReview(
                    name: p.name,
                    stars: stars[p.name] ?? 0,
                    comment: comments[p.name]!,
                    onStars: (v) => setState(() => stars[p.name] = v),
                  ),
                FilledButton(
                  onPressed: stars.isEmpty ? null : () => _save(game),
                  child: Text(
                    tr(context, 'Enregistrer les avis', 'Save reviews'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlayerReview extends StatelessWidget {
  const _PlayerReview({
    required this.name,
    required this.stars,
    required this.comment,
    required this.onStars,
  });

  final String name;
  final int stars;
  final TextEditingController comment;
  final ValueChanged<int> onStars;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: DeckPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: tr(context, '$i étoile(s) sur 5', '$i star(s) of 5'),
                  isSelected: i <= stars,
                  onPressed: () => onStars(i),
                  icon: Icon(
                    i <= stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i <= stars ? const Color(0xfff6c445) : null,
                  ),
                ),
            ],
          ),
          TextField(
            controller: comment,
            maxLength: 500,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: tr(
                context,
                'Un mot sur la partie',
                'A word on the game',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
