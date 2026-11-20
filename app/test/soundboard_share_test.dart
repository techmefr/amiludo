import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_share_protocol.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_share.dart';

import 'soundboard_helpers.dart';

class _Wire implements SoundShareTransport {
  _Wire(this.hub, this.id);
  final _Hub hub;
  final String id;
  final incomingController = StreamController<ShareIncoming>.broadcast(
    sync: true,
  );

  @override
  Stream<ShareIncoming> get incoming => incomingController.stream;

  @override
  void sendToHost(Map<String, Object?> message) {
    hub.log.add(message);
    hub.wires['host']!.incomingController.add(
      ShareIncoming(
        id,
        jsonDecode(jsonEncode(message)) as Map<String, dynamic>,
      ),
    );
  }

  @override
  void broadcast(Map<String, Object?> message) {
    hub.log.add(message);
    for (final wire in hub.wires.values) {
      if (wire.id == 'host') continue;
      wire.incomingController.add(
        ShareIncoming(
          'host',
          jsonDecode(jsonEncode(message)) as Map<String, dynamic>,
        ),
      );
    }
  }
}

class _Hub {
  final Map<String, _Wire> wires = {};
  final List<Map<String, Object?>> log = [];
  _Wire wire(String id) => wires[id] = _Wire(this, id);
}

Uint8List _audio(int length) =>
    Uint8List.fromList(List.generate(length, (i) => i % 251));

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  late _Hub hub;
  late SoundRig hostRig, aliceRig, bobRig;
  late SoundShare host, alice, bob;

  SoundShare build(_Hub hub, String id, SoundRig rig, {bool isHost = false}) =>
      SoundShare(
        hub.wire(id),
        rig.blobs,
        selfId: id,
        isHost: isHost,
        wait: (_) async {},
      );

  setUp(() {
    hub = _Hub();
    hostRig = SoundRig();
    aliceRig = SoundRig();
    bobRig = SoundRig();
    host = build(hub, 'host', hostRig, isHost: true);
    alice = build(hub, 'alice', aliceRig);
    bob = build(hub, 'bob', bobRig);
  });

  tearDown(() {
    host.dispose();
    alice.dispose();
    bob.dispose();
  });

  test('a suggestion needs the sender confirmation', () async {
    expect(
      () => alice.suggest('Theme', _audio(10), confirmed: false),
      throwsA(isA<SoundShareNotConfirmed>()),
    );
  });

  test('a clip over the size cap is refused before anything is sent', () async {
    expect(
      () => alice.suggest('Big', _audio(maxSharedBytes + 1), confirmed: true),
      throwsA(isA<SoundShareTooLarge>()),
    );
    expect(hub.log, isEmpty);
  });

  test(
    'a suggestion reaches the host and no audio moves before acceptance',
    () async {
      await alice.suggest('Theme', _audio(100000), confirmed: true);
      await _settle();
      expect(host.pending.single.name, 'Theme');
      expect(hub.log.where((m) => m['k'] == 'chunk'), isEmpty);
      expect(bob.tracks, isEmpty);
    },
  );

  test('an accepted track reaches every device with identical audio', () async {
    final audio = _audio(100000);
    final clip = await alice.suggest('Theme', audio, confirmed: true);
    await _settle();
    await host.accept(clip);
    await _settle();
    for (final who in [host, alice, bob]) {
      expect(who.tracks.single.name, 'Theme', reason: who.selfId);
    }
    final fromBob = await bobRig.blobs.get(sharedBlobId(clip));
    expect(fromBob!.bytes, audio);
    final fromHost = await hostRig.blobs.get(sharedBlobId(clip));
    expect(fromHost!.bytes, audio);
  });

  test('a host track is shared without a suggestion round trip', () async {
    final audio = _audio(50000);
    final clip = await host.suggest('Boss', audio, confirmed: true);
    expect(host.pending.single.clip, clip);
    await host.accept(clip);
    await _settle();
    expect((await aliceRig.blobs.get(sharedBlobId(clip)))!.bytes, audio);
  });

  test('a rejected suggestion never transfers audio', () async {
    final clip = await alice.suggest('Nope', _audio(30000), confirmed: true);
    await _settle();
    host.reject(clip);
    await _settle();
    expect(host.pending, isEmpty);
    expect(hub.log.where((m) => m['k'] == 'chunk'), isEmpty);
    expect(bob.tracks, isEmpty);
  });

  test('a player cannot push chunks for someone else clip', () async {
    final clip = await alice.suggest('Theme', _audio(60000), confirmed: true);
    await _settle();
    await host.accept(clip);
    await _settle();
    final before = host.tracks.length;
    hub.wires['host']!.incomingController.add(
      ShareIncoming(
        'bob',
        shareMessage('chunk', {'clip': clip, 'i': 0, 'd': 'AAAA'}),
      ),
    );
    await _settle();
    expect(host.tracks.length, before);
  });

  test('a corrupted chunk is dropped and the clip stays incomplete', () async {
    final clip = await alice.suggest('Theme', _audio(60000), confirmed: true);
    await _settle();
    hub.wires['host']!.incomingController.add(
      ShareIncoming(
        'alice',
        shareMessage('chunk', {'clip': clip, 'i': 0, 'd': '!!!'}),
      ),
    );
    await _settle();
    expect(host.tracks, isEmpty);
  });

  test('at most five pending suggestions per player', () async {
    for (var i = 0; i < 7; i++) {
      await alice.suggest('T$i', _audio(10), confirmed: true);
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    await _settle();
    expect(host.pending, hasLength(maxPendingPerPlayer));
  });

  test('offers with bad ids, names or sizes are ignored by the host', () async {
    final wire = hub.wires['host']!;
    for (final bad in [
      {'clip': 'a b', 'name': 'x', 'size': 10},
      {'clip': 'ok', 'name': '', 'size': 10},
      {'clip': 'ok2', 'name': 'x', 'size': maxSharedBytes + 1},
      {'clip': 'ok3', 'name': 'x', 'size': -1},
      {'clip': 'ok4', 'name': 'x' * 200, 'size': 10},
    ]) {
      wire.incomingController.add(
        ShareIncoming('alice', shareMessage('suggest', bad)),
      );
    }
    await _settle();
    expect(host.pending, isEmpty);
  });

  test('received audio is session only and can be saved to a set', () async {
    final clip = await alice.suggest('Theme', _audio(30000), confirmed: true);
    await _settle();
    await host.accept(clip);
    await _settle();
    await bobRig.newSet();
    await bob.save(bobRig.sets, bobRig.set.id, bob.tracks.single);
    expect(bobRig.set.entries.single.kind, SoundKind.track);
    await bob.purgeSession();
    expect(bob.tracks, isEmpty);
    expect(await bobRig.blobs.exists(sharedBlobId(clip)), isFalse);
    expect(await bobRig.blobs.exists(bobRig.set.entries.single.id), isTrue);
  });

  test('cancel by the owner drops the clip everywhere', () async {
    final clip = await alice.suggest('Theme', _audio(30000), confirmed: true);
    await _settle();
    await alice.cancel(clip);
    await _settle();
    expect(host.pending, isEmpty);
  });

  test('assembler rejects wrong size and duplicate chunks', () {
    final offer = ShareOffer(
      clip: 'c',
      name: 'n',
      size: shareChunkBytes + 10,
      from: 'a',
    );
    final assembler = ClipAssembler(offer);
    final first = base64Encode(_audio(shareChunkBytes));
    expect(assembler.add(0, first), isTrue);
    expect(assembler.add(0, first), isFalse);
    expect(assembler.add(1, base64Encode(_audio(9))), isFalse);
    expect(assembler.add(5, first), isFalse);
    expect(assembler.add(1, base64Encode(_audio(10))), isTrue);
    expect(assembler.complete, isTrue);
    expect(assembler.assemble(), hasLength(shareChunkBytes + 10));
  });
}
