import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_components.dart';
import 'package:amiludo/layers/functional/Templates/presentation/creation_draft.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_component_stages.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_drafts.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_rule_stages.dart';

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
  bool trackers = false;
  List<String> get stages => [
    'Jeu',
    'Modes',
    if (modes.contains('dice')) 'Dés',
    if (modes.contains('roles')) 'Rôles',
    if (modes.contains('scores')) 'Points',
    if (trackers) 'Compteurs',
    if (modes.contains('character')) 'Personnages',
    if (modes.contains('timer')) 'Temps',
    if (modes.contains('rules')) 'Règles',
    'Résumé',
  ];
  final creation = <CreationDraft>[];
  final dice = <DieDraft>[], roles = <RoleDraft>[], rules = <RuleDraft>[];
  final resources = <ResourceDraft>[];
  final statuses = <TextEditingController>[];
  bool low = false, coop = false, saved = false;
  String? error;
  late final String id;

  List<TextEditingController> get _fields => [
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
  ];

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
    _loadDrafts(t);
  }

  void _loadDrafts(GameTemplate t) {
    creation.addAll(t.creation.map(CreationDraft.new));
    dice.addAll(t.dice.map(DieDraft.new));
    roles.addAll(t.roles.map(RoleDraft.new));
    rules.addAll(
      t.scoring.isNotEmpty
          ? t.scoring.map(RuleDraft.new)
          : t.categories.map((n) => RuleDraft(ScoreRule(name: n))),
    );
    resources.addAll(
      t.resources.entries.map((e) => ResourceDraft(e.key, e.value)),
    );
    statuses.addAll(t.statuses.map((s) => TextEditingController(text: s)));
    trackers = resources.isNotEmpty || statuses.isNotEmpty;
  }

  @override
  void dispose() {
    for (final c in [..._fields, ...statuses]) {
      c.dispose();
    }
    for (final dispose in [
      ...creation.map((d) => d.dispose),
      ...dice.map((d) => d.dispose),
      ...roles.map((d) => d.dispose),
      ...rules.map((d) => d.dispose),
      ...resources.map((d) => d.dispose),
    ]) {
      dispose();
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
        resources: trackers
            ? Map.fromEntries(resources.map((d) => d.value()))
            : const {},
        statuses: trackers
            ? statuses.map((c) => c.text.trim()).toList()
            : const [],
      ).toJson(),
    );
  }

  void _leave() {
    setState(() => saved = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/templates');
      }
    });
  }

  Future<void> save() async {
    try {
      await context.read<TemplatesCubit>().addTemplate(compile());
      if (mounted) {
        notify(context, 'Pack enregistré sur cet appareil');
        _leave();
      }
    } on FormatException catch (e) {
      setState(() => error = e.message);
    } on TypeError {
      setState(() => error = 'Vérifiez les nombres et les champs du pack.');
    }
  }

  void _toggleTool(String tool, bool on) => setState(() {
    if (!on) {
      modes.remove(tool);
      return;
    }
    modes.add(tool);
    if (tool == 'dice' && dice.isEmpty) dice.add(DieDraft(null));
  });

  void _next() {
    if (stage == 0 &&
        (name.text.trim().isEmpty || englishName.text.trim().isEmpty)) {
      setState(() => error = 'Renseignez le nom du jeu et son nom anglais.');
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
  }

  Widget _stage() => switch (stages[stage]) {
    'Jeu' => Column(
      children: [
        BuilderField(name, 'Nom du jeu ou du pack', maxLength: 80),
        BuilderField(englishName, 'Nom du jeu en anglais', maxLength: 80),
        BuilderField(description, 'Présentation', lines: 2, maxLength: 500),
        BuilderField(edition, 'Édition ou variante', maxLength: 120),
        BuilderField(language, 'Langue du pack (fr, en…)'),
      ],
    ),
    'Modes' => ModesStage(
      modes: modes,
      trackers: trackers,
      onTool: _toggleTool,
      onTrackers: (v) => setState(() => trackers = v),
    ),
    'Dés' => DiceStage(dice: dice, refresh: setState),
    'Rôles' => RolesStage(roles: roles, refresh: setState),
    'Points' => PointsStage(
      rules: rules,
      target: target,
      low: low,
      coop: coop,
      onLow: (v) => setState(() => low = v),
      onCoop: (v) => setState(() => coop = v),
      refresh: setState,
    ),
    'Compteurs' => TrackersStage(
      resources: resources,
      statuses: statuses,
      refresh: setState,
    ),
    'Personnages' => CharactersStage(creation: creation, refresh: setState),
    'Temps' => BuilderField(seconds, 'Temps par tour en secondes'),
    'Règles' => RulesStage(url: url, notes: notes),
    _ => SummaryStage(
      title: '${name.text} / ${englishName.text}',
      modes: {...modes, if (trackers) 'compteurs'},
      author: author,
      license: license,
      revision: revision,
    ),
  };

  Future<void> _confirmLeave(bool didPop, Object? result) async {
    if (didPop) return;
    if (await confirm(
          context,
          'Quitter le builder ?',
          'Les modifications non enregistrées seront perdues.',
        ) &&
        mounted) {
      _leave();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: saved,
    onPopInvokedWithResult: _confirmLeave,
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
          _stage(),
          _StageNavigation(
            last: stages[stage] == 'Résumé',
            first: stage == 0,
            error: error,
            onNext: _next,
            onBack: () => setState(() {
              stage--;
              error = null;
            }),
            onSave: save,
          ),
        ],
      ),
    ),
  );
}

class _StageNavigation extends StatelessWidget {
  const _StageNavigation({
    required this.last,
    required this.first,
    required this.error,
    required this.onNext,
    required this.onBack,
    required this.onSave,
  });
  final bool last, first;
  final String? error;
  final VoidCallback onNext, onBack, onSave;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!last)
        FilledButton(onPressed: onNext, child: const Text('Continuer')),
      if (!first)
        TextButton(onPressed: onBack, child: const Text('Étape précédente')),
      if (error != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      if (last)
        FilledButton.icon(
          onPressed: onSave,
          icon: const DeckIcon(Icons.save_outlined),
          label: const Text('Enregistrer le pack'),
        ),
    ],
  );
}
