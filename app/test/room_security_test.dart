import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Lobby/data/gateways/lobby_gateway_impl.dart';
import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/technical/Network/lan_room_io.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/technical/Network/room_seal.dart';

import 'network_fakes.dart';

void main() {
  _sealTests();
  _hostTests();
  _seatTests();
  _lanTests();
}

class _Room {
  _Room(this.network, this.host, this.guest, this.rogue, this.heard);

  final FakeRoomNetwork network;
  final LobbyGatewayImpl host, guest;
  final RoomChannel rogue;
  final List<RoomMessage> heard;

  String get code => host.current!.lobby.code;

  static Future<_Room> open({bool withSecret = true}) async {
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
    final link = withSecret ? hosting.link : hosting.lobby.link;
    await guest.join(link, const LobbySeat(id: 'g', name: 'Léa'));
    await pumpEventQueue();
    return _Room(network, host, guest, rogue, heard);
  }

  Future<void> inject(RoomMessage message) async {
    rogue.send(message);
    await pumpEventQueue();
  }

  Map<String, Object?> lobbyWith(SeatStatus status) => host.current!.lobby
      .decide('g', accept: status == SeatStatus.accepted)
      .toJson();
}

void _sealTests() {
  test('the host secret travels in the link and only there', () {
    final secret = newRoomSecret();
    expect(isRoomSecret(secret), isTrue);
    final link = RoomLink(
      RoomKind.join,
      'ABC234',
      lan: '192.168.1.20:4321',
      secret: secret,
    );
    expect(RoomLink.parse(link.appUri.toString())!.secret, secret);
    expect(link.route, contains('k=$secret'));
    expect(
      RoomLink.parse('amiludo://amiludo.app/join/ABC234?k=nope')!.secret,
      isNull,
    );
    expect(RoomLink.parse('ABC234')!.secret, isNull);
    final lobby = const Lobby(
      title: 'Skull',
      hostName: 'Camille',
    ).copyWith(code: 'ABC234');
    final session = LobbySession(lobby, secret: secret);
    expect(session.link.secret, secret);
    expect(jsonEncode(lobby.toJson()), isNot(contains(secret)));
  });

  test('a seal only verifies with the same secret', () {
    final seal = RoomSeal(newRoomSecret());
    final signature = seal.sign('ABC234|state|1|{}');
    expect(seal.verify('ABC234|state|1|{}', signature), isTrue);
    expect(seal.verify('ABC234|state|2|{}', signature), isFalse);
    expect(
      RoomSeal(newRoomSecret()).verify('ABC234|state|1|{}', signature),
      isFalse,
    );
    expect(roomFingerprint('ABC234'), isNot(contains('ABC234')));
    expect(isRoomProof(roomProof(newRoomSecret())), isTrue);
  });
}

void _hostTests() {
  test('the host publishes every state with a signature', () async {
    final room = await _Room.open();
    final state = room.heard.lastWhere((m) => m['type'] == 'state');
    expect(state['sig'], hasLength(64));
    expect(state['n'], isA<int>());
    expect(room.heard.any((m) => m.containsKey('lobby')), isFalse);
  });

  test('a peer without the secret cannot close the room', () async {
    final room = await _Room.open();
    await room.inject({'type': 'closed'});
    await room.inject({
      'type': 'closed',
      'n': 999,
      'body': '',
      'sig': 'f' * 64,
    });
    await room.inject({'type': 'disconnected'});
    expect(room.guest.current!.ended, isFalse);
    await room.host.leave();
    await pumpEventQueue();
    expect(room.guest.current!.ended, isTrue);
  });

  test('a peer without the secret cannot impersonate the host', () async {
    final room = await _Room.open();
    final refused = room.lobbyWith(SeatStatus.refused);
    await room.inject({'type': 'state', 'lobby': refused});
    await room.inject({
      'type': 'state',
      'n': 999,
      'body': jsonEncode(refused),
      'sig': RoomSeal(newRoomSecret()).sign('${room.code}|state|999|x'),
    });
    expect(room.guest.current!.myStatus, SeatStatus.pending);
    room.host.publish(room.host.current!.lobby.decide('g', accept: true));
    await pumpEventQueue();
    expect(room.guest.current!.myStatus, SeatStatus.accepted);
  });

  test('a peer cannot replay an older signed state', () async {
    final room = await _Room.open();
    final pending = room.heard.lastWhere((m) => m['type'] == 'state');
    room.host.publish(room.host.current!.lobby.decide('g', accept: true));
    await pumpEventQueue();
    await room.inject(pending);
    expect(room.guest.current!.myStatus, SeatStatus.accepted);
  });

  test('a guest joining with the bare code still works', () async {
    final room = await _Room.open(withSecret: false);
    expect(room.guest.current!.myStatus, SeatStatus.pending);
    room.host.publish(room.host.current!.lobby.decide('g', accept: true));
    await pumpEventQueue();
    expect(room.guest.current!.myStatus, SeatStatus.accepted);
  });
}

void _seatTests() {
  test('a peer cannot eject someone else', () async {
    final room = await _Room.open();
    await room.inject({'type': 'leave', 'id': 'g'});
    await room.inject({'type': 'leave', 'id': 'g', 'key': newRoomSecret()});
    await room.inject({'type': 'disconnected', '_peer': 'peer0'});
    expect(room.host.current!.lobby.seat('g')!.status, SeatStatus.pending);
  });

  test('a peer cannot take over a seat to eject it', () async {
    final room = await _Room.open();
    final key = newRoomSecret();
    await room.inject({
      'type': 'join',
      'seat': const LobbySeat(id: 'g', name: 'Mallory').toJson(),
      'proof': roomProof(key),
    });
    await room.inject({'type': 'leave', 'id': 'g', 'key': key});
    final seat = room.host.current!.lobby.seat('g')!;
    expect(seat.status, SeatStatus.pending);
    expect(seat.name, 'Léa');
  });

  test('joins without a proof are ignored', () async {
    final room = await _Room.open();
    await room.inject({
      'type': 'join',
      'seat': const LobbySeat(id: 'm', name: 'Mallory').toJson(),
    });
    expect(room.host.current!.lobby.seat('m'), isNull);
  });

  test('a guest can still leave its own seat', () async {
    final room = await _Room.open();
    await room.guest.leave();
    await pumpEventQueue();
    expect(room.host.current!.lobby.seat('g')!.status, SeatStatus.left);
  });
}

void _lanTests() {
  test('the Wi-Fi host proves it knows the secret', () async {
    final secret = newRoomSecret();
    final room = await LanHostedRoom.open('ABC234', secret: secret);
    final port = room.address.split(':').last;
    final client = await LanClientRoom.connect(
      '127.0.0.1:$port',
      'ABC234',
      secret: secret,
    );
    final fromHost = client.messages.first;
    room.send({'type': 'state'});
    expect((await fromHost)['type'], 'state');
    await client.close();
    await expectLater(
      LanClientRoom.connect(
        '127.0.0.1:$port',
        'ABC234',
        secret: newRoomSecret(),
      ),
      throwsA(isA<RoomHostUnverified>()),
    );
    await room.close();
  });

  test('a Wi-Fi peer cannot forge local events', () async {
    final room = await LanHostedRoom.open('ABC234');
    final port = room.address.split(':').last;
    final client = await LanClientRoom.connect('127.0.0.1:$port', 'ABC234');
    final fromClient = room.messages.first;
    client.send({'type': 'disconnected', '_local': true, '_peer': 'peer9'});
    final message = await fromClient;
    expect(message['_local'], isNull);
    expect(message['_peer'], 'peer0');
    await client.close();
    await room.close();
  });

  test('Wi-Fi discovery only trusts a host holding the secret', () async {
    final secret = newRoomSecret();
    final room = await LanHostedRoom.open('ABC234', secret: secret);
    final port = room.address.split(':').last;
    expect(await discoverLanRoom('ABC234', secret: secret), endsWith(':$port'));
    expect(
      await discoverLanRoom(
        'ABC234',
        secret: newRoomSecret(),
        wait: const Duration(milliseconds: 500),
      ),
      isNull,
    );
    await room.close();
  });
}
