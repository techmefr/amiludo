import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_header.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ChroniclesEditionStep extends StatefulWidget {
  const ChroniclesEditionStep({
    super.key,
    required this.data,
    required this.run,
  });
  final ChroniclesData data;
  final ChroniclesRun run;

  @override
  State<ChroniclesEditionStep> createState() => _ChroniclesEditionStepState();
}

class _ChroniclesEditionStepState extends State<ChroniclesEditionStep> {
  String? edition;

  String statNames(ChroniclesEdition e) => [
    for (final s in e.stats)
      widget.data.stats.firstWhere((x) => x.id == s).name,
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChroniclesCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChroniclesHeader(data: widget.data, run: widget.run),
        Text(
          context.l10n.chroniclesChooseEdition,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: Space.md),
        ResponsiveGrid(
          minimumWidth: 160,
          children: [
            for (final e in widget.data.editions)
              DeckTile(
                key: ValueKey('edition-${e.id}'),
                icon: Icons.auto_stories_outlined,
                title: e.name,
                subtitle: statNames(e),
                selected: edition == e.id,
                onTap: () => setState(() => edition = e.id),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          children: [
            FilledButton(
              key: const ValueKey('tear'),
              onPressed: edition == null
                  ? null
                  : () => cubit.openBooster(edition!),
              child: Text(context.l10n.chroniclesTearBooster),
            ),
            OutlinedButton(
              key: const ValueKey('destiny'),
              onPressed: cubit.letDestinyComplete,
              child: Text(context.l10n.chroniclesDestiny),
            ),
            TextButton(
              onPressed: cubit.restart,
              child: Text(context.l10n.chroniclesRestart),
            ),
          ],
        ),
      ],
    );
  }
}
