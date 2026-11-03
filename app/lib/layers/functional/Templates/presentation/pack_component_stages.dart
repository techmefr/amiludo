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
      const SectionHeading('01 / Dés du jeu'),
      const Text(
        'Définissez le libellé et la valeur de chaque face. Répétez une face pour augmenter sa fréquence. Chaque type peut avoir plusieurs exemplaires.',
      ),
      const SizedBox(height: 16),
      _DraftList<DieDraft>(
        drafts: dice,
        max: 16,
        addLabel: 'Ajouter un dé',
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
      BuilderField(die.name, 'Nom du dé'),
      BuilderField(die.count, 'Nombre d’exemplaires'),
      for (final f in die.faces)
        Padding(
          key: ObjectKey(f),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BuilderField(f.label, 'Face / symbole')),
              const SizedBox(width: 8),
              SizedBox(width: 90, child: BuilderField(f.value, 'Valeur')),
              IconButton(
                tooltip: 'Retirer la face',
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
        child: const Text('Ajouter une face'),
      ),
      RemoveDraftButton('Retirer ce dé', onRemove),
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
      const SectionHeading('02 / Rôles du jeu'),
      const Text(
        'Choisissez le nombre de cartes de chaque rôle. La distribution demandera exactement autant de cartes que de joueurs.',
      ),
      const SizedBox(height: 16),
      _DraftList<RoleDraft>(
        drafts: roles,
        max: 32,
        addLabel: 'Ajouter un rôle',
        create: () => RoleDraft(null),
        refresh: refresh,
        item: (d) => Column(
          children: [
            BuilderField(d.name, 'Nom du rôle'),
            BuilderField(d.count, 'Nombre de cartes'),
            BuilderField(
              d.description,
              'Pouvoir, objectif ou consigne privée',
              lines: 3,
              maxLength: 2000,
            ),
            RemoveDraftButton(
              'Retirer ce rôle',
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
      const SectionHeading('04 / Personnages et boosters'),
      const Text(
        'Créez vos catégories : races, métiers, histoires, pouvoirs… En mode liste, toutes les cartes sont proposées. En mode booster, seules les cartes tirées sont révélées. Le minimum et le maximum de cartes gardées s’appliquent aux deux modes.',
      ),
      const SizedBox(height: 16),
      _DraftList<CreationDraft>(
        drafts: creation,
        max: 16,
        addLabel: 'Ajouter une catégorie de personnage',
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
      BuilderField(draft.name, 'Catégorie de personnage'),
      BuilderField(draft.draw, 'Cartes proposées par booster'),
      BuilderField(draft.keepMin, 'Cartes à garder au minimum'),
      BuilderField(draft.keepMax, 'Cartes à garder au maximum'),
      for (final c in draft.cards)
        Padding(
          key: ObjectKey(c),
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              BuilderField(c.name, 'Nom de la carte'),
              BuilderField(
                c.description,
                'Description, effet ou histoire',
                lines: 2,
                maxLength: 2000,
              ),
              RemoveDraftButton(
                'Retirer la carte',
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
        child: const Text('Ajouter une carte'),
      ),
      RemoveDraftButton('Retirer cette catégorie de personnage', onRemove),
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
      const SectionHeading('Compteurs de joueur'),
      const Text(
        'Vies, énergie, points de combat… Chaque joueur démarre avec ces valeurs et les ajuste en partie.',
      ),
      const SizedBox(height: 16),
      _DraftList<ResourceDraft>(
        drafts: resources,
        max: 16,
        addLabel: 'Ajouter un compteur',
        create: ResourceDraft.new,
        refresh: refresh,
        item: (d) => Column(
          children: [
            BuilderField(d.name, 'Nom du compteur', maxLength: 40),
            BuilderField(d.start, 'Valeur de départ'),
            RemoveDraftButton(
              'Retirer ce compteur',
              () => refresh(() {
                resources.remove(d);
                disposeLater(d.dispose);
              }),
            ),
          ],
        ),
      ),
      const SectionHeading('Statuts cumulables'),
      const Text(
        'Poison, bouclier, étourdi… Les joueurs empilent ou retirent des jetons de statut pendant la partie.',
      ),
      const SizedBox(height: 16),
      _DraftList<TextEditingController>(
        drafts: statuses,
        max: 16,
        addLabel: 'Ajouter un statut',
        create: TextEditingController.new,
        refresh: refresh,
        item: (c) => Row(
          children: [
            Expanded(child: BuilderField(c, 'Nom du statut', maxLength: 40)),
            IconButton(
              tooltip: 'Retirer ce statut',
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
