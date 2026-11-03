import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

class ShelfGameForm extends StatefulWidget {
  const ShelfGameForm({super.key, required this.id});

  final String id;

  @override
  State<ShelfGameForm> createState() => _ShelfGameFormState();
}

class _ShelfGameFormState extends State<ShelfGameForm> {
  late ShelfGame game;
  late final TextEditingController name;

  @override
  void initState() {
    super.initState();
    final shelf = context.read<LibraryCubit>().state.games;
    game =
        shelf.where((g) => g.id == widget.id).firstOrNull ??
        ShelfGame(
          id: newId(),
          name: '',
          addedAt: DateTime.now().millisecondsSinceEpoch,
        );
    name = TextEditingController(text: game.name);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _toggle(List<String> list, String value, bool on, bool isGenre) {
    final next = on ? [...list, value] : list.where((v) => v != value).toList();
    setState(
      () => game = isGenre
          ? game.copyWith(genres: next)
          : game.copyWith(templateIds: next),
    );
  }

  Future<void> _save() async {
    final value = name.text.trim();
    if (value.isEmpty) {
      notify(context, tr(context, 'Donnez un nom au jeu.', 'Name the game.'));
      return;
    }
    await context.read<LibraryCubit>().save(game.copyWith(name: value));
    if (mounted) context.go('/library');
  }

  @override
  Widget build(BuildContext context) {
    final templates = [
      ...GameTemplate.builtIn,
      ...context.watch<LibraryCubit>().templates,
    ];
    return FullPage(
      title: tr(context, 'Jeu de la ludothèque', 'Shelf game'),
      fallback: '/library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: name,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: tr(context, 'Nom du jeu', 'Game name'),
            ),
          ),
          _ShelfNumbers(game: game, onChanged: (g) => setState(() => game = g)),
          SectionHeading(tr(context, 'Genres', 'Genres')),
          _ChoiceChips(
            values: gameGenres,
            label: (g) =>
                tr(context, gameGenreLabels[g]!.$1, gameGenreLabels[g]!.$2),
            selected: game.genres,
            onToggle: (v, on) => _toggle(game.genres, v, on, true),
          ),
          SectionHeading(tr(context, 'Couleur de la boîte', 'Box colour')),
          _ColorPicker(
            value: game.color,
            onChanged: (c) => setState(() => game = game.copyWith(color: c)),
          ),
          SectionHeading(tr(context, 'Packs liés', 'Linked packs')),
          _ChoiceChips(
            values: templates.map((t) => t.id).toList(),
            label: (id) => templates.firstWhere((t) => t.id == id).name,
            selected: game.templateIds,
            onToggle: (v, on) => _toggle(game.templateIds, v, on, false),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: Text(tr(context, 'Ranger sur l’étagère', 'Put on shelf')),
          ),
        ],
      ),
    );
  }
}

class _ShelfNumbers extends StatelessWidget {
  const _ShelfNumbers({required this.game, required this.onChanged});

  final ShelfGame game;
  final ValueChanged<ShelfGame> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tr(context, 'Joueurs', 'Players')} : ${game.minPlayers} - ${game.maxPlayers}',
          style: theme.textTheme.titleMedium,
        ),
        RangeSlider(
          min: 1,
          max: 12,
          divisions: 11,
          values: RangeValues(
            game.minPlayers.clamp(1, 12).toDouble(),
            game.maxPlayers.clamp(1, 12).toDouble(),
          ),
          labels: RangeLabels('${game.minPlayers}', '${game.maxPlayers}'),
          onChanged: (v) => onChanged(
            game.copyWith(
              minPlayers: v.start.round(),
              maxPlayers: v.end.round(),
            ),
          ),
        ),
        Text(
          '${tr(context, 'Durée', 'Length')} : ${game.minutes} min',
          style: theme.textTheme.titleMedium,
        ),
        Slider(
          min: 5,
          max: 240,
          divisions: 47,
          value: game.minutes.clamp(5, 240).toDouble(),
          label: '${game.minutes} min',
          onChanged: (v) => onChanged(game.copyWith(minutes: v.round())),
        ),
      ],
    );
  }
}

class _ChoiceChips extends StatelessWidget {
  const _ChoiceChips({
    required this.values,
    required this.label,
    required this.selected,
    required this.onToggle,
  });

  final List<String> values, selected;
  final String Function(String) label;
  final void Function(String value, bool on) onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final v in values)
        FilterChip(
          label: Text(label(v)),
          selected: selected.contains(v),
          onSelected: (on) => onToggle(v, on),
        ),
    ],
  );
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      for (final (i, c) in shelfColors.indexed)
        Semantics(
          selected: c == value,
          child: Tooltip(
            message: '${tr(context, 'Couleur', 'Colour')} ${i + 1}',
            child: InkWell(
              onTap: () => onChanged(c),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Color(c),
                child: c == value
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ),
    ],
  );
}
