import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Lobby/data/gateways/lobby_gateway_impl.dart';
import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_share.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';
import 'package:amiludo/lobby_sound_transport.dart';

import 'network_fakes.dart';
import 'soundboard_helpers.dart';

Uint8List _audio(int length) =>
    Uint8List.fromList(List.generate(length, (i) => (i * 7) % 253));

class _Table {
  _Table(
    this.host,
    this.guest,
    this.rogue,
    this.heard,
    this.hostShare,
    this.guestShare,
    this.hostRig,
    this.guestRig,
  );

  final LobbyGatewayImpl host, guest;
  final RoomChannel rogue;
  final List<RoomMessage> heard;
  final SoundShare hostShare, guestShare;
  final SoundRig hostRig, guestRig;

  static Future<_Table> open({bool secret = true, bool accept = true}) async {
    final network = FakeRoomNetwork();
    final host = LobbyGatewayImpl(network);
    final guest = LobbyGatewayImpl(network);
    final hosting = await host.host(
      const Lobby(title: 'Skull', hostName: 'Camille'),
      lan: true,
      remote: false,
    );
    final rogue = await network.joinLan('10.0.0.2:4000', hosting.lobby.code);
    final heard = <RoomMessage>[];
    rogue.messages.listen(heard.add);
    await guest.join(
      secret ? hosting.link : hosting.lobby.link,
      const LobbySeat(id: 'g', name: 'Léa'),
    );
    await pumpEventQueue();
    if (accept) {
      host.publish(host.current!.lobby.decide('g', accept: true));
      await pumpEventQueue();
    }
    final hostRig = SoundRig();
    final guestRig = SoundRig();
    SoundShare share(
      LobbyGatewayImpl gateway,
      SoundRig rig,
      String id,
      bool isHost,
    ) => SoundShare(
      LobbySoundTransport(gateway),
      rig.blobs,
      selfId: id,
      isHost: isHost,
      wait: (_) async {},
    );
    return _Table(
      host,
      guest,
      rogue,
      heard,
      share(host, hostRig, 'host', true),
      share(guest, guestRig, 'g', false),
      hostRig,
      guestRig,
    );
  }

  Future<void> close() async {
    hostShare.dispose();
    guestShare.dispose();
    await guest.leave();
    await host.leave();
  }
}

void main() {
  late _Table table;

  tearDown(() => table.close());

  test('a guest track reaches the host through the sealed room', () async {
    table = await _Table.open();
    final audio = _audio(70000);
    final clip = await table.guestShare.suggest(
      'Theme',
      audio,
      confirmed: true,
    );
    await pumpEventQueue();
    expect(table.hostShare.pending.single.name, 'Theme');
    await table.hostShare.accept(clip);
    await pumpEventQueue(times: 400);
    expect(table.hostShare.tracks.single.name, 'Theme');
    expect(table.guestShare.tracks.single.name, 'Theme');
    final onHost = await table.hostRig.blobs.get(sharedBlobId(clip));
    expect(onHost!.bytes, audio);
  });

  test('a host track reaches the guest', () async {
    table = await _Table.open();
    final audio = _audio(40000);
    final clip = await table.hostShare.suggest('Boss', audio, confirmed: true);
    await table.hostShare.accept(clip);
    await pumpEventQueue(times: 400);
    final onGuest = await table.guestRig.blobs.get(sharedBlobId(clip));
    expect(onGuest!.bytes, audio);
  });

  test('every app message carries a signature and a counter', () async {
    table = await _Table.open();
    final clip = await table.hostShare.suggest(
      'Boss',
      _audio(30000),
      confirmed: true,
    );
    await table.hostShare.accept(clip);
    await pumpEventQueue(times: 400);
    final app = table.heard.where((m) => m['type'] == 'app');
    expect(app, isNotEmpty);
    for (final message in app) {
      expect(message['sig'], isA<String>());
      expect(message['n'], isA<int>());
    }
  });

  test(
    'a rogue peer without the secret cannot inject into the guest',
    () async {
      table = await _Table.open();
      table.rogue.send({
        'type': 'app',
        'n': 999,
        'body': jsonEncode({
          'topic': 'snd',
          'body': {
            't': 'snd',
            'k': 'accept',
            'clip': 'evil',
            'name': 'Evil',
            'size': 10,
            'from': 'host',
          },
        }),
        'sig': 'f' * 64,
      });
      await pumpEventQueue();
      expect(table.guestShare.progress, isEmpty);
      expect(table.guestShare.tracks, isEmpty);
    },
  );

  test('a rogue peer cannot speak as a guest to the host', () async {
    table = await _Table.open();
    table.rogue.send({
      'type': 'app',
      'id': 'g',
      'n': 1,
      'body': jsonEncode({
        'topic': 'snd',
        'body': {
          't': 'snd',
          'k': 'suggest',
          'clip': 'evil',
          'name': 'Evil',
          'size': 10,
        },
      }),
      'sig': 'a' * 64,
    });
    await pumpEventQueue();
    expect(table.hostShare.pending, isEmpty);
  });

  test('a replayed guest message is ignored by the host', () async {
    table = await _Table.open();
    await table.guestShare.suggest('Theme', _audio(1000), confirmed: true);
    await pumpEventQueue();
    expect(table.hostShare.pending, hasLength(1));
    final sealed = table.heard.firstWhere(
      (m) => m['type'] == 'app' && m['id'] == 'g',
    );
    table.hostShare.reject(table.hostShare.pending.single.clip);
    await pumpEventQueue();
    table.rogue.send(Map<String, dynamic>.of(sealed));
    await pumpEventQueue();
    expect(table.hostShare.pending, isEmpty);
  });

  test('a guest whose seat is not accepted cannot send', () async {
    table = await _Table.open(accept: false);
    expect(table.guest.canSendApp, isFalse);
    await table.guestShare.suggest('Theme', _audio(1000), confirmed: true);
    await pumpEventQueue();
    expect(table.hostShare.pending, isEmpty);
  });

  test('a link without the room secret cannot carry audio', () async {
    table = await _Table.open(secret: false);
    expect(table.guest.canSendApp, isFalse);
    expect(table.host.canSendApp, isTrue);
    final clip = await table.hostShare.suggest(
      'Boss',
      _audio(2000),
      confirmed: true,
    );
    await table.hostShare.accept(clip);
    await pumpEventQueue(times: 200);
    expect(table.guestShare.tracks, isEmpty);
  });
}
