import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Templates/presentation/creation_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';

class PackBuilder extends StatefulWidget {
  const PackBuilder({super.key, this.template});
  final GameTemplate? template;
  @override
  State<PackBuilder> createState() => _PackBuilderState();
}

class _PackBuilderState extends State<PackBuilder> {
  late final TextEditingController name,
      englishName,
      description,
      author,
      license,
      revision,
      edition,
      language,
      url,
      notes,
      target,
      seconds;
  int stage = 0;
  final modes = <String>{};
  List<String> get stages => [
    'Jeu',
    'Modes',
    if (modes.contains('dice')) 'Dés',
    if (modes.contains('roles')) 'Rôles',
    if (modes.contains('scores')) 'Points',
    if (modes.contains('character')) 'Personnages',
    if (modes.contains('timer')) 'Temps',
    if (modes.contains('rules')) 'Règles',
    'Résumé',
  ];
  final creation = <CreationDraft>[];
  final dice = <DieDraft>[], roles = <RoleDraft>[], rules = <RuleDraft>[];
  bool low = false, coop = false, saved = false;
  String? error;
  late final String id;
  @override
  void initState() {
    super.initState();
    final t =
        widget.template ??
        GameTemplate(
          id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
          name: '',
        );
    id = t.id;
    name = TextEditingController(text: t.name);
    englishName = TextEditingController(
      text: t.englishName.isEmpty ? t.name : t.englishName,
    );
    modes.addAll(t.modules);
    description = TextEditingController(text: t.description);
    author = TextEditingController(text: t.author);
    license = TextEditingController(text: t.license);
    revision = TextEditingController(text: t.revision);
    edition = TextEditingController(text: t.edition);
    language = TextEditingController(text: t.language);
    url = TextEditingController(text: t.rulesUrl);
    notes = TextEditingController(text: t.rulesNotes);
    target = TextEditingController(text: '${t.target}');
    seconds = TextEditingController(text: '${t.seconds}');
    low = t.lowestWins;
    coop = t.cooperative;
    creation.addAll(t.creation.map(CreationDraft.new));
    dice.addAll(t.dice.map(DieDraft.new));
    roles.addAll(t.roles.map(RoleDraft.new));
    rules.addAll(
      t.scoring.isNotEmpty
          ? t.scoring.map(RuleDraft.new)
          : t.categories.map((n) => RuleDraft(ScoreRule(name: n))),
    );
  }

  @override
  void dispose() {
    for (final c in [
      name,
      englishName,
      description,
      author,
      license,
      revision,
      edition,
      language,
      url,
      notes,
      target,
      seconds,
    ]) {
      c.dispose();
    }
    for (final d in creation) {
      d.dispose();
    }
    for (final d in dice) {
      d.dispose();
    }
    for (final d in roles) {
      d.dispose();
    }
    for (final d in rules) {
      d.dispose();
    }
    super.dispose();
  }

  GameTemplate compile() {
    final scoring = modes.contains('scores')
        ? rules.map((d) => d.value()).toList()
        : <ScoreRule>[];
    return GameTemplate.fromJson(
      GameTemplate(
        id: id,
        name: name.text.trim(),
        englishName: englishName.text.trim(),
        modules: modes.toList(),
        description: description.text.trim(),
        author: author.text.trim(),
        license: license.text.trim(),
        revision: revision.text.trim(),
        edition: edition.text.trim(),
        language: language.text.trim(),
        rulesUrl: modes.contains('rules') ? url.text.trim() : '',
        rulesNotes: modes.contains('rules') ? notes.text.trim() : '',
        target: modes.contains('scores')
            ? double.parse(target.text.replaceAll(',', '.'))
            : 0,
        seconds: modes.contains('timer') ? int.parse(seconds.text) : 150,
        lowestWins: low,
        cooperative: coop,
        categories: scoring.isEmpty
            ? ['Points']
            : scoring.map((s) => s.name).toList(),
        scoring: scoring,
        creation: modes.contains('character')
            ? creation.map((d) => d.value()).toList()
            : [],
        dice: modes.contains('dice') ? dice.map((d) => d.value()).toList() : [],
        roles: modes.contains('roles')
            ? roles.map((d) => d.value()).toList()
            : [],
      ).toJson(),
    );
  }

  Future<void> save() async {
    try {
      final pack = compile();
      await context.read<TemplatesCubit>().addTemplate(pack);
      if (mounted) {
        setState(() => saved = true);
        notify(context, 'Pack enregistré sur cet appareil');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/templates');
            }
          }
        });
      }
    } on FormatException catch (e) {
      setState(() => error = e.message);
    } on TypeError {
      setState(() => error = 'Vérifiez les nombres et les champs du pack.');
    }
  }

  Widget field(
    TextEditingController c,
    String label, {
    int lines = 1,
    int? maxLength,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: c,
      maxLines: lines,
      minLines: lines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 3,
      ),
    ),
  );
  Widget remove(String label, VoidCallback action) => TextButton.icon(
    onPressed: () => setState(action),
    icon: const DeckIcon(Icons.delete_outline),
    label: Text(label),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: saved,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final leave = await confirm(
        context,
        'Quitter le builder ?',
        'Les modifications non enregistrées seront perdues.',
      );
      if (leave && mounted) {
        setState(() => saved = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/templates');
            }
          }
        });
      }
    },
    child: FullPage(
      title: widget.template == null
          ? 'Créer un pack de jeu'
          : 'Modifier le pack',
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DeckHeading(
            eyebrow: 'ATELIER / VOTRE JEU',
            title: 'Un jeu, vos outils',
            subtitle: 'Construisez les dés, les rôles et le décompte. Enregistrez, testez puis partagez votre pack.',
          ),
          Text(
            'Étape ${stage + 1} / ${stages.length} · ${stages[stage]}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: (stage + 1) / stages.length),
          const SizedBox(height: 24),
          if (stages[stage] == 'Jeu') ...[
            field(name, 'Nom du jeu ou du pack', maxLength: 80),
            field(englishName, 'Nom du jeu en anglais', maxLength: 80),
            field(description, 'Présentation', lines: 2, maxLength: 500),
            field(edition, 'Édition ou variante', maxLength: 120),
            field(language, 'Langue du pack (fr, en…)'),
          ],
          if (stages[stage] == 'Modes') ...[
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
                onChanged: (v) => setState(() {
                  if (v == true) {
                    modes.add(t.id);
                    if (t.id == 'dice' && dice.isEmpty) {
                      dice.add(DieDraft(null));
                    }
                  } else {
                    modes.remove(t.id);
                  }
                }),
              ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Règles et variantes'),
              value: modes.contains('rules'),
              onChanged: (v) => setState(
                () => v == true ? modes.add('rules') : modes.remove('rules'),
              ),
            ),
          ],
          if (stages[stage] == 'Dés') ...[
            const SectionHeading('01 / Dés du jeu'),
            const Text(
              'Définissez le libellé et la valeur de chaque face. Répétez une face pour augmenter sa fréquence. Chaque type peut avoir plusieurs exemplaires.',
            ),
            const SizedBox(height: 16),
            for (final d in dice)
              Padding(
                key: ObjectKey(d),
                padding: const EdgeInsets.only(bottom: 16),
                child: DeckPanel(
                  child: Column(
                    children: [
                      field(d.name, 'Nom du dé'),
                      field(d.count, 'Nombre d’exemplaires'),
                      for (final f in d.faces)
                        Padding(
                          key: ObjectKey(f),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: field(f.label, 'Face / symbole')),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: field(f.value, 'Valeur'),
                              ),
                              IconButton(
                                tooltip: 'Retirer la face',
                                onPressed: () => setState(() {
                                  d.faces.remove(f);
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => f.dispose(),
                                  );
                                }),
                                icon: const DeckIcon(
                                  Icons.remove_circle_outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      OutlinedButton(
                        onPressed: d.faces.length >= 100
                            ? null
                            : () =>
                                  setState(() => d.faces.add(FaceDraft(null))),
                        child: const Text('Ajouter une face'),
                      ),
                      remove('Retirer ce dé', () {
                        dice.remove(d);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => d.dispose(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: dice.length >= 16
                  ? null
                  : () => setState(() => dice.add(DieDraft(null))),
              icon: const DeckIcon(Icons.add),
              label: const Text('Ajouter un dé'),
            ),
          ],
          if (stages[stage] == 'Rôles') ...[
            const SectionHeading('02 / Rôles du jeu'),
            const Text(
              'Choisissez le nombre de cartes de chaque rôle. La distribution demandera exactement autant de cartes que de joueurs.',
            ),
            const SizedBox(height: 16),
            for (final d in roles)
              Padding(
                key: ObjectKey(d),
                padding: const EdgeInsets.only(bottom: 16),
                child: DeckPanel(
                  child: Column(
                    children: [
                      field(d.name, 'Nom du rôle'),
                      field(d.count, 'Nombre de cartes'),
                      field(
                        d.description,
                        'Pouvoir, objectif ou consigne privée',
                        lines: 3,
                        maxLength: 2000,
                      ),
                      remove('Retirer ce rôle', () {
                        roles.remove(d);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => d.dispose(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: roles.length >= 32
                  ? null
                  : () => setState(() => roles.add(RoleDraft(null))),
              icon: const DeckIcon(Icons.add),
              label: const Text('Ajouter un rôle'),
            ),
          ],
          if (stages[stage] == 'Points') ...[
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
                  child: Column(
                    children: [
                      field(d.name, 'Catégorie de points', maxLength: 40),
                      DropdownButtonFormField<String>(
                        initialValue: d.kind,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Méthode de calcul',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'linear',
                            child: Text('Quantité × points'),
                          ),
                          DropdownMenuItem(
                            value: 'sets',
                            child: Text('Lots complets'),
                          ),
                          DropdownMenuItem(
                            value: 'triangular',
                            child: Text('Progression 1 + 2 + 3…'),
                          ),
                          DropdownMenuItem(
                            value: 'threshold',
                            child: Text('Bonus à partir d’un seuil'),
                          ),
                          DropdownMenuItem(
                            value: 'lookup',
                            child: Text('Barème personnalisé'),
                          ),
                        ],
                        onChanged: (v) => setState(() => d.kind = v!),
                      ),
                      const SizedBox(height: 16),
                      if (d.kind != 'lookup')
                        field(
                          d.factor,
                          d.kind == 'threshold'
                              ? 'Points si le seuil est atteint'
                              : 'Points par unité ou lot',
                        ),
                      if (['sets', 'threshold'].contains(d.kind))
                        field(
                          d.step,
                          d.kind == 'sets'
                              ? 'Taille d’un lot'
                              : 'Seuil à atteindre',
                        ),
                      if (d.kind == 'lookup')
                        field(
                          d.table,
                          'Barème pour 0, 1, 2, 3…',
                          hint: 'Valeurs séparées par des virgules : 0, 1, 3, 6, 10',
                        ),
                      field(d.bonus, 'Bonus ou malus fixe'),
                      remove('Retirer cette catégorie', () {
                        rules.remove(d);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => d.dispose(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: rules.length >= 32
                  ? null
                  : () => setState(() => rules.add(RuleDraft(null))),
              icon: const DeckIcon(Icons.add),
              label: const Text('Ajouter une catégorie'),
            ),
            const SizedBox(height: 20),
            field(target, 'Objectif de points (0 = libre)'),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Le score le plus bas gagne'),
              value: low,
              onChanged: (v) => setState(() => low = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Objectif coopératif'),
              value: coop,
              onChanged: (v) => setState(() => coop = v),
            ),
          ],
          if (stages[stage] == 'Personnages') ...[
            const SectionHeading('04 / Personnages et boosters'),
            const Text(
              'Créez vos catégories : races, métiers, histoires, pouvoirs… En mode liste, toutes les cartes sont proposées. En mode booster, seules les cartes tirées sont révélées. Le minimum et le maximum de cartes gardées s’appliquent aux deux modes.',
            ),
            const SizedBox(height: 16),
            for (final d in creation)
              Padding(
                key: ObjectKey(d),
                padding: const EdgeInsets.only(bottom: 16),
                child: DeckPanel(
                  child: Column(
                    children: [
                      field(d.name, 'Catégorie de personnage'),
                      field(d.draw, 'Cartes proposées par booster'),
                      field(d.keepMin, 'Cartes à garder au minimum'),
                      field(d.keepMax, 'Cartes à garder au maximum'),
                      for (final c in d.cards)
                        Padding(
                          key: ObjectKey(c),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              field(c.name, 'Nom de la carte'),
                              field(
                                c.description,
                                'Description, effet ou histoire',
                                lines: 2,
                                maxLength: 2000,
                              ),
                              remove('Retirer la carte', () {
                                d.cards.remove(c);
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => c.dispose(),
                                );
                              }),
                            ],
                          ),
                        ),
                      OutlinedButton(
                        onPressed: d.cards.length >= 100
                            ? null
                            : () =>
                                  setState(() => d.cards.add(CardDraft(null))),
                        child: const Text('Ajouter une carte'),
                      ),
                      remove('Retirer cette catégorie de personnage', () {
                        creation.remove(d);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => d.dispose(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: creation.length >= 16
                  ? null
                  : () => setState(() => creation.add(CreationDraft(null))),
              icon: const DeckIcon(Icons.add),
              label: const Text('Ajouter une catégorie de personnage'),
            ),
          ],
          if (stages[stage] == 'Règles') ...[
            const SectionHeading('05 / Règles et références'),

            field(
              url,
              'Lien HTTPS vers les règles ou le site de l’éditeur',
              hint: 'Le lien s’ouvrira dans le navigateur. Le livret distant n’est pas téléchargé.',
            ),
            field(
              notes,
              'Vos consignes et variantes',
              lines: 6,
              maxLength: 12000,
              hint: 'Ces notes seront disponibles hors connexion dans le pack.',
            ),
          ],
          if (stages[stage] == 'Temps')
            field(seconds, 'Temps par tour en secondes'),
          if (stages[stage] == 'Résumé') ...[
            Text(
              '${name.text} / ${englishName.text}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Outils choisis : ${modes.join(' · ')}'),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Publication et crédits'),
              children: [
                field(author, 'Auteur du pack', maxLength: 120),
                field(
                  license,
                  'Licence du pack',
                  hint: 'MIT, CC0-1.0, CC-BY-4.0… Les contenus doivent vous appartenir ou être autorisés.',
                ),
                field(revision, 'Version du pack'),
              ],
            ),
          ],
          if (stages[stage] != 'Résumé')
            FilledButton(
              onPressed: () {
                if (stage == 0 &&
                    (name.text.trim().isEmpty ||
                        englishName.text.trim().isEmpty)) {
                  setState(
                    () =>
                        error = 'Renseignez le nom du jeu et son nom anglais.',
                  );
                  return;
                }
                if (stage == 1 && modes.isEmpty) {
                  setState(() => error = 'Choisissez au moins un outil.');
                  return;
                }
                setState(() {
                  stage++;
                  error = null;
                });
              },
              child: const Text('Continuer'),
            ),
          if (stage > 0)
            TextButton(
              onPressed: () => setState(() {
                stage--;
                error = null;
              }),
              child: const Text('Étape précédente'),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (stages[stage] == 'Résumé')
            FilledButton.icon(
              onPressed: save,
              icon: const DeckIcon(Icons.save_outlined),
              label: const Text('Enregistrer le pack'),
            ),
        ],
      ),
    ),
  );
}

class FaceDraft {
  FaceDraft(DieFace? f)
    : label = TextEditingController(text: f?.label ?? ''),
      value = TextEditingController(text: '${f?.value ?? 0}');
  final TextEditingController label, value;
  DieFace build() => DieFace.fromJson({
    'label': label.text.trim(),
    'value': double.parse(value.text.replaceAll(',', '.')),
  });
  void dispose() {
    label.dispose();
    value.dispose();
  }
}

class DieDraft {
  DieDraft(GameDie? d)
    : name = TextEditingController(text: d?.name ?? 'Dé classique'),
      count = TextEditingController(text: '${d?.count ?? 1}'),
      faces =
          (d?.faces ??
                  List.generate(
                    6,
                    (i) => DieFace('${i + 1}', (i + 1).toDouble()),
                  ))
              .map(FaceDraft.new)
              .toList();
  final TextEditingController name, count;
  final List<FaceDraft> faces;
  GameDie value() => GameDie.fromJson({
    'name': name.text.trim(),
    'count': int.parse(count.text),
    'faces': faces.map((f) => f.build().toJson()).toList(),
  });
  void dispose() {
    name.dispose();
    count.dispose();
    for (final f in faces) {
      f.dispose();
    }
  }
}

class RoleDraft {
  RoleDraft(GameRole? r)
    : name = TextEditingController(text: r?.name ?? ''),
      count = TextEditingController(text: '${r?.count ?? 1}'),
      description = TextEditingController(text: r?.description ?? '');
  final TextEditingController name, count, description;
  GameRole value() => GameRole.fromJson({
    'name': name.text.trim(),
    'count': int.parse(count.text),
    'description': description.text.trim(),
  });
  void dispose() {
    name.dispose();
    count.dispose();
    description.dispose();
  }
}

class RuleDraft {
  RuleDraft(ScoreRule? r)
    : name = TextEditingController(text: r?.name ?? ''),
      factor = TextEditingController(text: '${r?.factor ?? 1}'),
      step = TextEditingController(text: '${r?.step ?? 1}'),
      bonus = TextEditingController(text: '${r?.bonus ?? 0}'),
      table = TextEditingController(text: r?.table.join(', ') ?? ''),
      kind = r?.kind ?? 'linear';
  final TextEditingController name, factor, step, bonus, table;
  String kind;
  ScoreRule value() => ScoreRule.fromJson({
    'name': name.text.trim(),
    'kind': kind,
    'factor': double.parse(factor.text.replaceAll(',', '.')),
    'step': double.parse(step.text.replaceAll(',', '.')),
    'bonus': double.parse(bonus.text.replaceAll(',', '.')),
    'table': kind == 'lookup'
        ? table.text.split(',').map((s) => double.parse(s.trim())).toList()
        : <double>[],
  });
  void dispose() {
    name.dispose();
    factor.dispose();
    step.dispose();
    bonus.dispose();
    table.dispose();
  }
}
