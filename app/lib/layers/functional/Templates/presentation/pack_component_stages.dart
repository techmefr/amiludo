import 'package:flutter/material.dart';

import 'package:amiludo/dice_studio.dart';
import 'package:amiludo/layers/functional/Templates/presentation/creation_draft.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_drafts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class _DraftList<T> extends StatelessWidget {
  const _DraftList({
    required this.drafts,
    required this.max,
    required this.addLabel,
    required this.create,
    required this.item,
    required this.refresh,
  });
  final List<T> drafts;
  final int max;
  final String addLabel;
  final T Function() create;
  final Widget Function(T draft) item;
  final Refresh refresh;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final d in drafts)
        Padding(
          key: ObjectKey(d),
          padding: const EdgeInsets.only(bottom: 16),
          child: DeckPanel(child: item(d)),
        ),
      OutlinedButton.icon(
        onPressed: drafts.length >= max
            ? null
            : () => refresh(() => drafts.add(create())),
        icon: const DeckIcon(Icons.add),
        label: Text(addLabel),
      ),
    ],
  );
}

class DiceStage extends StatelessWidget {
  const DiceStage({super.key, required this.dice, required this.refresh});
  final List<DieDraft> dice;
  final Refresh refresh;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.templates01GameDice),
      Text(context.l10n.templatesSetTheLabelAndValue),
      const SizedBox(height: 16),
      _DraftList<DieDraft>(
        drafts: dice,
        max: 16,
        addLabel: context.l10n.templatesAddADie,
        create: () => DieDraft(null),
        refresh: refresh,
        item: (d) => _DieEditor(
          die: d,
          refresh: refresh,
          onRemove: () => refresh(() {
            dice.remove(d);
            disposeLater(d.dispose);
          }),
        ),
      ),
    ],
  );
}

class _DieEditor extends StatelessWidget {
  const _DieEditor({
    required this.die,
    required this.refresh,
    required this.onRemove,
  });
  final DieDraft die;
  final Refresh refresh;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      BuilderField(die.name, context.l10n.templatesDieName),
      BuilderField(die.count, context.l10n.templatesNumberOfCopies),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          onPressed: () async {
            final picked = await pickDesignFromLibrary(context);
            if (picked != null && context.mounted) refresh(() => die.useDesign(picked));
          },
          child: Text(context.l10n.diceUseFromLibrary),
        ),
      ),
      for (final f in die.faces)
        Padding(
          key: ObjectKey(f),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BuilderField(f.label, context.l10n.templatesFaceSymbol),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: BuilderField(f.value, context.l10n.templatesValue),
              ),
              IconButton(
                tooltip: context.l10n.templatesRemoveTheFace,
                onPressed: () => refresh(() {
                  die.faces.remove(f);
                  disposeLater(f.dispose);
                }),
                icon: const DeckIcon(Icons.remove_circle_outline),
              ),
            ],
          ),
        ),
      OutlinedButton(
        onPressed: die.faces.length >= 100
            ? null
            : () => refresh(() => die.faces.add(FaceDraft(null))),
        child: Text(context.l10n.templatesAddAFace),
      ),
      RemoveDraftButton(context.l10n.templatesRemoveThisDie, onRemove),
    ],
  );
}

class RolesStage extends StatelessWidget {
  const RolesStage({super.key, required this.roles, required this.refresh});
  final List<RoleDraft> roles;
  final Refresh refresh;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.templates02GameRoles),
      Text(context.l10n.templatesPickHowManyCardsEach),
      const SizedBox(height: 16),
      _DraftList<RoleDraft>(
        drafts: roles,
        max: 32,
        addLabel: context.l10n.templatesAddARole,
        create: () => RoleDraft(null),
        refresh: refresh,
        item: (d) => Column(
          children: [
            BuilderField(d.name, context.l10n.templatesRoleName),
            BuilderField(d.count, context.l10n.templatesNumberOfCards),
            BuilderField(
              d.description,
              context.l10n.templatesPowerGoalOrPrivateInstruction,
              lines: 3,
              maxLength: 2000,
            ),
            RemoveDraftButton(
              context.l10n.templatesRemoveThisRole,
              () => refresh(() {
                roles.remove(d);
                disposeLater(d.dispose);
              }),
            ),
          ],
        ),
      ),
    ],
  );
}

class CharactersStage extends StatelessWidget {
  const CharactersStage({
    super.key,
    required this.creation,
    required this.refresh,
  });
  final List<CreationDraft> creation;
  final Refresh refresh;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.templates04CharactersAndBoosters),
      Text(context.l10n.templatesCreateYourCategoriesRacesJobs),
      const SizedBox(height: 16),
      _DraftList<CreationDraft>(
        drafts: creation,
        max: 16,
        addLabel: context.l10n.templatesAddACharacterCategory,
        create: () => CreationDraft(null),
        refresh: refresh,
        item: (d) => _CreationEditor(
          draft: d,
          refresh: refresh,
          onRemove: () => refresh(() {
            creation.remove(d);
            disposeLater(d.dispose);
          }),
        ),
      ),
    ],
  );
}

class _CreationEditor extends StatelessWidget {
  const _CreationEditor({
    required this.draft,
    required this.refresh,
    required this.onRemove,
  });
  final CreationDraft draft;
  final Refresh refresh;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      BuilderField(draft.name, context.l10n.templatesCharacterCategory),
      BuilderField(draft.draw, context.l10n.templatesCardsOfferedPerBooster),
      BuilderField(draft.keepMin, context.l10n.templatesMinimumCardsToKeep),
      BuilderField(draft.keepMax, context.l10n.templatesMaximumCardsToKeep),
      for (final c in draft.cards)
        Padding(
          key: ObjectKey(c),
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              BuilderField(c.name, context.l10n.templatesCardName),
              BuilderField(
                c.description,
                context.l10n.templatesDescriptionEffectOrStory,
                lines: 2,
                maxLength: 2000,
              ),
              RemoveDraftButton(
                context.l10n.templatesRemoveTheCard,
                () => refresh(() {
                  draft.cards.remove(c);
                  disposeLater(c.dispose);
                }),
              ),
            ],
          ),
        ),
      OutlinedButton(
        onPressed: draft.cards.length >= 100
            ? null
            : () => refresh(() => draft.cards.add(CardDraft(null))),
        child: Text(context.l10n.templatesAddACard),
      ),
      RemoveDraftButton(
        context.l10n.templatesRemoveThisCharacterCategory,
        onRemove,
      ),
    ],
  );
}

class TrackersStage extends StatelessWidget {
  const TrackersStage({
    super.key,
    required this.resources,
    required this.statuses,
    required this.refresh,
  });
  final List<ResourceDraft> resources;
  final List<TextEditingController> statuses;
  final Refresh refresh;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(context.l10n.templatesPlayerCounters),
      Text(context.l10n.templatesLivesEnergyCombatPointsEach),
      const SizedBox(height: 16),
      _DraftList<ResourceDraft>(
        drafts: resources,
        max: 16,
        addLabel: context.l10n.templatesAddACounter,
        create: ResourceDraft.new,
        refresh: refresh,
        item: (d) => Column(
          children: [
            BuilderField(
              d.name,
              context.l10n.templatesCounterName,
              maxLength: 40,
            ),
            BuilderField(d.start, context.l10n.templatesStartingValue),
            RemoveDraftButton(
              context.l10n.templatesRemoveThisCounter,
              () => refresh(() {
                resources.remove(d);
                disposeLater(d.dispose);
              }),
            ),
          ],
        ),
      ),
      SectionHeading(context.l10n.templatesStackableStatuses),
      Text(context.l10n.templatesPoisonShieldStunnedPlayersStack),
      const SizedBox(height: 16),
      _DraftList<TextEditingController>(
        drafts: statuses,
        max: 16,
        addLabel: context.l10n.templatesAddAStatus,
        create: TextEditingController.new,
        refresh: refresh,
        item: (c) => Row(
          children: [
            Expanded(
              child: BuilderField(
                c,
                context.l10n.templatesStatusName,
                maxLength: 40,
              ),
            ),
            IconButton(
              tooltip: context.l10n.templatesRemoveThisStatus,
              onPressed: () => refresh(() {
                statuses.remove(c);
                disposeLater(c.dispose);
              }),
              icon: const DeckIcon(Icons.remove_circle_outline),
            ),
          ],
        ),
      ),
    ],
  );
}
