import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_editor_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_library_actions.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_preview.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/immersive_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DieLibraryScreen extends StatefulWidget {
  const DieLibraryScreen({super.key});

  @override
  State<DieLibraryScreen> createState() => _DieLibraryScreenState();
}

class _DieLibraryScreenState extends State<DieLibraryScreen> {
  final selected = <String>{};

  void toggle(String id) => setState(
    () => selected.contains(id) ? selected.remove(id) : selected.add(id),
  );

  Future<void> open(DieStudioCubit cubit, DieDesign? design) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DieStudio(
            cubit: cubit,
            child: DieEditorScreen(initial: design),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = DieStudio.maybeOf(context)!;
    final l = context.l10n;
    final compactAction =
        MediaQuery.sizeOf(context).width < 400 &&
        MediaQuery.textScalerOf(context).scale(16) > 24;
    return ImmersivePage(
      title: l.diceLibraryTitle,
      fallback: '/tools',
      actions: [
        IconButton(
          tooltip: l.diceImport,
          constraints: const BoxConstraints.tightFor(
            width: Targets.minimum,
            height: Targets.minimum,
          ),
          icon: const DeckIcon(Icons.file_open_outlined),
          onPressed: () => importDice(context, cubit),
        ),
        IconButton(
          tooltip: l.diceExportSelection,
          constraints: const BoxConstraints.tightFor(
            width: Targets.minimum,
            height: Targets.minimum,
          ),
          icon: const DeckIcon(Icons.ios_share_outlined),
          onPressed: selected.isEmpty
              ? null
              : () => exportDice(context, cubit, selected.toList()),
        ),
      ],
      floatingActionButton: compactAction
          ? FloatingActionButton(
              onPressed: () => open(cubit, null),
              tooltip: l.diceNew,
              child: const DeckIcon(Icons.add),
            )
          : FloatingActionButton.extended(
              onPressed: () => open(cubit, null),
              icon: const DeckIcon(Icons.add),
              label: Text(l.diceNew),
            ),
      child: BlocBuilder<DieStudioCubit, DieLibrary>(
        bloc: cubit,
        builder: (context, library) => library.designs.isEmpty
            ? Center(child: Text(l.diceLibraryEmpty))
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.lg,
                  Space.lg,
                  96,
                ),
                children: [
                  for (final d in library.designs)
                    DieTile(
                      design: d,
                      selected: selected.contains(d.id),
                      onSelect: () => toggle(d.id),
                      onEdit: () => open(cubit, d),
                      onDuplicate: () =>
                          cubit.duplicate(d.id, l.diceCopyName(d.name)),
                      onDelete: () {
                        selected.remove(d.id);
                        cubit.remove(d.id);
                      },
                      onExport: () => exportDice(context, cubit, [d.id]),
                    ),
                ],
              ),
      ),
    );
  }
}

class DieTile extends StatelessWidget {
  const DieTile({
    super.key,
    required this.design,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onExport,
  });
  final DieDesign design;
  final bool selected;
  final VoidCallback onSelect, onEdit, onDuplicate, onDelete, onExport;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget action(String tip, IconData icon, VoidCallback tap) => IconButton(
      tooltip: tip,
      constraints: const BoxConstraints.tightFor(
        width: Targets.minimum,
        height: Targets.minimum,
      ),
      icon: DeckIcon(icon),
      onPressed: tap,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.sm),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  semanticLabel: l.diceSelectDie(design.name),
                  value: selected,
                  onChanged: (_) => onSelect(),
                ),
                DiePreview(design: design, size: 56),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(l.diceFaceTotal(design.sides)),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                action(l.diceEdit, Icons.edit_outlined, onEdit),
                action(l.diceDuplicate, Icons.copy_outlined, onDuplicate),
                action(l.diceExport, Icons.ios_share_outlined, onExport),
                action(l.diceDelete, Icons.delete_outline, onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
