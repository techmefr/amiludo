import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/playlist_panel.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/sound_entries_sheet.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/sound_pad_grid.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_focus.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const defaultSoundOwnerId = 'table';

class SoundboardTool extends StatefulWidget {
  const SoundboardTool({
    super.key,
    required this.sets,
    required this.library,
    required this.engine,
    required this.pads,
    this.ownerKind = SoundOwnerKind.companion,
    this.ownerId = defaultSoundOwnerId,
  });

  final SoundSetUseCases sets;
  final SoundLibraryGateway library;
  final PlaylistEngine engine;
  final PadPlayer pads;
  final SoundOwnerKind ownerKind;
  final String ownerId;

  @override
  State<SoundboardTool> createState() => _SoundboardToolState();
}

class _SoundboardToolState extends State<SoundboardTool> {
  late final StreamSubscription<SoundLibrary> _changes;
  String? _selectedId;

  List<SoundSet> get _owned =>
      widget.library.current.ownedBy(widget.ownerKind, widget.ownerId);

  SoundSet? get _selected {
    for (final s in _owned) {
      if (s.id == _selectedId) return s;
    }
    return _owned.firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    _sync();
    _changes = widget.library.changes.listen((_) {
      if (!mounted) return;
      setState(_sync);
    });
  }

  void _sync() {
    final set = _selected;
    _selectedId = set?.id;
    if (set != null) widget.engine.load(set);
  }

  @override
  void dispose() {
    _changes.cancel();
    widget.engine.dispose();
    widget.pads.stopAll();
    widget.pads.dispose();
    super.dispose();
  }

  Future<String?> _ask(String title, [String initial = '']) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.l10n.soundboardSetName,
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final name = (await _ask(context.l10n.soundboardNewSet))?.trim();
    if (name == null || name.isEmpty) return;
    final set = await widget.sets.create(
      widget.ownerKind,
      widget.ownerId,
      name,
    );
    if (mounted) setState(() => _selectedId = set.id);
  }

  Future<void> _rename(SoundSet set) async {
    final name = (await _ask(context.l10n.soundboardRename, set.name))?.trim();
    if (name != null && name.isNotEmpty) await widget.sets.rename(set.id, name);
  }

  Future<void> _delete(SoundSet set) async {
    await widget.engine.stop();
    await widget.pads.stopAll();
    await widget.sets.delete(set.id);
  }

  void _manage(SoundSet set) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SoundEntriesSheet(
      setId: set.id,
      sets: widget.sets,
      library: widget.library,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final set = _selected;
    return Align(
      alignment: Alignment.topCenter,
      child: ToolFocus(
        baseWidth: 640,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final s in _owned)
                  ChoiceChip(
                    label: Text(s.name),
                    selected: s.id == set?.id,
                    onSelected: (_) => setState(() {
                      _selectedId = s.id;
                      _sync();
                    }),
                  ),
                ActionChip(
                  avatar: const DeckIcon(Icons.add),
                  label: Text(l.soundboardNewSet),
                  onPressed: _create,
                ),
              ],
            ),
            const SizedBox(height: Space.lg),
            if (set == null)
              Text(l.soundboardNoSets)
            else ...[
              Wrap(
                spacing: Space.sm,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _manage(set),
                    icon: const DeckIcon(Icons.library_add_outlined),
                    label: Text(l.soundboardManage),
                  ),
                  TextButton.icon(
                    onPressed: () => _rename(set),
                    icon: const DeckIcon(Icons.edit_outlined),
                    label: Text(l.soundboardRename),
                  ),
                  TextButton.icon(
                    onPressed: () => _delete(set),
                    icon: const DeckIcon(Icons.delete_outline),
                    label: Text(l.soundboardDeleteSet),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              PlaylistPanel(set: set, engine: widget.engine, sets: widget.sets),
              const SizedBox(height: Space.xl),
              SoundPadGrid(set: set, pads: widget.pads, sets: widget.sets),
            ],
          ],
        ),
      ),
    );
  }
}
