import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/sheet_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_edit_dialog.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_field_row.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_labels.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetEditor extends StatelessWidget {
  const SheetEditor({super.key, required this.sheet, required this.step});
  final CharacterSheet sheet;
  final int step;

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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: l10n.sheetStepOf(step, SheetSpec.stepCount),
          child: LinearProgressIndicator(
            value: step / SheetSpec.stepCount,
            minHeight: Space.sm,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          children: [
            for (var i = 1; i <= SheetSpec.stepCount; i++)
              ChoiceChip(
                key: ValueKey('sheet-step-$i'),
                label: Text('$i'),
                selected: i == step,
                avatar: sheet.stepComplete(i)
                    ? const Icon(Icons.check, size: TypeScale.body)
                    : null,
                onSelected: (_) => cubit.goTo(i),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        Text(
          l10n.sheetStepOf(step, SheetSpec.stepCount),
          style: theme.textTheme.labelLarge,
        ),
        Text(sheetStepLabel(l10n, step), style: theme.textTheme.headlineSmall),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          children: [
            OutlinedButton(
              key: const ValueKey('sheet-generate-step'),
              onPressed: cubit.generateStep,
              child: Text(l10n.sheetGenerateStep),
            ),
            FilledButton(
              key: const ValueKey('sheet-generate-all'),
              onPressed: cubit.generateAll,
              child: Text(l10n.sheetGenerateAll),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
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
