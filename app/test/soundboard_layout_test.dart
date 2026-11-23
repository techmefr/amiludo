import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_share.dart';
import 'package:amiludo/layers/functional/Sounds/presentation/soundboard_tool.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';

import 'soundboard_helpers.dart';

const sizes = [
  Size(390, 844),
  Size(844, 390),
  Size(1280, 720),
  Size(1920, 1080),
];

void main() {
  for (final size in sizes) {
    testWidgets('soundboard fits ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final rig = SoundRig();
      final output = RecordingClipOutput();
      await tester.runAsync(() async {
        await rig.sets.create(
          SoundOwnerKind.companion,
          defaultSoundOwnerId,
          'Dragons',
        );
        final track = await rig.add('Theme', SoundKind.track);
        await rig.sets.addToPlaylist(rig.set.id, track.id);
        for (var i = 0; i < 12; i++) {
          final fx = await rig.add(
            'Long effect name number $i',
            SoundKind.effect,
          );
          await rig.sets.addToSoundboard(rig.set.id, fx.id);
        }
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SoundboardTool(
                sets: rig.sets,
                library: rig.library,
                engine: PlaylistEngine(output, rig.blobs, wait: (_) async {}),
                pads: PadPlayer(output, rig.blobs),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Dragons'), findsWidgets);
      expect(find.text('Long effect name number 0'), findsOneWidget);
    });
  }

  testWidgets('tapping a pad plays it', (tester) async {
    final rig = SoundRig();
    final output = RecordingClipOutput();
    late String fxId;
    await tester.runAsync(() async {
      await rig.sets.create(
        SoundOwnerKind.companion,
        defaultSoundOwnerId,
        'Dragons',
      );
      final fx = await rig.add('Boom', SoundKind.effect);
      fxId = fx.id;
      await rig.sets.addToSoundboard(rig.set.id, fx.id);
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoundboardTool(
              sets: rig.sets,
              library: rig.library,
              engine: PlaylistEngine(output, rig.blobs, wait: (_) async {}),
              pads: PadPlayer(output, rig.blobs),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text('Boom'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    expect(output.started, ['pad:$fxId']);
  });

  testWidgets('the shared tracks panel shows pending offers to the host', (
    tester,
  ) async {
    final rig = SoundRig();
    final output = RecordingClipOutput();
    final wire = _SilentTransport();
    final share = SoundShare(
      wire,
      rig.blobs,
      selfId: 'host',
      isHost: true,
      wait: (_) async {},
    );
    await tester.runAsync(() async {
      await rig.sets.create(
        SoundOwnerKind.companion,
        defaultSoundOwnerId,
        'Dragons',
      );
      await share.suggest(
        'Tavern song',
        Uint8List.fromList([1, 2, 3]),
        confirmed: true,
      );
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SoundboardTool(
              sets: rig.sets,
              library: rig.library,
              engine: PlaylistEngine(output, rig.blobs, wait: (_) async {}),
              pads: PadPlayer(output, rig.blobs),
              share: share,
              blobs: rig.blobs,
              output: output,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Shared tracks'), findsOneWidget);
    expect(find.text('Tavern song'), findsOneWidget);
    expect(find.byTooltip('Accept'), findsOneWidget);
  });
}

class _SilentTransport implements SoundShareTransport {
  @override
  Stream<ShareIncoming> get incoming => const Stream.empty();

  @override
  void sendToHost(Map<String, Object?> message) {}

  @override
  void broadcast(Map<String, Object?> message) {}
}
