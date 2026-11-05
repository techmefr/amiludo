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
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
    } on FriendError {
      if (mounted) {
        notify(context, context.l10n.friendsThisFriendAlreadyExists);
      }
    } on FormatException catch (error) {
      if (mounted) notify(context, error.message);
    }
  }

  Future<void> _remove() async {
    final cubit = context.read<FriendsCubit>();
    if (await confirm(
      context,
      context.l10n.friendsRemoveThisFriend,
      friend.name,
    )) {
      await cubit.remove(friend.id);
      if (mounted) context.go('/friends');
    }
  }

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.friendsFriendProfile,
    fallback: '/friends',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: name,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: context.l10n.friendsNameOrNickname,
          ),
        ),
        SectionHeading(context.l10n.friendsTastes),
        Text(context.l10n.friendsTapAGenreLikesThen),
        const SizedBox(height: 12),
        _TasteChips(friend: friend, onCycle: _cycle),
        SectionHeading(context.l10n.friendsLongestGame),
        Slider(
          max: 240,
          divisions: 16,
          value: friend.maxMinutes.clamp(0, 240).toDouble(),
          label: friend.maxMinutes == 0
              ? context.l10n.friendsNoLimit
              : '${friend.maxMinutes} min',
          onChanged: (v) =>
              setState(() => friend = friend.copyWith(maxMinutes: v.round())),
        ),
        SectionHeading(context.l10n.friendsPerGameOpinion),
        Text(context.l10n.friendsTapAGameWantsIt),
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
            FilledButton(onPressed: _save, child: Text(context.l10n.themeSave)),
            if (context.read<FriendsCubit>().state.friends.any(
              (f) => f.id == friend.id,
            ))
              OutlinedButton(
                onPressed: _remove,
                child: Text(context.l10n.eveningsRemove),
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
        ? context.l10n.friendsLikes
        : avoided
        ? context.l10n.friendsDislikes
        : context.l10n.friendsNeutral;
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
    GameOpinion.wished => context.l10n.friendsWants,
    GameOpinion.loved => context.l10n.friendsLoves,
    GameOpinion.refused => context.l10n.friendsRefused,
    GameOpinion.neutral => '',
  };

  @override
  Widget build(BuildContext context) {
    final shelf = context.read<FriendsCubit>().shelf;
    if (shelf.isEmpty) {
      return Text(context.l10n.friendsYourShelfIsEmpty);
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
