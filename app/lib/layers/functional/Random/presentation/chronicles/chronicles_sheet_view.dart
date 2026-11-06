import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_export.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_sheet.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/chronicles_mapping.dart';
import 'package:amiludo/layers/functional/Random/presentation/character_sheet_stack.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Network/link_share.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ChroniclesSheetView extends StatefulWidget {
  const ChroniclesSheetView({
    super.key,
    required this.data,
    required this.run,
    this.onSave,
  });
  final ChroniclesData data;
  final ChroniclesRun run;
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  State<ChroniclesSheetView> createState() => _ChroniclesSheetViewState();
}

class _ChroniclesSheetViewState extends State<ChroniclesSheetView> {
  bool saved = false;

  ChroniclesSheet get sheet => ChroniclesSheet.build(
    widget.data,
    widget.run.universe,
    widget.run.kept,
  );

  Map<String, List<CharacterCard>> choices(ChroniclesSheet s, String destiny) =>
      {
        for (final section in s.sections)
          if (section.fields.isNotEmpty)
            section.step.name: [
              for (final k in section.fields)
                characterCardOf(
                  k.card,
                  prefix: k.destiny ? destiny : '',
                ),
            ],
      };

  Future<void> save(ChroniclesSheet s) async {
    final destiny = context.l10n.chroniclesChosenByDestiny;
    await widget.onSave!(
      GameCharacter(
        id: newId(),
        name: s.name,
        packName: s.universe.name,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        choices: choices(s, destiny),
      ),
    );
    if (mounted) setState(() => saved = true);
  }

  Future<void> copy(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.chroniclesCopied;
    await copyText(text);
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final s = sheet;
    final theme = Theme.of(context);
    final destiny = context.l10n.chroniclesChosenByDestiny;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(context.l10n.chroniclesSheet),
        Text(s.name, style: theme.textTheme.headlineMedium),
        Text(s.epithet, style: theme.textTheme.titleMedium),
        Text('${context.l10n.chroniclesRarity} : ${s.rarity.name}'),
        const SizedBox(height: Space.lg),
        Text(
          context.l10n.chroniclesAbilities,
          style: theme.textTheme.titleMedium,
        ),
        Wrap(
          spacing: Space.lg,
          children: [
            for (final stat in widget.data.stats)
              Text('${stat.name} ${s.stats[stat.id]}'),
          ],
        ),
        for (final section in s.sections) ...[
          SectionHeading(section.step.name),
          for (final k in section.fields)
            Text(
              '${s.labels[k.card.id]} : ${k.card.name}'
              '${k.destiny ? ' ($destiny)' : ''}',
            ),
        ],
        SectionHeading(context.l10n.chroniclesCards),
        CharacterSheetStack(choices: choices(s, destiny)),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          children: [
            OutlinedButton(
              key: const ValueKey('copy-text'),
              onPressed: () => copy(ChroniclesExport.text(s, widget.data)),
              child: Text(context.l10n.chroniclesCopyText),
            ),
            OutlinedButton(
              key: const ValueKey('copy-json'),
              onPressed: () => copy(ChroniclesExport.jsonText(s)),
              child: Text(context.l10n.chroniclesCopyJson),
            ),
            OutlinedButton(
              key: const ValueKey('share'),
              onPressed: () =>
                  shareLink(ChroniclesExport.text(s, widget.data)),
              child: Text(context.l10n.chroniclesShare),
            ),
            if (widget.onSave != null)
              FilledButton(
                key: const ValueKey('save'),
                onPressed: saved ? null : () => save(s),
                child: Text(
                  saved
                      ? context.l10n.chroniclesSaved
                      : context.l10n.chroniclesSaveToLibrary,
                ),
              ),
            TextButton(
              onPressed: context.read<ChroniclesCubit>().restart,
              child: Text(context.l10n.chroniclesRestart),
            ),
          ],
        ),
      ],
    );
  }
}
