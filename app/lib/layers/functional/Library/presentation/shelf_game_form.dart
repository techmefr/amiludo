import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/cubit/library_cubit.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_fields.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class ShelfGameForm extends StatefulWidget {
  const ShelfGameForm({super.key, required this.id, this.draft});

  final String id;
  final ShelfGame? draft;

  @override
  State<ShelfGameForm> createState() => _ShelfGameFormState();
}

class _ShelfGameFormState extends State<ShelfGameForm> {
  late ShelfGame game;
  late final TextEditingController name, barcode;

  @override
  void initState() {
    super.initState();
    final shelf = context.read<LibraryCubit>().state.games;
    game =
        shelf.where((g) => g.id == widget.id).firstOrNull ??
        widget.draft ??
        ShelfGame(
          id: newId(),
          name: '',
          addedAt: DateTime.now().millisecondsSinceEpoch,
        );
    name = TextEditingController(text: game.name);
    barcode = TextEditingController(text: game.barcode);
  }

  @override
  void dispose() {
    name.dispose();
    barcode.dispose();
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
      notify(context, context.l10n.libraryNameTheGame);
      return;
    }
    await context.read<LibraryCubit>().save(
      game.copyWith(
        name: value,
        barcode: barcode.text.replaceAll(RegExp(r'\D'), ''),
      ),
    );
    if (mounted) context.go('/library');
  }

  @override
  Widget build(BuildContext context) {
    final templates = [
      ...GameTemplate.builtIn,
      ...context.watch<LibraryCubit>().templates,
    ];
    return FullPage(
      title: context.l10n.libraryShelfGame,
      fallback: '/library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: name,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: context.l10n.libraryGameName,
            ),
          ),
          TextField(
            controller: barcode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.libraryBarcode,
            ),
          ),
          SectionHeading(context.l10n.libraryStatus),
          ShelfChoiceChips(
            values: shelfStatuses,
            label: (v) => shelfStatusLabel(context, v),
            selected: [game.status],
            onToggle: (v, on) {
              if (on) setState(() => game = game.copyWith(status: v));
            },
          ),
          ShelfNumbers(game: game, onChanged: (g) => setState(() => game = g)),
          SectionHeading(context.l10n.libraryGenres),
          ShelfChoiceChips(
            values: gameGenres,
            label: (g) =>
                tr(context, gameGenreLabels[g]!.$1, gameGenreLabels[g]!.$2),
            selected: game.genres,
            onToggle: (v, on) => _toggle(game.genres, v, on, true),
          ),
          SectionHeading(context.l10n.libraryBoxColour),
          ShelfColorPicker(
            value: game.color,
            onChanged: (c) => setState(() => game = game.copyWith(color: c)),
          ),
          SectionHeading(context.l10n.libraryLinkedPacks),
          ShelfChoiceChips(
            values: templates.map((t) => t.id).toList(),
            label: (id) => templates.firstWhere((t) => t.id == id).name,
            selected: game.templateIds,
            onToggle: (v, on) => _toggle(game.templateIds, v, on, false),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: Text(context.l10n.libraryPutOnShelf),
          ),
        ],
      ),
    );
  }
}
