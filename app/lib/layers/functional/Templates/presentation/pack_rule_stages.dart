import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_drafts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class ModesStage extends StatelessWidget {
  const ModesStage({
    super.key,
    required this.modes,
    required this.trackers,
    required this.onTool,
    required this.onTrackers,
  });
  final Set<String> modes;
  final bool trackers;
  final void Function(String id, bool on) onTool;
  final ValueChanged<bool> onTrackers;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        tr(
          context,
          'Choisissez uniquement les outils utiles à ce jeu. Les étapes suivantes s’adaptent à votre sélection.',
          'Pick only the tools this game needs. The next steps adapt to your choice.',
        ),
      ),
      const SizedBox(height: 16),
      for (final t in toolDefinitions)
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.title),
          subtitle: Text(t.subtitle),
          value: modes.contains(t.id),
          onChanged: (v) => onTool(t.id, v == true),
        ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(tr(context, 'Règles et variantes', 'Rules and variants')),
        value: modes.contains('rules'),
        onChanged: (v) => onTool('rules', v == true),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          tr(
            context,
            'Compteurs et statuts de joueur',
            'Player counters and statuses',
          ),
        ),
        subtitle: Text(
          tr(
            context,
            'Vies, énergie, poison, bouclier…',
            'Lives, energy, poison, shield…',
          ),
        ),
        value: trackers,
        onChanged: (v) => onTrackers(v == true),
      ),
    ],
  );
}

const _ruleKinds = ['linear', 'sets', 'triangular', 'threshold', 'lookup'];

String _ruleKindLabel(BuildContext context, String kind) => switch (kind) {
  'linear' => tr(context, 'Quantité × points', 'Quantity × points'),
  'sets' => tr(context, 'Lots complets', 'Complete sets'),
  'triangular' => tr(
    context,
    'Progression 1 + 2 + 3…',
    'Progression 1 + 2 + 3…',
  ),
  'threshold' => tr(
    context,
    'Bonus à partir d’un seuil',
    'Bonus from a threshold',
  ),
  _ => tr(context, 'Barème personnalisé', 'Custom table'),
};

class PointsStage extends StatelessWidget {
  const PointsStage({
    super.key,
    required this.rules,
    required this.target,
    required this.low,
    required this.coop,
    required this.onLow,
    required this.onCoop,
    required this.refresh,
  });
  final List<RuleDraft> rules;
  final TextEditingController target;
  final bool low, coop;
  final ValueChanged<bool> onLow, onCoop;
  final Refresh refresh;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(tr(context, '03 / Décompte des points', '03 / Scoring')),
      Text(
        tr(
          context,
          'Chaque catégorie calcule un total à partir d’une quantité. La feuille de décompte remplace le total de la catégorie ; elle ne l’ajoute pas une deuxième fois.',
          'Each category computes a total from a quantity. The score sheet replaces the category total; it does not add it twice.',
        ),
      ),
      const SizedBox(height: 16),
      for (final d in rules)
        Padding(
          key: ObjectKey(d),
          padding: const EdgeInsets.only(bottom: 16),
          child: DeckPanel(
            child: _RuleEditor(
              rule: d,
              refresh: refresh,
              onRemove: () => refresh(() {
                rules.remove(d);
                disposeLater(d.dispose);
              }),
            ),
          ),
        ),
      OutlinedButton.icon(
        onPressed: rules.length >= 32
            ? null
            : () => refresh(() => rules.add(RuleDraft(null))),
        icon: const DeckIcon(Icons.add),
        label: Text(tr(context, 'Ajouter une catégorie', 'Add a category')),
      ),
      const SizedBox(height: 20),
      BuilderField(
        target,
        tr(context, 'Objectif de points (0 = libre)', 'Points goal (0 = none)'),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          tr(context, 'Le score le plus bas gagne', 'Lowest score wins'),
        ),
        value: low,
        onChanged: onLow,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(tr(context, 'Objectif coopératif', 'Cooperative goal')),
        value: coop,
        onChanged: onCoop,
      ),
    ],
  );
}

class _RuleEditor extends StatelessWidget {
  const _RuleEditor({
    required this.rule,
    required this.refresh,
    required this.onRemove,
  });
  final RuleDraft rule;
  final Refresh refresh;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      BuilderField(
        rule.name,
        tr(context, 'Catégorie de points', 'Points category'),
        maxLength: 40,
      ),
      DropdownButtonFormField<String>(
        style: Theme.of(context).textTheme.bodyLarge,
        initialValue: rule.kind,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: tr(context, 'Méthode de calcul', 'Calculation method'),
        ),
        items: [
          for (final value in _ruleKinds)
            DropdownMenuItem(
              value: value,
              child: Text(_ruleKindLabel(context, value)),
            ),
        ],
        onChanged: (v) => refresh(() => rule.kind = v!),
      ),
      const SizedBox(height: 16),
      if (rule.kind != 'lookup')
        BuilderField(
          rule.factor,
          rule.kind == 'threshold'
              ? tr(
                  context,
                  'Points si le seuil est atteint',
                  'Points when the threshold is reached',
                )
              : tr(
                  context,
                  'Points par unité ou lot',
                  'Points per unit or set',
                ),
        ),
      if (['sets', 'threshold'].contains(rule.kind))
        BuilderField(
          rule.step,
          rule.kind == 'sets'
              ? tr(context, 'Taille d’un lot', 'Set size')
              : tr(context, 'Seuil à atteindre', 'Threshold to reach'),
        ),
      if (rule.kind == 'lookup')
        BuilderField(
          rule.table,
          tr(context, 'Barème pour 0, 1, 2, 3…', 'Table for 0, 1, 2, 3…'),
          hint: tr(
            context,
            'Valeurs séparées par des virgules : 0, 1, 3, 6, 10',
            'Comma-separated values: 0, 1, 3, 6, 10',
          ),
        ),
      BuilderField(
        rule.bonus,
        tr(context, 'Bonus ou malus fixe', 'Fixed bonus or penalty'),
      ),
      RemoveDraftButton(
        tr(context, 'Retirer cette catégorie', 'Remove this category'),
        onRemove,
      ),
    ],
  );
}

class RulesStage extends StatelessWidget {
  const RulesStage({super.key, required this.url, required this.notes});
  final TextEditingController url, notes;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SectionHeading(
        tr(context, '05 / Règles et références', '05 / Rules and references'),
      ),
      BuilderField(
        url,
        tr(
          context,
          'Lien HTTPS vers les règles ou le site de l’éditeur',
          'HTTPS link to the rules or the publisher site',
        ),
        hint: tr(
          context,
          'Le lien s’ouvrira dans le navigateur. Le livret distant n’est pas téléchargé.',
          'The link opens in the browser. The remote booklet is not downloaded.',
        ),
      ),
      BuilderField(
        notes,
        tr(context, 'Vos consignes et variantes', 'Your notes and variants'),
        lines: 6,
        maxLength: 12000,
        hint: tr(
          context,
          'Ces notes seront disponibles hors connexion dans le pack.',
          'These notes will be available offline in the pack.',
        ),
      ),
    ],
  );
}

class SummaryStage extends StatelessWidget {
  const SummaryStage({
    super.key,
    required this.title,
    required this.modes,
    required this.author,
    required this.license,
    required this.revision,
  });
  final String title;
  final Set<String> modes;
  final TextEditingController author, license, revision;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      Text(
        '${tr(context, 'Outils choisis', 'Chosen tools')} : ${modes.join(' · ')}',
      ),
      const SizedBox(height: 16),
      ExpansionTile(
        title: Text(
          tr(context, 'Publication et crédits', 'Publishing and credits'),
        ),
        children: [
          BuilderField(
            author,
            tr(context, 'Auteur du pack', 'Pack author'),
            maxLength: 120,
          ),
          BuilderField(
            license,
            tr(context, 'Licence du pack', 'Pack licence'),
            hint: tr(
              context,
              'MIT, CC0-1.0, CC-BY-4.0… Les contenus doivent vous appartenir ou être autorisés.',
              'MIT, CC0-1.0, CC-BY-4.0… The content must be yours or allowed.',
            ),
          ),
          BuilderField(
            revision,
            tr(context, 'Version du pack', 'Pack version'),
          ),
        ],
      ),
    ],
  );
}
