import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_header.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ChroniclesRecap extends StatelessWidget {
  const ChroniclesRecap({super.key, required this.data, required this.run});
  final ChroniclesData data;
  final ChroniclesRun run;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChroniclesCubit>();
    final kept = run.boosterKept;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChroniclesHeader(data: data, run: run),
        SectionHeading(context.l10n.chroniclesRecap),
        if (kept.isEmpty) Text(context.l10n.chroniclesNoneKept),
        for (final c in kept)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(c.name),
            subtitle: Text(
              '${data.labelOf(c)} · ${data.rarity(c.rarity).name}',
            ),
          ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          children: [
            FilledButton(
              key: const ValueKey('continue'),
              onPressed: cubit.next,
              child: Text(context.l10n.chroniclesContinue),
            ),
            if (!run.stepComplete(data))
              OutlinedButton(
                key: const ValueKey('destiny'),
                onPressed: cubit.letDestinyComplete,
                child: Text(context.l10n.chroniclesDestiny),
              ),
          ],
        ),
      ],
    );
  }
}
