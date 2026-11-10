import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/sheet_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_edit_dialog.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_field_row.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_generate_buttons.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_labels.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/section.dart';
import 'package:amiludo/layers/technical/Theme/components/step_indicator.dart';
import 'package:amiludo/layers/technical/Theme/components/tag_chip.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetEditor extends StatelessWidget {
  const SheetEditor({
    super.key,
    required this.sheet,
    required this.step,
    this.editions = const [],
    this.inlineGenerate = true,
  });
  final CharacterSheet sheet;
  final int step;
  final List<String> editions;
  final bool inlineGenerate;

  void _edit(BuildContext context, SheetField field) {
    final cubit = context.read<SheetCubit>();
    showDialog<void>(
      context: context,
      builder: (_) => SheetEditDialog(
        field: field,
        label: sheetFieldLabel(context.l10n, field.id),
        initial: sheet.of(field.id),
        onSubmit: (values) => cubit.edit(field.id, values),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SheetCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (editions.isNotEmpty)
          Section(
            title: l10n.sheetEditionLabel,
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final e in editions)
                  TagChip(
                    key: ValueKey('sheet-edition-$e'),
                    label: sheetEditionLabel(l10n, e),
                    selected: sheet.edition == e,
                    onSelected: (on) => cubit.setEdition(on ? e : null),
                  ),
              ],
            ),
          ),
        StepIndicator(
          count: SheetSpec.stepCount,
          current: step,
          label: l10n.sheetStepOf(step, SheetSpec.stepCount),
          completed: sheet.stepComplete,
          onSelect: cubit.goTo,
          stepKey: (i) => ValueKey('sheet-step-$i'),
        ),
        const SizedBox(height: Space.xl),
        Section(
          kicker: l10n.sheetStepOf(step, SheetSpec.stepCount),
          title: sheetStepLabel(l10n, step),
          child: inlineGenerate
              ? Row(
                  children: [
                    for (final (i, b) in sheetGenerateButtons(
                      context,
                    ).indexed) ...[
                      if (i > 0) const SizedBox(width: Space.md),
                      Expanded(child: b),
                    ],
                  ],
                )
              : const SizedBox.shrink(),
        ),
        for (final field in SheetSpec.ofStep(step))
          SheetFieldRow(
            key: ValueKey('sheet-row-${field.id}'),
            field: field,
            label: sheetFieldLabel(l10n, field.id),
            values: sheet.of(field.id),
            locked: sheet.isLocked(field.id),
            onReroll: () => cubit.reroll(field.id),
            onLock: () => cubit.toggleLock(field.id),
            onEdit: () => _edit(context, field),
          ),
        const SizedBox(height: Space.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              key: const ValueKey('sheet-previous'),
              onPressed: step > 1 ? () => cubit.goTo(step - 1) : null,
              child: Text(l10n.sheetPrevious),
            ),
            TextButton(
              key: const ValueKey('sheet-next'),
              onPressed: step < SheetSpec.stepCount
                  ? () => cubit.goTo(step + 1)
                  : null,
              child: Text(l10n.sheetNext),
            ),
          ],
        ),
      ],
    );
  }
}
