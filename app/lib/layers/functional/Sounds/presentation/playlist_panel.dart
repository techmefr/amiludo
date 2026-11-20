import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/playlist_state.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class PlaylistPanel extends StatelessWidget {
  const PlaylistPanel({
    super.key,
    required this.set,
    required this.engine,
    required this.sets,
  });

  final SoundSet set;
  final PlaylistEngine engine;
  final SoundSetUseCases sets;

  PlaylistRepeat _nextRepeat(PlaylistRepeat repeat) => switch (repeat) {
    PlaylistRepeat.off => PlaylistRepeat.all,
    PlaylistRepeat.all => PlaylistRepeat.one,
    PlaylistRepeat.one => PlaylistRepeat.off,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final playlist = set.playlist;
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.soundboardPlaylist,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: l.soundboardShuffle,
                isSelected: playlist.shuffle,
                onPressed: () =>
                    sets.configure(set.id, shuffle: !playlist.shuffle),
                icon: const DeckIcon(Icons.shuffle),
              ),
              IconButton(
                tooltip: l.soundboardPrevious,
                onPressed: engine.previous,
                icon: const DeckIcon(Icons.skip_previous),
              ),
              IconButton.filled(
                tooltip: engine.playing ? l.soundboardPause : l.soundboardPlay,
                onPressed: engine.playing ? engine.pause : engine.play,
                icon: DeckIcon(engine.playing ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                tooltip: l.soundboardNext,
                onPressed: engine.next,
                icon: const DeckIcon(Icons.skip_next),
              ),
              IconButton(
                tooltip: l.soundboardRepeat,
                isSelected: playlist.repeat != PlaylistRepeat.off,
                onPressed: () => sets.configure(
                  set.id,
                  repeat: _nextRepeat(playlist.repeat),
                ),
                icon: DeckIcon(
                  playlist.repeat == PlaylistRepeat.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                ),
              ),
            ],
          ),
          Slider(
            value: set.playlistVolume,
            label: l.soundboardPlaylistVolume,
            semanticFormatterCallback: (v) =>
                '${l.soundboardPlaylistVolume} ${(v * 100).round()}%',
            onChanged: (v) {
              engine.setVolume(v);
              sets.configure(set.id, playlistVolume: v);
            },
          ),
          if (playlist.entryIds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Text(l.soundboardPlaylistEmpty),
            )
          else
            for (final id in playlist.entryIds)
              if (set.entry(id) != null)
                ListTile(
                  dense: true,
                  selected: engine.currentId == id,
                  leading: DeckIcon(
                    engine.currentId == id && engine.playing
                        ? Icons.graphic_eq
                        : Icons.music_note,
                  ),
                  title: Text(set.entry(id)!.name),
                ),
        ],
      ),
    );
  }
}
