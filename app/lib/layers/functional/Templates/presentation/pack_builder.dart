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

enum BuilderStage {
  game,
  modes,
  dice,
  roles,
  points,
  trackers,
  characters,
  timer,
  rules,
  summary,
}

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
  List<BuilderStage> get stages => [
    BuilderStage.game,
    BuilderStage.modes,
    if (modes.contains('dice')) BuilderStage.dice,
    if (modes.contains('roles')) BuilderStage.roles,
    if (modes.contains('scores')) BuilderStage.points,
    if (trackers) BuilderStage.trackers,
    if (modes.contains('character')) BuilderStage.characters,
    if (modes.contains('timer')) BuilderStage.timer,
    if (modes.contains('rules')) BuilderStage.rules,
    BuilderStage.summary,
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
        notify(
          context,
          tr(
            context,
            'Pack enregistré sur cet appareil',
            'Pack saved on this device',
          ),
        );
        _leave();
      }
    } on FormatException catch (e) {
      setState(() => error = e.message);
    } on TypeError {
      setState(
        () => error = tr(
          context,
          'Vérifiez les nombres et les champs du pack.',
          'Check the numbers and fields of the pack.',
        ),
      );
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
      setState(
        () => error = tr(
          context,
          'Renseignez le nom du jeu et son nom anglais.',
          'Fill in the game name and its English name.',
        ),
      );
      return;
    }
    if (stage == 1 && modes.isEmpty) {
      setState(
        () => error = tr(
          context,
          'Choisissez au moins un outil.',
          'Pick at least one tool.',
        ),
      );
      return;
    }
    setState(() {
      stage++;
      error = null;
    });
  }

  Widget _gameStage() => Column(
    children: [
      BuilderField(
        name,
        tr(context, 'Nom du jeu ou du pack', 'Game or pack name'),
        maxLength: 80,
      ),
      BuilderField(
        englishName,
        tr(context, 'Nom du jeu en anglais', 'English game name'),
        maxLength: 80,
      ),
      BuilderField(
        description,
        tr(context, 'Présentation', 'Description'),
        lines: 2,
        maxLength: 500,
      ),
      BuilderField(
        edition,
        tr(context, 'Édition ou variante', 'Edition or variant'),
        maxLength: 120,
      ),
      BuilderField(
        language,
        tr(context, 'Langue du pack (fr, en…)', 'Pack language (fr, en…)'),
      ),
    ],
  );

  Widget _stage() => switch (stages[stage]) {
    BuilderStage.game => _gameStage(),
    BuilderStage.modes => ModesStage(
      modes: modes,
      trackers: trackers,
      onTool: _toggleTool,
      onTrackers: (v) => setState(() => trackers = v),
    ),
    BuilderStage.dice => DiceStage(dice: dice, refresh: setState),
    BuilderStage.roles => RolesStage(roles: roles, refresh: setState),
    BuilderStage.points => PointsStage(
      rules: rules,
      target: target,
      low: low,
      coop: coop,
      onLow: (v) => setState(() => low = v),
      onCoop: (v) => setState(() => coop = v),
      refresh: setState,
    ),
    BuilderStage.trackers => TrackersStage(
      resources: resources,
      statuses: statuses,
      refresh: setState,
    ),
    BuilderStage.characters => CharactersStage(
      creation: creation,
      refresh: setState,
    ),
    BuilderStage.timer => BuilderField(
      seconds,
      tr(context, 'Temps par tour en secondes', 'Turn time in seconds'),
    ),
    BuilderStage.rules => RulesStage(url: url, notes: notes),
    BuilderStage.summary => SummaryStage(
      title: '${name.text} / ${englishName.text}',
      modes: {...modes, if (trackers) tr(context, 'compteurs', 'counters')},
      author: author,
      license: license,
      revision: revision,
    ),
  };

  String _stageLabel(BuilderStage stage) => switch (stage) {
    BuilderStage.game => tr(context, 'Jeu', 'Game'),
    BuilderStage.modes => tr(context, 'Modes', 'Modes'),
    BuilderStage.dice => tr(context, 'Dés', 'Dice'),
    BuilderStage.roles => tr(context, 'Rôles', 'Roles'),
    BuilderStage.points => tr(context, 'Points', 'Points'),
    BuilderStage.trackers => tr(context, 'Compteurs', 'Counters'),
    BuilderStage.characters => tr(context, 'Personnages', 'Characters'),
    BuilderStage.timer => tr(context, 'Temps', 'Time'),
    BuilderStage.rules => tr(context, 'Règles', 'Rules'),
    BuilderStage.summary => tr(context, 'Résumé', 'Summary'),
  };

  Future<void> _confirmLeave(bool didPop, Object? result) async {
    if (didPop) return;
    if (await confirm(
          context,
          tr(context, 'Quitter le builder ?', 'Leave the builder?'),
          tr(
            context,
            'Les modifications non enregistrées seront perdues.',
            'Unsaved changes will be lost.',
          ),
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
          ? tr(context, 'Créer un pack de jeu', 'Create a game pack')
          : tr(context, 'Modifier le pack', 'Edit the pack'),
      fallback: '/templates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeckHeading(
            eyebrow: tr(context, 'ATELIER / VOTRE JEU', 'WORKSHOP / YOUR GAME'),
            title: tr(context, 'Un jeu, vos outils', 'One game, your tools'),
            subtitle: tr(
              context,
              'Construisez les dés, les rôles et le décompte. Enregistrez, testez puis partagez votre pack.',
              'Build the dice, roles and scoring. Save, test, then share your pack.',
            ),
          ),
          Text(
            '${tr(context, 'Étape', 'Step')} ${stage + 1} / ${stages.length} · ${_stageLabel(stages[stage])}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: (stage + 1) / stages.length),
          const SizedBox(height: 24),
          _stage(),
          _StageNavigation(
            last: stages[stage] == BuilderStage.summary,
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
        FilledButton(
          onPressed: onNext,
          child: Text(tr(context, 'Continuer', 'Continue')),
        ),
      if (!first)
        TextButton(
          onPressed: onBack,
          child: Text(tr(context, 'Étape précédente', 'Previous step')),
        ),
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
          label: Text(tr(context, 'Enregistrer le pack', 'Save the pack')),
        ),
    ],
  );
}
