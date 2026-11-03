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
  bool boosters = true, opened = false, saved = false;
  CharacterDraft? draft;
  final selected = <int>{};
  final name = TextEditingController();
  String? error;
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
    error = null;
  });

  Future<void> save(CharacterDraft d) async {
    if (name.text.trim().isEmpty) {
      setState(() => error = 'Donnez un nom au personnage.');
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
        error = null;
      });
    }
  }

  Future<void> restart() async {
    if (await confirm(
      context,
      'Recommencer la création ?',
      'Les choix en cours seront abandonnés. Les fiches déjà enregistrées restent conservées.',
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
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('Liste'),
          icon: DeckIcon(Icons.list),
        ),
        ButtonSegment(
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
          '${c.name} · ${c.cards.length} cartes · ${c.draw} proposées par booster · garder ${c.keepMin} à ${c.keepMax}',
        ),
      ),
    const SizedBox(height: 16),
    FilledButton(onPressed: start, child: const Text('Générer mon personnage')),
  ];

  Widget booster(CreationCategory category) => DeckPanel(
    highlight: true,
    child: Column(
      children: [
        const DeckIcon(Icons.style_outlined, size: 72),
        const SizedBox(height: 16),
        Text('${category.draw} cartes à découvrir'),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => setState(() => opened = true),
          child: Text('Ouvrir le booster · ${category.name}'),
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
          title: const Text('Garder cette carte'),
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
            ? 'Créer la fiche'
            : 'Valider et continuer',
      ),
    ),
  ];

  List<Widget> step(CharacterDraft d, CreationCategory category) => [
    Text(
      'ÉTAPE ${d.index + 1} / ${d.categories.length} · ${category.name}',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 12),
    Text(
      'Gardez ${category.keepMin == category.keepMax ? "${category.keepMax}" : "${category.keepMin} à ${category.keepMax}"} carte(s). ${selected.length} sélectionnée(s).',
    ),
    const SizedBox(height: 20),
    if (!opened) booster(category),
    if (opened) ...offers(d, category),
  ];

  List<Widget> summary(CharacterDraft d) => [
    const SectionHeading('Votre personnage'),
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
      decoration: const InputDecoration(labelText: 'Nom du personnage'),
    ),
    if (error != null) Text(error!),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: saved ? null : () => save(d),
      child: Text(saved ? 'Personnage enregistré' : 'Enregistrer la fiche'),
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
        const Text(
          'Composez votre personnage avec les cartes du pack. Les limites de sélection sont définies par son créateur.',
        ),
        const SizedBox(height: 20),
        if (d == null) ...setup(),
        if (category != null) ...step(d!, category),
        if (d != null && d.complete) ...summary(d),
        if (d != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(onPressed: restart, child: const Text('Recommencer')),
        ],
        const CharacterLibrary(),
      ],
    );
  }
}
