import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/random_cubit.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_library.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_sheet_stack.dart';
import 'package:amiludo/layers/functional/Random/presentation/pack_opening.dart';

class CharacterTool extends StatefulWidget {
  const CharacterTool({super.key, required this.pack});
  final GameTemplate pack;
  @override
  State<CharacterTool> createState() => _CharacterToolState();
}

class _CharacterToolState extends State<CharacterTool> {
  bool boosters = true, opened = false, saved = false, missingName = false;
  late CharacterDraft? draft;
  final selected = <int>{};
  final name = TextEditingController();

  @override
  void initState() {
    super.initState();
    draft = context.read<RandomCubit>().draftFor(widget.pack.name);
    opened = draft != null && !draft!.boosters;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  RandomCubit get cubit => context.read<RandomCubit>();

  void start() {
    final fresh = CharacterDraft(
      widget.pack.creation,
      packName: widget.pack.name,
      boosters: boosters,
    );
    cubit.saveDraft(fresh);
    setState(() {
      draft = fresh;
      opened = !boosters;
      selected.clear();
      saved = false;
      missingName = false;
    });
  }

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
    await cubit.saveCharacter(c);
    await cubit.clearDraft();
    if (mounted) {
      setState(() {
        saved = true;
        missingName = false;
      });
    }
  }

  Future<void> restart() async {
    final confirmed = await confirm(
      context,
      tr(context, 'Recommencer la création ?', 'Restart creation?'),
      tr(
        context,
        'Les choix en cours seront abandonnés. Les fiches déjà enregistrées restent conservées.',
        'Current choices will be discarded. Saved sheets are kept.',
      ),
    );
    if (!confirmed || !mounted) return;
    await cubit.clearDraft();
    if (!mounted) return;
    setState(() {
      draft = null;
      selected.clear();
      opened = false;
      saved = false;
      name.clear();
    });
  }

  void confirmStep(CharacterDraft d) {
    d.choose(selected);
    cubit.saveDraft(d);
    setState(() {
      selected.clear();
      opened = !d.boosters;
    });
  }

  void toggle(int i) => setState(
    () => selected.contains(i) ? selected.remove(i) : selected.add(i),
  );

  List<Widget> setup() => [
    SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          label: Text(tr(context, 'Liste', 'List')),
          icon: const DeckIcon(Icons.list),
        ),
        ButtonSegment(
          value: true,
          label: Text(tr(context, 'Packs', 'Packs')),
          icon: const DeckIcon(Icons.style_outlined),
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
            '${c.name} · ${c.cards.length} cartes · ${c.draw} par pack · garder ${c.keepMin} à ${c.keepMax}',
            '${c.name} · ${c.cards.length} cards · ${c.draw} per pack · keep ${c.keepMin} to ${c.keepMax}',
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
    if (!opened)
      ClosedPack(
        category: category,
        onOpen: () => setState(() => opened = true),
      )
    else ...[
      PackReveal(
        key: ValueKey('${d.packName}-${d.index}'),
        type: category.name,
        cards: d.offers[d.index],
        selected: selected,
        keepMax: category.keepMax,
        onToggle: toggle,
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: selected.length < category.keepMin
            ? null
            : () => confirmStep(d),
        child: Text(
          d.index + 1 == d.categories.length
              ? tr(context, 'Créer la fiche', 'Create the sheet')
              : tr(context, 'Valider et continuer', 'Confirm and continue'),
        ),
      ),
    ],
  ];

  List<Widget> summary(CharacterDraft d) => [
    SectionHeading(tr(context, 'Votre personnage', 'Your character')),
    CharacterSheetStack(choices: d.choices),
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
            'Composez votre personnage en ouvrant un pack par type de carte. Les limites de sélection sont définies par son créateur.',
            'Build your character by opening one pack per card type. Selection limits are set by its creator.',
          ),
        ),
        const SizedBox(height: 20),
        if (d == null) ...setup(),
        if (d != null && category != null) ...step(d, category),
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
