import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_face_ops.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_bulk_panel.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_grid.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_spinner.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/immersive_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DieEditorScreen extends StatefulWidget {
  const DieEditorScreen({super.key, this.initial});
  final DieDesign? initial;

  @override
  State<DieEditorScreen> createState() => _DieEditorScreenState();
}

class _DieEditorScreenState extends State<DieEditorScreen> {
  late DieDesign design = widget.initial ?? DieDesign.standard(dieId(), '', 6);
  late final name = TextEditingController(text: design.name);
  int current = 0;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void update(DieDesign next, {int? focus}) => setState(() {
    design = next;
    current = (focus ?? current).clamp(0, next.faces.length - 1);
  });

  Future<void> editFace(int index) async {
    setState(() => current = index);
    final result = await showFaceSheet(context, design, index);
    if (result == null || !mounted) return;
    DieStudio.maybeOf(context)!.staged.addAll(result.images);
    update(design.withFace(index, result.face));
  }

  Future<void> save() async {
    final used = design.imageIds;
    final cubit = DieStudio.maybeOf(context)!;
    await cubit.save(
      design.copyWith(name: name.text.trim()),
      images: {
        for (final e in cubit.staged.entries)
          if (used.contains(e.key)) e.key: e.value,
      },
    );
    cubit.staged.clear();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ImmersivePage(
      title: l.diceEditorTitle,
      child: LayoutBuilder(builder: layout),
    );
  }

  Widget header(double size) {
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DieFaceSpinner(
          design: design,
          current: current,
          size: size,
          onFace: (i) => setState(() => current = i),
          onTap: () => editFace(current),
        ),
        const SizedBox(height: Space.sm),
        FilledButton.tonalIcon(
          onPressed: () => editFace(current),
          icon: const Icon(Icons.edit_outlined),
          label: Text(l.diceFaceEdit(current + 1)),
        ),
      ],
    );
  }

  Widget layout(BuildContext context, BoxConstraints box) {
    final side = box.maxWidth >= 600 && box.maxHeight < 520;
    if (side) {
      final size = min(
        box.maxWidth * .32,
        box.maxHeight - 96,
      ).clamp(120.0, 300.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(Space.lg), child: header(size)),
          Expanded(child: form(context)),
        ],
      );
    }
    final size = min(
      box.maxWidth - Space.lg * 2,
      box.maxHeight * .34,
    ).clamp(120.0, 260.0);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Space.sm),
          child: header(size),
        ),
        Expanded(child: form(context)),
      ],
    );
  }

  Widget form(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(Space.lg),
      children: [
        TextField(
          controller: name,
          maxLength: maxDesignName,
          decoration: InputDecoration(labelText: l.diceName),
          onChanged: (_) => setState(() {}),
        ),
        Text(l.diceFaceCount),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final s in solidSides)
              ChoiceChip(
                label: Text('d$s'),
                selected: design.sides == s,
                onSelected: (_) => update(design.resized(s)),
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: minDieFaces.toDouble(),
                max: maxDieFaces.toDouble(),
                divisions: maxDieFaces - minDieFaces,
                value: design.sides.toDouble(),
                label: '${design.sides}',
                semanticFormatterCallback: (v) => l.diceFaceTotal(v.round()),
                onChanged: (v) => update(design.resized(v.round())),
              ),
            ),
            Text(l.diceFaceTotal(design.sides)),
          ],
        ),
        Text(l.diceBodyColor),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final c in facePalette)
              IconButton(
                tooltip: l.diceBodyColor,
                constraints: const BoxConstraints.tightFor(
                  width: Targets.minimum,
                  height: Targets.minimum,
                ),
                onPressed: () => update(design.copyWith(color: c)),
                icon: Icon(
                  c == design.color ? Icons.check_circle : Icons.circle,
                  color: Color(c),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Text(l.diceFaces, style: Theme.of(context).textTheme.titleMedium),
        DieFaceGrid(
          design: design,
          current: current,
          onTap: editFace,
          onChange: update,
        ),
        DieBulkPanel(design: design, current: current, onChange: update),
        const SizedBox(height: Space.xl),
        FilledButton(
          onPressed: name.text.trim().isEmpty ? null : save,
          child: Text(l.themeSave),
        ),
      ],
    );
  }
}
