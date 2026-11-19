import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/sound_colors.dart';
import 'package:amiludo/layers/technical/Files/audio_clip_import.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SoundEntriesSheet extends StatelessWidget {
  const SoundEntriesSheet({
    super.key,
    required this.setId,
    required this.sets,
    required this.library,
  });

  final String setId;
  final SoundSetUseCases sets;
  final SoundLibraryGateway library;

  Future<void> _import(BuildContext context, SoundKind kind) async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      for (final clip in await AudioClipImport.pick()) {
        await sets.importClip(
          setId,
          clip.name,
          clip.bytes,
          clip.mimeType,
          kind,
        );
      }
    } on AudioClipTooLarge {
      messenger.showSnackBar(SnackBar(content: Text(l.soundboardTooLarge)));
    } on SoundSetFull {
      messenger.showSnackBar(SnackBar(content: Text(l.soundboardFull)));
    }
  }

  Future<void> _replace(BuildContext context, SoundEntry entry) async {
    final clips = await AudioClipImport.pick();
    if (clips.isEmpty) return;
    await sets.replaceAudio(
      setId,
      entry.id,
      clips.first.bytes,
      clips.first.mimeType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return StreamBuilder<SoundLibrary>(
      stream: library.changes,
      initialData: library.current,
      builder: (context, snapshot) {
        final set = snapshot.data!.sets.where((s) => s.id == setId).firstOrNull;
        if (set == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.all(Space.lg),
          children: [
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                FilledButton.icon(
                  onPressed: () => _import(context, SoundKind.track),
                  icon: const DeckIcon(Icons.library_music_outlined),
                  label: Text(l.soundboardImportTracks),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _import(context, SoundKind.effect),
                  icon: const DeckIcon(Icons.graphic_eq),
                  label: Text(l.soundboardImportEffects),
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            if (set.entries.isEmpty) Text(l.soundboardEmpty),
            for (final entry in set.entries)
              _EntryTile(
                key: ValueKey(entry.id),
                set: set,
                entry: entry,
                sets: sets,
                onReplace: () => _replace(context, entry),
              ),
          ],
        );
      },
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    super.key,
    required this.set,
    required this.entry,
    required this.sets,
    required this.onReplace,
  });

  final SoundSet set;
  final SoundEntry entry;
  final SoundSetUseCases sets;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final inList = entry.kind == SoundKind.track
        ? set.playlist.entryIds.contains(entry.id)
        : set.soundboard.contains(entry.id);
    return ExpansionTile(
      leading: DeckIcon(
        entry.kind == SoundKind.track ? Icons.music_note : Icons.graphic_eq,
        color: soundColor(context, entry.color),
      ),
      title: Text(entry.name),
      subtitle: FutureBuilder<bool>(
        future: sets.isMissing(entry),
        builder: (context, snapshot) => snapshot.data == true
            ? Text(l.soundboardMissing)
            : const SizedBox(),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: TextFormField(
            initialValue: entry.name,
            decoration: InputDecoration(labelText: l.soundboardEntryName),
            onFieldSubmitted: (v) => sets.updateEntry(
              set.id,
              entry.id,
              (e) => e.copyWith(name: v.trim().isEmpty ? e.name : v.trim()),
            ),
          ),
        ),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final name in soundColorNames)
              IconButton(
                tooltip: name,
                isSelected: entry.color == name,
                onPressed: () => sets.updateEntry(
                  set.id,
                  entry.id,
                  (e) => e.copyWith(color: name),
                ),
                icon: DeckIcon(Icons.circle, color: soundColor(context, name)),
              ),
          ],
        ),
        if (entry.kind == SoundKind.effect)
          SwitchListTile(
            title: Text(l.soundboardLoop),
            value: entry.loop,
            onChanged: (v) =>
                sets.updateEntry(set.id, entry.id, (e) => e.copyWith(loop: v)),
          ),
        Wrap(
          spacing: Space.sm,
          children: [
            TextButton.icon(
              onPressed: () => entry.kind == SoundKind.track
                  ? (inList
                        ? sets.removeFromPlaylist(set.id, entry.id)
                        : sets.addToPlaylist(set.id, entry.id))
                  : (inList
                        ? sets.removeFromSoundboard(set.id, entry.id)
                        : sets.addToSoundboard(set.id, entry.id)),
              icon: DeckIcon(inList ? Icons.remove : Icons.add),
              label: Text(
                entry.kind == SoundKind.track
                    ? (inList
                          ? l.soundboardOutOfPlaylist
                          : l.soundboardToPlaylist)
                    : (inList ? l.soundboardOutOfPads : l.soundboardToPads),
              ),
            ),
            TextButton.icon(
              onPressed: onReplace,
              icon: const DeckIcon(Icons.swap_horiz),
              label: Text(l.soundboardReplace),
            ),
            TextButton.icon(
              onPressed: () => sets.removeEntry(set.id, entry.id),
              icon: const DeckIcon(Icons.delete_outline),
              label: Text(l.soundboardRemove),
            ),
          ],
        ),
      ],
    );
  }
}
