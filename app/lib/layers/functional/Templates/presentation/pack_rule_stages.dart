import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Templates/presentation/pack_drafts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
      Text(context.l10n.templatesPickOnlyTheToolsThis),
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
        title: Text(context.l10n.templatesRulesAndVariants),
        value: modes.contains('rules'),
        onChanged: (v) => onTool('rules', v == true),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(context.l10n.templatesPlayerCountersAndStatuses),
        subtitle: Text(context.l10n.templatesLivesEnergyPoisonShield),
        value: trackers,
        onChanged: (v) => onTrackers(v == true),
      ),
    ],
  );
}

const _ruleKinds = ['linear', 'sets', 'triangular', 'threshold', 'lookup'];

String _ruleKindLabel(BuildContext context, String kind) => switch (kind) {
  'linear' => context.l10n.templatesQuantityPoints,
  'sets' => context.l10n.templatesCompleteSets,
  'triangular' => context.l10n.templatesProgression123,
  'threshold' => context.l10n.templatesBonusFromAThreshold,
  _ => context.l10n.templatesCustomTable,
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
      SectionHeading(context.l10n.templates03Scoring),
      Text(context.l10n.templatesEachCategoryComputesATotal),
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
        label: Text(context.l10n.templatesAddACategory),
      ),
      const SizedBox(height: 20),
      BuilderField(target, context.l10n.templatesPointsGoal0None),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(context.l10n.templatesLowestScoreWins),
        value: low,
        onChanged: onLow,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(context.l10n.templatesCooperativeGoal),
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
        context.l10n.templatesPointsCategory,
        maxLength: 40,
      ),
      DropdownButtonFormField<String>(
        style: Theme.of(context).textTheme.bodyLarge,
        initialValue: rule.kind,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: context.l10n.templatesCalculationMethod,
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
              ? context.l10n.templatesPointsWhenTheThresholdIs
              : context.l10n.templatesPointsPerUnitOrSet,
        ),
      if (['sets', 'threshold'].contains(rule.kind))
        BuilderField(
          rule.step,
          rule.kind == 'sets'
              ? context.l10n.templatesSetSize
              : context.l10n.templatesThresholdToReach,
        ),
      if (rule.kind == 'lookup')
        BuilderField(
          rule.table,
          context.l10n.templatesTableFor012,
          hint: context.l10n.templatesCommaSeparatedValues01,
        ),
      BuilderField(rule.bonus, context.l10n.templatesFixedBonusOrPenalty),
      RemoveDraftButton(context.l10n.templatesRemoveThisCategory, onRemove),
    ],
  );
}

class RulesStage extends StatelessWidget {
  const RulesStage({super.key, required this.url, required this.notes});
  final TextEditingController url, notes;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SectionHeading(context.l10n.templates05RulesAndReferences),
      BuilderField(
        url,
        context.l10n.templatesHttpsLinkToTheRules,
        hint: context.l10n.templatesTheLinkOpensInThe,
      ),
      BuilderField(
        notes,
        context.l10n.templatesYourNotesAndVariants,
        lines: 6,
        maxLength: 12000,
        hint: context.l10n.templatesTheseNotesWillBeAvailable,
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
      Text('${context.l10n.templatesChosenTools} : ${modes.join(' · ')}'),
      const SizedBox(height: 16),
      ExpansionTile(
        title: Text(context.l10n.templatesPublishingAndCredits),
        children: [
          BuilderField(
            author,
            context.l10n.templatesPackAuthor,
            maxLength: 120,
          ),
          BuilderField(
            license,
            context.l10n.templatesPackLicence,
            hint: context.l10n.templatesMitCc010Cc,
          ),
          BuilderField(revision, context.l10n.templatesPackVersion),
        ],
      ),
    ],
  );
}
