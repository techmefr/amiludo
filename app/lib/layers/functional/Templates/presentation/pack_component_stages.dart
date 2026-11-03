import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/presentation/creation_draft.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_drafts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

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
      SectionHeading(tr(context, '01 / Dés du jeu', '01 / Game dice')),
      Text(
        tr(
          context,
          'Définissez le libellé et la valeur de chaque face. Répétez une face pour augmenter sa fréquence. Chaque type peut avoir plusieurs exemplaires.',
          'Set the label and value of each face. Repeat a face to make it more frequent. Each type can have several copies.',
        ),
      ),
      const SizedBox(height: 16),
      _DraftList<DieDraft>(
        drafts: dice,
        max: 16,
        addLabel: tr(context, 'Ajouter un dé', 'Add a die'),
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
      BuilderField(die.name, tr(context, 'Nom du dé', 'Die name')),
      BuilderField(
        die.count,
        tr(context, 'Nombre d’exemplaires', 'Number of copies'),
      ),
      for (final f in die.faces)
        Padding(
          key: ObjectKey(f),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BuilderField(
                  f.label,
                  tr(context, 'Face / symbole', 'Face / symbol'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: BuilderField(f.value, tr(context, 'Valeur', 'Value')),
              ),
              IconButton(
                tooltip: tr(context, 'Retirer la face', 'Remove the face'),
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
        child: Text(tr(context, 'Ajouter une face', 'Add a face')),
      ),
      RemoveDraftButton(
        tr(context, 'Retirer ce dé', 'Remove this die'),
        onRemove,
      ),
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
      SectionHeading(tr(context, '02 / Rôles du jeu', '02 / Game roles')),
      Text(
        tr(
          context,
          'Choisissez le nombre de cartes de chaque rôle. La distribution demandera exactement autant de cartes que de joueurs.',
          'Pick how many cards each role has. Dealing needs exactly as many cards as players.',
        ),
      ),
      const SizedBox(height: 16),
      _DraftList<RoleDraft>(
        drafts: roles,
        max: 32,
        addLabel: tr(context, 'Ajouter un rôle', 'Add a role'),
        create: () => RoleDraft(null),
        refresh: refresh,
        item: (d) => Column(
          children: [
            BuilderField(d.name, tr(context, 'Nom du rôle', 'Role name')),
            BuilderField(
              d.count,
              tr(context, 'Nombre de cartes', 'Number of cards'),
            ),
            BuilderField(
              d.description,
              tr(
                context,
                'Pouvoir, objectif ou consigne privée',
                'Power, goal or private instruction',
              ),
              lines: 3,
              maxLength: 2000,
            ),
            RemoveDraftButton(
              tr(context, 'Retirer ce rôle', 'Remove this role'),
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
      SectionHeading(
        tr(
          context,
          '04 / Personnages et boosters',
          '04 / Characters and boosters',
        ),
      ),
      Text(
        tr(
          context,
          'Créez vos catégories : races, métiers, histoires, pouvoirs… En mode liste, toutes les cartes sont proposées. En mode booster, seules les cartes tirées sont révélées. Le minimum et le maximum de cartes gardées s’appliquent aux deux modes.',
          'Create your categories: races, jobs, backstories, powers… In list mode, every card is offered. In booster mode, only drawn cards are revealed. The minimum and maximum of kept cards apply to both modes.',
        ),
      ),
      const SizedBox(height: 16),
      _DraftList<CreationDraft>(
        drafts: creation,
        max: 16,
        addLabel: tr(
          context,
          'Ajouter une catégorie de personnage',
          'Add a character category',
        ),
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
      BuilderField(
        draft.name,
        tr(context, 'Catégorie de personnage', 'Character category'),
      ),
      BuilderField(
        draft.draw,
        tr(
          context,
          'Cartes proposées par booster',
          'Cards offered per booster',
        ),
      ),
      BuilderField(
        draft.keepMin,
        tr(context, 'Cartes à garder au minimum', 'Minimum cards to keep'),
      ),
      BuilderField(
        draft.keepMax,
        tr(context, 'Cartes à garder au maximum', 'Maximum cards to keep'),
      ),
      for (final c in draft.cards)
        Padding(
          key: ObjectKey(c),
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              BuilderField(c.name, tr(context, 'Nom de la carte', 'Card name')),
              BuilderField(
                c.description,
                tr(
                  context,
                  'Description, effet ou histoire',
                  'Description, effect or story',
                ),
                lines: 2,
                maxLength: 2000,
              ),
              RemoveDraftButton(
                tr(context, 'Retirer la carte', 'Remove the card'),
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
        child: Text(tr(context, 'Ajouter une carte', 'Add a card')),
      ),
      RemoveDraftButton(
        tr(
          context,
          'Retirer cette catégorie de personnage',
          'Remove this character category',
        ),
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
      SectionHeading(tr(context, 'Compteurs de joueur', 'Player counters')),
      Text(
        tr(
          context,
          'Vies, énergie, points de combat… Chaque joueur démarre avec ces valeurs et les ajuste en partie.',
          'Lives, energy, combat points… Each player starts with these values and adjusts them during the game.',
        ),
      ),
      const SizedBox(height: 16),
      _DraftList<ResourceDraft>(
        drafts: resources,
        max: 16,
        addLabel: tr(context, 'Ajouter un compteur', 'Add a counter'),
        create: ResourceDraft.new,
        refresh: refresh,
        item: (d) => Column(
          children: [
            BuilderField(
              d.name,
              tr(context, 'Nom du compteur', 'Counter name'),
              maxLength: 40,
            ),
            BuilderField(
              d.start,
              tr(context, 'Valeur de départ', 'Starting value'),
            ),
            RemoveDraftButton(
              tr(context, 'Retirer ce compteur', 'Remove this counter'),
              () => refresh(() {
                resources.remove(d);
                disposeLater(d.dispose);
              }),
            ),
          ],
        ),
      ),
      SectionHeading(tr(context, 'Statuts cumulables', 'Stackable statuses')),
      Text(
        tr(
          context,
          'Poison, bouclier, étourdi… Les joueurs empilent ou retirent des jetons de statut pendant la partie.',
          'Poison, shield, stunned… Players stack or remove status tokens during the game.',
        ),
      ),
      const SizedBox(height: 16),
      _DraftList<TextEditingController>(
        drafts: statuses,
        max: 16,
        addLabel: tr(context, 'Ajouter un statut', 'Add a status'),
        create: TextEditingController.new,
        refresh: refresh,
        item: (c) => Row(
          children: [
            Expanded(
              child: BuilderField(
                c,
                tr(context, 'Nom du statut', 'Status name'),
                maxLength: 40,
              ),
            ),
            IconButton(
              tooltip: tr(context, 'Retirer ce statut', 'Remove this status'),
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
