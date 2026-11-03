import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_library.dart';

class CharacterTool extends StatefulWidget {
  const CharacterTool({super.key, required this.pack});
  final GameTemplate pack;
  @override
  State<CharacterTool> createState() => _CharacterToolState();
}

class _CharacterToolState extends State<CharacterTool> {
  bool boosters = true, opened = false, saved = false, missingName = false;
  CharacterDraft? draft;
  final selected = <int>{};
  final name = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void start() => setState(() {
    draft = CharacterDraft(widget.pack.creation, boosters: boosters);
    opened = !boosters;
    selected.clear();
    saved = false;
    missingName = false;
  });

  Future<void> save(CharacterDraft d) async {
    if (name.text.trim().isEmpty) {
      setState(() => missingName = true);
      return;
    }
    final c = GameCharacter(
      id: newId(),
      name: name.text.trim(),
      packName: widget.pack.name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      choices: Map.from(d.choices),
    );
    await context.read<RandomCubit>().saveCharacter(c);
    if (mounted) {
      setState(() {
        saved = true;
        missingName = false;
      });
    }
  }

  Future<void> restart() async {
    if (await confirm(
      context,
      tr(context, 'Recommencer la création ?', 'Restart creation?'),
      tr(
        context,
        'Les choix en cours seront abandonnés. Les fiches déjà enregistrées restent conservées.',
        'Current choices will be discarded. Saved sheets are kept.',
      ),
    )) {
      if (!mounted) return;
      setState(() {
        draft = null;
        selected.clear();
        opened = false;
        saved = false;
        name.clear();
      });
    }
  }

  List<Widget> setup() => [
    SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          label: Text(tr(context, 'Liste', 'List')),
          icon: const DeckIcon(Icons.list),
        ),
        const ButtonSegment(
          value: true,
          label: Text('Boosters'),
          icon: DeckIcon(Icons.style_outlined),
        ),
      ],
      selected: {boosters},
      onSelectionChanged: (v) => setState(() => boosters = v.first),
    ),
    const SizedBox(height: 20),
    for (final c in widget.pack.creation)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          tr(
            context,
            '${c.name} · ${c.cards.length} cartes · ${c.draw} proposées par booster · garder ${c.keepMin} à ${c.keepMax}',
            '${c.name} · ${c.cards.length} cards · ${c.draw} offered per booster · keep ${c.keepMin} to ${c.keepMax}',
          ),
        ),
      ),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: start,
      child: Text(
        tr(context, 'Générer mon personnage', 'Generate my character'),
      ),
    ),
  ];

  Widget booster(CreationCategory category) => DeckPanel(
    highlight: true,
    child: Column(
      children: [
        const DeckIcon(Icons.style_outlined, size: 72),
        const SizedBox(height: 16),
        Text(
          tr(
            context,
            '${category.draw} cartes à découvrir',
            '${category.draw} cards to reveal',
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => setState(() => opened = true),
          child: Text(
            tr(
              context,
              'Ouvrir le booster · ${category.name}',
              'Open the booster · ${category.name}',
            ),
          ),
        ),
      ],
    ),
  );

  Widget offer(CharacterDraft d, CreationCategory category, int i) => DeckPanel(
    highlight: selected.contains(i),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          d.offers[d.index][i].name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(d.offers[d.index][i].description),
        const SizedBox(height: 20),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(context, 'Garder cette carte', 'Keep this card')),
          value: selected.contains(i),
          onChanged:
              !selected.contains(i) && selected.length >= category.keepMax
              ? null
              : (v) => setState(
                  () => v == true ? selected.add(i) : selected.remove(i),
                ),
        ),
      ],
    ),
  );

  List<Widget> offers(CharacterDraft d, CreationCategory category) => [
    ResponsiveGrid(
      minimumWidth: 220,
      children: [
        for (var i = 0; i < d.offers[d.index].length; i++)
          offer(d, category, i),
      ],
    ),
    const SizedBox(height: 20),
    FilledButton(
      onPressed: selected.length < category.keepMin
          ? null
          : () => setState(() {
              d.choose(selected);
              selected.clear();
              opened = !boosters;
            }),
      child: Text(
        d.index + 1 == d.categories.length
            ? tr(context, 'Créer la fiche', 'Create the sheet')
            : tr(context, 'Valider et continuer', 'Confirm and continue'),
      ),
    ),
  ];

  List<Widget> step(CharacterDraft d, CreationCategory category) => [
    Text(
      '${tr(context, 'ÉTAPE', 'STEP')} ${d.index + 1} / ${d.categories.length} · ${category.name}',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 12),
    Text(
      tr(
        context,
        'Gardez ${category.keepMin == category.keepMax ? "${category.keepMax}" : "${category.keepMin} à ${category.keepMax}"} carte(s). ${selected.length} sélectionnée(s).',
        'Keep ${category.keepMin == category.keepMax ? "${category.keepMax}" : "${category.keepMin} to ${category.keepMax}"} card(s). ${selected.length} selected.',
      ),
    ),
    const SizedBox(height: 20),
    if (!opened) booster(category),
    if (opened) ...offers(d, category),
  ];

  List<Widget> summary(CharacterDraft d) => [
    SectionHeading(tr(context, 'Votre personnage', 'Your character')),
    for (final e in d.choices.entries) ...[
      Text(e.key, style: Theme.of(context).textTheme.titleMedium),
      for (final card in e.value)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('${card.name}\n${card.description}'),
        ),
    ],
    const SizedBox(height: 20),
    TextField(
      controller: name,
      maxLength: 80,
      decoration: InputDecoration(
        labelText: tr(context, 'Nom du personnage', 'Character name'),
      ),
    ),
    if (missingName)
      Text(
        tr(
          context,
          'Donnez un nom au personnage.',
          'Give the character a name.',
        ),
      ),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: saved ? null : () => save(d),
      child: Text(
        saved
            ? tr(context, 'Personnage enregistré', 'Character saved')
            : tr(context, 'Enregistrer la fiche', 'Save the sheet'),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final d = draft;
    final category = d != null && !d.complete ? d.categories[d.index] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.pack.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          tr(
            context,
            'Composez votre personnage avec les cartes du pack. Les limites de sélection sont définies par son créateur.',
            'Build your character with the pack cards. Selection limits are set by its creator.',
          ),
        ),
        const SizedBox(height: 20),
        if (d == null) ...setup(),
        if (category != null) ...step(d!, category),
        if (d != null && d.complete) ...summary(d),
        if (d != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: restart,
            child: Text(tr(context, 'Recommencer', 'Restart')),
          ),
        ],
        const CharacterLibrary(),
      ],
    );
  }
}
