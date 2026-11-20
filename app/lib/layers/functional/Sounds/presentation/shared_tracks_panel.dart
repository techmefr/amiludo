import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_share.dart';
import 'package:amiludo/layers/technical/Files/audio_clip_import.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SharedTracksPanel extends StatefulWidget {
  const SharedTracksPanel({
    super.key,
    required this.share,
    required this.sets,
    required this.blobs,
    required this.output,
    required this.set,
  });

  final SoundShare share;
  final SoundSetUseCases sets;
  final SoundBlobGateway blobs;
  final ClipOutput output;
  final SoundSet? set;

  @override
  State<SharedTracksPanel> createState() => _SharedTracksPanelState();
}

class _SharedTracksPanelState extends State<SharedTracksPanel> {
  String? _playing;

  Future<void> _suggest() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final List<AudioClip> clips;
    try {
      clips = await AudioClipImport.pick(maxMegabytes: 3);
    } on AudioClipTooLarge {
      messenger.showSnackBar(
        SnackBar(content: Text(l.soundboardShareTooLarge)),
      );
      return;
    }
    if (clips.isEmpty || !mounted) return;
    final clip = clips.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.soundboardShareConfirmTitle),
        content: Text('${clip.name}\n\n${l.soundboardShareConfirmBody}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.soundboardShareTrack),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.share.suggest(
        clip.name,
        clip.bytes,
        confirmed: true,
        mime: clip.mimeType,
      );
    } on SoundShareTooLarge {
      messenger.showSnackBar(
        SnackBar(content: Text(l.soundboardShareTooLarge)),
      );
    }
  }

  Future<void> _toggle(SharedTrack track) async {
    if (_playing == track.clip) {
      await widget.output.stop(track.blobId);
      setState(() => _playing = null);
      return;
    }
    final blob = await widget.blobs.get(track.blobId);
    if (blob == null) return;
    if (_playing != null) await widget.output.stop('shared:$_playing');
    await widget.output.play(
      track.blobId,
      blob.bytes,
      blob.mimeType,
      volume: widget.set?.playlistVolume ?? 1,
    );
    if (mounted) setState(() => _playing = track.clip);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: widget.share,
      builder: (context, _) {
        final share = widget.share;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.soundboardShared,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _suggest,
                  icon: const DeckIcon(Icons.cloud_upload_outlined),
                  label: Text(l.soundboardShareTrack),
                ),
              ],
            ),
            if (share.isHost)
              for (final offer in share.pending)
                ListTile(
                  dense: true,
                  leading: const DeckIcon(Icons.hourglass_top),
                  title: Text(offer.name),
                  subtitle: Text(l.soundboardSharePending),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: l.soundboardShareAccept,
                        onPressed: () => share.accept(offer.clip),
                        icon: const DeckIcon(Icons.check),
                      ),
                      IconButton(
                        tooltip: l.soundboardShareReject,
                        onPressed: () => share.reject(offer.clip),
                        icon: const DeckIcon(Icons.close),
                      ),
                    ],
                  ),
                ),
            for (final entry in share.progress.entries)
              ListTile(
                dense: true,
                title: Text(l.soundboardShareReceiving),
                subtitle: LinearProgressIndicator(value: entry.value),
              ),
            if (share.tracks.isEmpty && share.progress.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Text(l.soundboardSharedEmpty),
              ),
            for (final track in share.tracks)
              ListTile(
                dense: true,
                leading: IconButton(
                  tooltip: l.soundboardPlay,
                  onPressed: () => _toggle(track),
                  icon: DeckIcon(
                    _playing == track.clip ? Icons.stop : Icons.play_arrow,
                  ),
                ),
                title: Text(track.name),
                trailing: widget.set == null
                    ? null
                    : IconButton(
                        tooltip: l.soundboardSaveToSet,
                        onPressed: () =>
                            share.save(widget.sets, widget.set!.id, track),
                        icon: const DeckIcon(Icons.bookmark_add_outlined),
                      ),
              ),
          ],
        );
      },
    );
  }
}
