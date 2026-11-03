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
      const Text(
        'Choisissez uniquement les outils utiles à ce jeu. Les étapes suivantes s’adaptent à votre sélection.',
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
        title: const Text('Règles et variantes'),
        value: modes.contains('rules'),
        onChanged: (v) => onTool('rules', v == true),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Compteurs et statuts de joueur'),
        subtitle: const Text('Vies, énergie, poison, bouclier…'),
        value: trackers,
        onChanged: (v) => onTrackers(v == true),
      ),
    ],
  );
}

const _ruleKinds = [
  ('linear', 'Quantité × points'),
  ('sets', 'Lots complets'),
  ('triangular', 'Progression 1 + 2 + 3…'),
  ('threshold', 'Bonus à partir d’un seuil'),
  ('lookup', 'Barème personnalisé'),
];

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
      const SectionHeading('03 / Décompte des points'),
      const Text(
        'Chaque catégorie calcule un total à partir d’une quantité. La feuille de décompte remplace le total de la catégorie ; elle ne l’ajoute pas une deuxième fois.',
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
        label: const Text('Ajouter une catégorie'),
      ),
      const SizedBox(height: 20),
      BuilderField(target, 'Objectif de points (0 = libre)'),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Le score le plus bas gagne'),
        value: low,
        onChanged: onLow,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Objectif coopératif'),
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
      BuilderField(rule.name, 'Catégorie de points', maxLength: 40),
      DropdownButtonFormField<String>(
        style: Theme.of(context).textTheme.bodyLarge,
        initialValue: rule.kind,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Méthode de calcul'),
        items: [
          for (final (value, label) in _ruleKinds)
            DropdownMenuItem(value: value, child: Text(label)),
        ],
        onChanged: (v) => refresh(() => rule.kind = v!),
      ),
      const SizedBox(height: 16),
      if (rule.kind != 'lookup')
        BuilderField(
          rule.factor,
          rule.kind == 'threshold'
              ? 'Points si le seuil est atteint'
              : 'Points par unité ou lot',
        ),
      if (['sets', 'threshold'].contains(rule.kind))
        BuilderField(
          rule.step,
          rule.kind == 'sets' ? 'Taille d’un lot' : 'Seuil à atteindre',
        ),
      if (rule.kind == 'lookup')
        BuilderField(
          rule.table,
          'Barème pour 0, 1, 2, 3…',
          hint: 'Valeurs séparées par des virgules : 0, 1, 3, 6, 10',
        ),
      BuilderField(rule.bonus, 'Bonus ou malus fixe'),
      RemoveDraftButton('Retirer cette catégorie', onRemove),
    ],
  );
}

class RulesStage extends StatelessWidget {
  const RulesStage({super.key, required this.url, required this.notes});
  final TextEditingController url, notes;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SectionHeading('05 / Règles et références'),
      BuilderField(
        url,
        'Lien HTTPS vers les règles ou le site de l’éditeur',
        hint: 'Le lien s’ouvrira dans le navigateur. Le livret distant n’est pas téléchargé.',
      ),
      BuilderField(
        notes,
        'Vos consignes et variantes',
        lines: 6,
        maxLength: 12000,
        hint: 'Ces notes seront disponibles hors connexion dans le pack.',
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
      Text('Outils choisis : ${modes.join(' · ')}'),
      const SizedBox(height: 16),
      ExpansionTile(
        title: const Text('Publication et crédits'),
        children: [
          BuilderField(author, 'Auteur du pack', maxLength: 120),
          BuilderField(
            license,
            'Licence du pack',
            hint: 'MIT, CC0-1.0, CC-BY-4.0… Les contenus doivent vous appartenir ou être autorisés.',
          ),
          BuilderField(revision, 'Version du pack'),
        ],
      ),
    ],
  );
}
