import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ChroniclesHeader extends StatelessWidget {
  const ChroniclesHeader({super.key, required this.data, required this.run});
  final ChroniclesData data;
  final ChroniclesRun run;

  @override
  Widget build(BuildContext context) {
    final step = data.step(run.stepIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: run.stepIndex / data.steps.length),
        const SizedBox(height: Space.md),
        Text(
          '${context.l10n.chroniclesStep} ${run.stepIndex + 1} / '
          '${data.steps.length} · ${step.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Space.sm),
        ChroniclesNeeds(data: data, run: run),
        const SizedBox(height: Space.lg),
      ],
    );
  }
}

class ChroniclesNeeds extends StatelessWidget {
  const ChroniclesNeeds({super.key, required this.data, required this.run});
  final ChroniclesData data;
  final ChroniclesRun run;

  @override
  Widget build(BuildContext context) {
    final step = data.step(run.stepIndex);
    final missing = ChroniclesRules.missing(step, run.pool(data), run.kept);
    if (missing.isEmpty) return const SizedBox.shrink();
    final text = [
      for (final q in missing)
        '${data.shortLabels[q.type] ?? q.type} '
            '${ChroniclesRules.count(run.kept, step.id, q.type)}/${q.min}',
    ].join(' · ');
    return Text('${context.l10n.chroniclesStillMissing} : $text');
  }
}
