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
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
      context.l10n.randomRestartCreation,
      context.l10n.randomCurrentChoicesWillBeDiscarded,
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
          label: Text(context.l10n.randomList),
          icon: const DeckIcon(Icons.list),
        ),
        ButtonSegment(
          value: true,
          label: Text(context.l10n.randomPacks),
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
          context.l10n.randomCardsPerPackKeepTo(
            c.name,
            c.cards.length,
            c.draw,
            c.keepMin,
            c.keepMax,
          ),
        ),
      ),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: start,
      child: Text(context.l10n.randomGenerateMyCharacter),
    ),
  ];

  List<Widget> step(CharacterDraft d, CreationCategory category) => [
    Text(
      '${context.l10n.randomStep} ${d.index + 1} / ${d.categories.length} · ${category.name}',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 12),
    Text(
      context.l10n.randomKeepCards(
        category.keepMin == category.keepMax
            ? "${category.keepMax}"
            : context.l10n.randomKeepRangeBetween(
                category.keepMin,
                category.keepMax,
              ),
        selected.length,
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
              ? context.l10n.randomCreateTheSheet
              : context.l10n.randomConfirmAndContinue,
        ),
      ),
    ],
  ];

  List<Widget> summary(CharacterDraft d) => [
    SectionHeading(context.l10n.randomYourCharacter),
    CharacterSheetStack(choices: d.choices),
    const SizedBox(height: 20),
    TextField(
      controller: name,
      maxLength: 80,
      decoration: InputDecoration(labelText: context.l10n.randomCharacterName),
    ),
    if (missingName) Text(context.l10n.randomGiveTheCharacterAName),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: saved ? null : () => save(d),
      child: Text(
        saved
            ? context.l10n.randomCharacterSaved
            : context.l10n.randomSaveTheSheet,
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
        Text(context.l10n.randomBuildYourCharacterByOpening),
        const SizedBox(height: 20),
        if (d == null) ...setup(),
        if (d != null && category != null) ...step(d, category),
        if (d != null && d.complete) ...summary(d),
        if (d != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: restart,
            child: Text(context.l10n.randomRestart),
          ),
        ],
        const CharacterLibrary(),
      ],
    );
  }
}
