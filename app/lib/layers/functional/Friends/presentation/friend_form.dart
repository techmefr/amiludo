import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Friends/domain/entities/friend.dart';
import 'package:amiludo/layers/functional/Friends/presentation/cubit/friends_cubit.dart';
import 'package:amiludo/layers/functional/Friends/presentation/friends_screen.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class FriendForm extends StatefulWidget {
  const FriendForm({super.key, required this.id});

  final String id;

  @override
  State<FriendForm> createState() => _FriendFormState();
}

class _FriendFormState extends State<FriendForm> {
  late Friend friend;
  late final TextEditingController name;

  @override
  void initState() {
    super.initState();
    final friends = context.read<FriendsCubit>().state.friends;
    friend =
        friends.where((f) => f.id == widget.id).firstOrNull ??
        Friend(id: newId(), name: '');
    name = TextEditingController(text: friend.name);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _cycle(String genre) {
    final liked = friend.likedGenres.contains(genre);
    final avoided = friend.avoidedGenres.contains(genre);
    final likes = friend.likedGenres.where((g) => g != genre).toList();
    final avoids = friend.avoidedGenres.where((g) => g != genre).toList();
    setState(
      () => friend = friend.copyWith(
        likedGenres: liked || avoided ? likes : [...likes, genre],
        avoidedGenres: liked ? [...avoids, genre] : avoids,
      ),
    );
  }

  Future<void> _save() async {
    try {
      await context.read<FriendsCubit>().save(
        friend.copyWith(name: name.text.trim()),
      );
      if (mounted) context.go('/friends');
    } on FormatException catch (error) {
      if (mounted) notify(context, error.message);
    }
  }

  Future<void> _remove() async {
    final cubit = context.read<FriendsCubit>();
    if (await confirm(
      context,
      tr(context, 'Retirer cet ami ?', 'Remove this friend?'),
      friend.name,
    )) {
      await cubit.remove(friend.id);
      if (mounted) context.go('/friends');
    }
  }

  @override
  Widget build(BuildContext context) => FullPage(
    title: tr(context, 'Profil d’ami', 'Friend profile'),
    fallback: '/friends',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: name,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: tr(context, 'Prénom ou pseudo', 'Name or nickname'),
          ),
        ),
        SectionHeading(tr(context, 'Goûts', 'Tastes')),
        Text(
          tr(
            context,
            'Touchez un genre : aime, puis n’aime pas, puis neutre.',
            'Tap a genre: likes, then dislikes, then neutral.',
          ),
        ),
        const SizedBox(height: 12),
        _TasteChips(friend: friend, onCycle: _cycle),
        SectionHeading(tr(context, 'Durée maximale', 'Longest game')),
        Slider(
          max: 240,
          divisions: 16,
          value: friend.maxMinutes.clamp(0, 240).toDouble(),
          label: friend.maxMinutes == 0
              ? tr(context, 'Sans limite', 'No limit')
              : '${friend.maxMinutes} min',
          onChanged: (v) =>
              setState(() => friend = friend.copyWith(maxMinutes: v.round())),
        ),
        SectionHeading(tr(context, 'Avis par jeu', 'Per-game opinion')),
        Text(
          tr(
            context,
            'Touchez un jeu : envie, adore même hors de ses genres, refusé, neutre.',
            'Tap a game: wants it, loves it despite the genre, refuses it, neutral.',
          ),
        ),
        const SizedBox(height: 12),
        _GameOpinions(
          friend: friend,
          onChanged: (updated) => setState(() => friend = updated),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: _save,
              child: Text(tr(context, 'Enregistrer', 'Save')),
            ),
            if (context.read<FriendsCubit>().state.friends.any(
              (f) => f.id == friend.id,
            ))
              OutlinedButton(
                onPressed: _remove,
                child: Text(tr(context, 'Retirer', 'Remove')),
              ),
          ],
        ),
      ],
    ),
  );
}

class _TasteChips extends StatelessWidget {
  const _TasteChips({required this.friend, required this.onCycle});

  final Friend friend;
  final ValueChanged<String> onCycle;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final g in gameGenres)
        _TasteChip(
          label: genreLabel(context, g),
          liked: friend.likedGenres.contains(g),
          avoided: friend.avoidedGenres.contains(g),
          onTap: () => onCycle(g),
        ),
    ],
  );
}

class _TasteChip extends StatelessWidget {
  const _TasteChip({
    required this.label,
    required this.liked,
    required this.avoided,
    required this.onTap,
  });

  final String label;
  final bool liked, avoided;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = liked
        ? tr(context, 'aime', 'likes')
        : avoided
        ? tr(context, 'n’aime pas', 'dislikes')
        : tr(context, 'neutre', 'neutral');
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label : $state',
      button: true,
      excludeSemantics: true,
      child: ActionChip(
        avatar: liked
            ? const DeckIcon(Icons.thumb_up_outlined, size: 16)
            : avoided
            ? const DeckIcon(Icons.thumb_down_outlined, size: 16)
            : null,
        backgroundColor: liked
            ? scheme.primaryContainer
            : avoided
            ? scheme.errorContainer
            : null,
        label: Text(
          label,
          style: avoided
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _GameOpinions extends StatelessWidget {
  const _GameOpinions({required this.friend, required this.onChanged});

  final Friend friend;
  final ValueChanged<Friend> onChanged;

  static const _next = {
    GameOpinion.neutral: GameOpinion.wished,
    GameOpinion.wished: GameOpinion.loved,
    GameOpinion.loved: GameOpinion.refused,
    GameOpinion.refused: GameOpinion.neutral,
  };

  static const _icons = {
    GameOpinion.wished: Icons.bookmark_add_outlined,
    GameOpinion.loved: Icons.favorite,
    GameOpinion.refused: Icons.block,
  };

  String _label(BuildContext context, GameOpinion opinion) => switch (opinion) {
    GameOpinion.wished => tr(context, 'envie', 'wants'),
    GameOpinion.loved => tr(context, 'adore', 'loves'),
    GameOpinion.refused => tr(context, 'refusé', 'refused'),
    GameOpinion.neutral => '',
  };

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<FriendsCubit>().state.shelf;
    if (shelf.isEmpty) {
      return Text(
        tr(context, 'Votre ludothèque est vide.', 'Your shelf is empty.'),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final game in shelf)
          Builder(
            builder: (context) {
              final opinion = friend.opinionOf(game.id);
              final icon = _icons[opinion];
              return ActionChip(
                avatar: icon == null ? null : Icon(icon, size: 18),
                label: Text(
                  opinion == GameOpinion.neutral
                      ? game.name
                      : '${game.name} · ${_label(context, opinion)}',
                ),
                onPressed: () =>
                    onChanged(friend.withOpinion(game.id, _next[opinion]!)),
              );
            },
          ),
      ],
    );
  }
}
