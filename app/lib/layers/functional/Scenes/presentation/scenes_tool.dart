import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';
import 'package:amiludo/layers/functional/Scenes/domain/entities/storyline.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/handout_page.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scene_card.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scene_editor.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scene_ambience.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Sound/ambient_output.dart';
import 'package:amiludo/layers/technical/Sound/ambient_sounds.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ScenesTool extends StatefulWidget {
  const ScenesTool({
    super.key,
    this.initial = const Storyline(),
    this.onChanged,
    this.creatureNames = const {},
    this.placeNames = const {},
    this.ambient = const SilentAmbientOutput(),
  });
  final Storyline initial;
  final ValueChanged<Storyline>? onChanged;
  final Map<String, String> creatureNames;
  final Map<String, String> placeNames;
  final AmbientOutput ambient;

  @override
  State<ScenesTool> createState() => _ScenesToolState();
}

class _ScenesToolState extends State<ScenesTool> {
  late Storyline storyline = widget.initial;
  final tool = toolThemeFor('scenes');
  String? playingId;

  @override
  void dispose() {
    widget.ambient.stopAll();
    super.dispose();
  }

  Future<void> _ambience(Scene scene) async {
    final kind = ambienceKind(scene.ambience);
    await widget.ambient.stopAll();
    if (kind == null || playingId == scene.id) {
      if (mounted) setState(() => playingId = null);
      return;
    }
    await widget.ambient.start(kind.name, ambientLoop(kind), .6);
    if (mounted) setState(() => playingId = scene.id);
  }

  void _commit(Storyline next) {
    setState(() => storyline = next);
    widget.onChanged?.call(next);
  }

  Future<void> _edit([Scene? scene]) async {
    final saved = await showSceneEditor(
      context,
      scene: scene,
      others: [
        for (final s in storyline.scenes)
          if (s.id != scene?.id) s,
      ],
      creatureNames: widget.creatureNames,
      onDelete: scene == null ? null : () => _commit(storyline.remove(scene.id)),
    );
    if (saved != null) _commit(storyline.put(saved));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scenes = storyline.scenes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: _edit,
            icon: const DeckIcon(Icons.add),
            label: Text(l.scenesAdd),
          ),
        ),
        const SizedBox(height: Space.lg),
        if (scenes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Text(l.scenesEmpty, textAlign: TextAlign.center),
          ),
        for (final (i, s) in scenes.indexed)
          Padding(
            key: ValueKey(s.id),
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: SceneCard(
              scene: s,
              number: i + 1,
              tool: tool,
              followers: storyline.followers(s),
              placeName: widget.placeNames[s.id],
              creatureNames: [
                for (final id in s.creatureIds)
                  if (widget.creatureNames[id] != null)
                    widget.creatureNames[id]!,
              ],
              onOpen: () => _edit(s),
              onShow: () => showHandout(context, s),
              playing: playingId == s.id,
              onAmbience: () => _ambience(s),
              onUp: i == 0 ? null : () => _commit(storyline.move(s.id, -1)),
              onDown: i == scenes.length - 1
                  ? null
                  : () => _commit(storyline.move(s.id, 1)),
            ),
          ),
      ],
    );
  }
}
