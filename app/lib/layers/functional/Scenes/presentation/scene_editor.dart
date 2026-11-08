import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scene_ambience.dart';
import 'package:amiludo/layers/technical/Sound/ambient_sounds.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<Scene?> showSceneEditor(
  BuildContext context, {
  Scene? scene,
  required List<Scene> others,
  required Map<String, String> creatureNames,
  VoidCallback? onDelete,
}) => showModalBottomSheet<Scene>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => SceneEditor(
    scene: scene,
    others: others,
    creatureNames: creatureNames,
    onDelete: onDelete,
  ),
);

class SceneEditor extends StatefulWidget {
  const SceneEditor({
    super.key,
    this.scene,
    this.others = const [],
    this.creatureNames = const {},
    this.onDelete,
  });
  final Scene? scene;
  final List<Scene> others;
  final Map<String, String> creatureNames;
  final VoidCallback? onDelete;

  @override
  State<SceneEditor> createState() => _SceneEditorState();
}

class _SceneEditorState extends State<SceneEditor> {
  late final title = TextEditingController(text: widget.scene?.title);
  late final notes = TextEditingController(text: widget.scene?.notes);
  late final handout = TextEditingController(text: widget.scene?.handout);
  late final Set<String> next = {...?widget.scene?.nextIds};
  late final Set<String> creatures = {...?widget.scene?.creatureIds};
  late String? ambience = widget.scene?.ambience;

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    handout.dispose();
    super.dispose();
  }

  void _save() {
    final clean = title.text.trim();
    if (clean.isEmpty) return;
    Navigator.pop(
      context,
      Scene(
        id: widget.scene?.id ?? newSceneId(),
        title: clean,
        notes: notes.text.trim(),
        handout: handout.text.trim(),
        nextIds: next.toList(),
        creatureIds: creatures.toList(),
        ambience: ambience,
      ),
    );
  }

  Widget _chips(
    String label,
    Map<String, String> options,
    Set<String> selected,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Space.lg),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final MapEntry(key: id, value: name) in options.entries)
              FilterChip(
                label: Text(name),
                selected: selected.contains(id),
                onSelected: (on) =>
                    setState(() => on ? selected.add(id) : selected.remove(id)),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: l.scenesTitleField),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: notes,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: l.scenesNotes),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: handout,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(labelText: l.scenesHandout),
            ),
            _chips(l.scenesLeadsTo, {
              for (final s in widget.others) s.id: s.title,
            }, next),
            _chips(l.scenesCreatures, widget.creatureNames, creatures),
            const SizedBox(height: Space.lg),
            Text(
              l.scenesAmbience,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                ChoiceChip(
                  label: Text(l.scenesAmbienceNone),
                  selected: ambience == null,
                  onSelected: (_) => setState(() => ambience = null),
                ),
                for (final kind in AmbientKind.values)
                  ChoiceChip(
                    avatar: Icon(ambienceIcon(kind), size: 18),
                    label: Text(ambienceLabel(context, kind)),
                    selected: ambience == kind.name,
                    onSelected: (_) => setState(() => ambience = kind.name),
                  ),
              ],
            ),
            const SizedBox(height: Space.lg),
            FilledButton(onPressed: _save, child: Text(l.scenesSave)),
            if (widget.onDelete != null)
              TextButton(
                onPressed: () {
                  widget.onDelete!();
                  Navigator.pop(context);
                },
                child: Text(l.scenesDelete),
              ),
          ],
        ),
      ),
    );
  }
}
