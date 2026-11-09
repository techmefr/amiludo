import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class ShelfNumbers extends StatelessWidget {
  const ShelfNumbers({super.key, required this.game, required this.onChanged});

  final ShelfGame game;
  final ValueChanged<ShelfGame> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.l10n.libraryPlayers} : ${game.minPlayers} - ${game.maxPlayers}',
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
          '${context.l10n.libraryLength} : ${game.minutes} min',
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

class ShelfChoiceChips extends StatelessWidget {
  const ShelfChoiceChips({
    super.key,
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

class ShelfColorPicker extends StatelessWidget {
  const ShelfColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

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
            message: '${context.l10n.libraryColour} ${i + 1}',
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

String shelfStatusLabel(BuildContext context, String status) =>
    switch (status) {
      'wishlist' => context.l10n.libraryStatusWishlist,
      'lent' => context.l10n.libraryStatusLent,
      _ => context.l10n.libraryStatusOwned,
    };
