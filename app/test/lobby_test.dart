import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Lobby/data/gateways/lobby_gateway_impl.dart';
import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/decide_seat_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/host_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/join_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/start_lobby_game_use_case.dart';
import 'package:amiludo/layers/technical/Network/lan_room_io.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';

import 'fakes.dart';
import 'network_fakes.dart';

void main() {
  _linkTests();
  _lobbyRuleTests();
  _protocolTests();
  _lanTests();
}

void _linkTests() {
  test('room codes avoid ambiguous letters and parse from links', () {
    final code = newRoomCode(6);
    expect(code, hasLength(6));
    expect(code, isNot(matches('[IL0O1]')));
    expect(normalizeRoomCode('abc-234'), 'ABC234');
    expect(normalizeRoomCode('ABC1O4'), isNull);
    final link = RoomLink(RoomKind.join, 'ABC234', lan: '192.168.1.20:4321');
    final parsed = RoomLink.parse(link.appUri.toString())!;
    expect(parsed.kind, RoomKind.join);
    expect(parsed.code, 'ABC234');
    expect(parsed.lan, '192.168.1.20:4321');
    expect(
      RoomLink.parse('https://amiludo.app/evening/ABCDEFGH')?.kind,
      RoomKind.evening,
    );
    expect(RoomLink.parse('ABCD EFGH')?.kind, RoomKind.evening);
    expect(
      RoomLink.parse('amiludo://amiludo.app/join/ABC234?lan=evil')?.lan,
      isNull,
    );
    expect(RoomLink.parse('nope'), isNull);
  });
}

void _lobbyRuleTests() {
  test('seats fill up, refused players stay out and leavers free a seat', () {
    var lobby = const Lobby(title: 'Skull', hostName: 'Camille', seats: 2);
    lobby = lobby
        .withRequest(const LobbySeat(id: 'a', name: 'Léa'))
        .withRequest(const LobbySeat(id: 'b', name: 'Sam'))
        .decide('a', accept: true)
        .decide('b', accept: true);
    expect(lobby.playerNames, ['Camille', 'Léa']);
    expect(lobby.seat('b')!.status, SeatStatus.pending);
    lobby = lobby.without('a').decide('b', accept: true);
    expect(lobby.playerNames, ['Camille', 'Sam']);
    lobby = lobby.decide('b', accept: false);
    expect(
      lobby
          .withRequest(const LobbySeat(id: 'b', name: 'Sam'))
          .seat('b')!
          .status,
      SeatStatus.refused,
    );
    final closed = lobby
        .copyWith(open: false)
        .withRequest(const LobbySeat(id: 'c', name: 'Alex'));
    expect(closed.seat('c')!.status, SeatStatus.refused);
    expect(Lobby.fromJson(lobby.toJson()).playerNames, lobby.playerNames);
  });
}

void _protocolTests() {
  test('a guest joins by code, is accepted and sees the start', () async {
    final network = FakeRoomNetwork();
    final host = LobbyGatewayImpl(network);
    final guest = LobbyGatewayImpl(network);
    final hosting = await HostLobbyUseCase(host, MemoryWorkspace())(
      title: 'Skull',
      name: 'Camille',
      seats: 4,
      lan: true,
      remote: false,
    );
    expect(hosting.lobby.lan, '10.0.0.2:4000');
    final guestSpace = MemoryWorkspace();
    final joined = await JoinLobbyUseCase(guest, guestSpace)(
      hosting.lobby.code.toLowerCase(),
      name: 'Léa',
    );
    expect(joined.myStatus, SeatStatus.pending);
    expect(guestSpace.current.nickname, 'Léa');
    DecideSeatUseCase(host)(joined.me!, accept: true);
    await pumpEventQueue();
    expect(guest.current!.myStatus, SeatStatus.accepted);
    expect(StartLobbyGameUseCase(host)(), ['Camille', 'Léa']);
    await pumpEventQueue();
    expect(guest.current!.lobby.started, isTrue);
    await host.leave();
    await pumpEventQueue();
    expect(guest.current!.ended, isTrue);
  });

  test('a leaving guest frees the seat and unknown codes fail fast', () async {
    final network = FakeRoomNetwork();
    final host = LobbyGatewayImpl(network);
    final guest = LobbyGatewayImpl(network);
    final hosting = await host.host(
      const Lobby(title: 'Skull', hostName: 'Camille'),
      lan: true,
      remote: false,
    );
    await guest.join(hosting.lobby.link, const LobbySeat(id: 'g', name: 'Léa'));
    await guest.leave();
    await pumpEventQueue();
    expect(host.current!.lobby.seat('g')!.status, SeatStatus.left);
    expect(
      () => guest.join(
        const RoomLink(RoomKind.join, 'ZZZZZZ'),
        const LobbySeat(id: 'g', name: 'Léa'),
      ),
      throwsA(isA<LobbyNotFound>()),
    );
    expect(
      () => LobbyGatewayImpl(FakeRoomNetwork(lanSupported: false)).host(
        const Lobby(title: 'Skull', hostName: 'Camille'),
        lan: true,
        remote: true,
      ),
      throwsA(isA<LobbyUnreachable>()),
    );
  });
}

void _lanTests() {
  test('the Wi-Fi room relays messages over real sockets', () async {
    final room = await LanHostedRoom.open('ABC234');
    final port = room.address.split(':').last;
    final client = await LanClientRoom.connect('127.0.0.1:$port', 'ABC234');
    final fromClient = room.messages.first;
    client.send({'type': 'join', 'seat': 'x'});
    expect((await fromClient)['type'], 'join');
    final fromHost = client.messages.first;
    room.send({'type': 'state'});
    expect((await fromHost)['type'], 'state');
    final left = room.messages.firstWhere((m) => m['type'] == 'disconnected');
    await client.close();
    expect((await left)['_peer'], isNotNull);
    await expectLater(
      LanClientRoom.connect('127.0.0.1:$port', 'WRONG2'),
      throwsA(anything),
    );
    await room.close();
  });
}
