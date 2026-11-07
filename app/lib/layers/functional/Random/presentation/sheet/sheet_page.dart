import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_checks.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/sheet_cubit.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_editor.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_export_bar.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_labels.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_read_view.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetPage extends StatelessWidget {
  const SheetPage({super.key, this.onSave});
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  Widget build(BuildContext context) => FullPage(
    title: context.l10n.sheetTitle,
    child: SheetView(onSave: onSave),
  );
}

class SheetView extends StatefulWidget {
  const SheetView({super.key, this.onSave});
  final Future<void> Function(GameCharacter character)? onSave;

  @override
  State<SheetView> createState() => _SheetViewState();
}

class _SheetViewState extends State<SheetView> {
  bool saved = false;

  Future<void> save(SheetState state) async {
    final sheet = state.sheet!;
    final universe = sheetUniverseLabel(context.l10n, sheet.universe);
    await widget.onSave!(
      GameCharacter(
        id: newId(),
        name: sheet.first('name'),
        packName: universe,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        choices: const {},
        sheet: sheet.toJson(),
      ),
    );
    if (mounted) setState(() => saved = true);
  }

  Widget picker(BuildContext context, SheetState state) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: l10n.sheetTitle,
          title: l10n.sheetChooseUniverse,
          subtitle: l10n.sheetSubtitle,
        ),
        ResponsiveGrid(
          minimumWidth: 200,
          children: [
            for (final id in state.generator!.tables.universes.keys)
              DeckTile(
                key: ValueKey('sheet-universe-$id'),
                icon: Icons.auto_stories_outlined,
                title: sheetUniverseLabel(l10n, id),
                onTap: () => context.read<SheetCubit>().start(id),
              ),
          ],
        ),
      ],
    );
  }

  Widget sheetBody(
    BuildContext context,
    SheetState state,
    CharacterSheet sheet,
  ) {
    final l10n = context.l10n;
    final cubit = context.read<SheetCubit>();
    final mismatch = SheetChecks.problems(sheet, state.generator!.tables);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<bool>(
          key: const ValueKey('sheet-mode'),
          segments: [
            ButtonSegment(value: false, label: Text(l10n.sheetEditMode)),
            ButtonSegment(value: true, label: Text(l10n.sheetReadMode)),
          ],
          selected: {state.reading},
          onSelectionChanged: (v) => cubit.setReading(v.first),
        ),
        const SizedBox(height: Space.lg),
        if (mismatch.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: Text(
              l10n.sheetMismatch,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (state.reading)
          SheetReadView(sheet: sheet, tables: state.generator!.tables)
        else
          SheetEditor(sheet: sheet, step: state.step),
        const SizedBox(height: Space.xl),
        SheetExportBar(
          sheet: sheet,
          saved: saved,
          onSave: widget.onSave == null || sheet.first('name').isEmpty
              ? null
              : () => save(state),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<SheetCubit, SheetState>(
    builder: (context, state) {
      if (state.failed) return Text(context.l10n.sheetLoadFailed);
      if (state.generator == null) return const SizedBox.shrink();
      final sheet = state.sheet;
      if (sheet == null) return picker(context, state);
      return sheetBody(context, state, sheet);
    },
  );
}
