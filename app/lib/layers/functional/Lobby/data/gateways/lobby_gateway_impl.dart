import 'dart:async';
import 'dart:convert';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';
import 'package:amiludo/layers/technical/Network/room_seal.dart';

class LobbyGatewayImpl implements LobbyGateway {
  LobbyGatewayImpl(
    this._network, {
    this.answerTimeout = const Duration(seconds: 8),
  });

  final RoomNetwork _network;
  final Duration answerTimeout;
  final _sessions = StreamController<LobbySession?>.broadcast();
  final _channels = <RoomChannel>[];
  final _subscriptions = <StreamSubscription<RoomMessage>>[];
  final _peers = <String, String>{};
  final _proofs = <String, String>{};
  LobbySession? _current;
  RoomSeal? _seal;
  String? _leaveKey;
  var _sequence = 0;

  @override
  bool get lanSupported => _network.lanSupported;

  @override
  bool get remoteSupported => _network.remoteSupported;

  @override
  LobbySession? get current => _current;

  @override
  Stream<LobbySession?> watch() => _sessions.stream;

  void _set(LobbySession? session) {
    _current = session;
    _sessions.add(session);
  }

  static String _signed(String code, String type, int n, String body) =>
      '$code|$type|$n|$body';

  @override
  Future<LobbySession> host(
    Lobby draft, {
    required bool lan,
    required bool remote,
  }) async {
    await leave();
    final code = newRoomCode(6);
    final secret = newRoomSecret();
    _seal = RoomSeal(secret);
    String? address;
    if (lan && lanSupported) {
      final room = await _network.hostLan(code, secret);
      address = room.address;
      _channels.add(room);
    }
    final online = remote && remoteSupported;
    if (online) _channels.add(await _network.remote(code));
    if (_channels.isEmpty) throw const LobbyUnreachable();
    for (final channel in _channels) {
      _subscriptions.add(channel.messages.listen(_hostReceive));
    }
    _set(
      LobbySession(
        draft.copyWith(code: code, lan: address, remote: online),
        secret: secret,
      ),
    );
    return _current!;
  }

  void _hostReceive(RoomMessage message) {
    final session = _current;
    if (session == null || !session.isHost) return;
    final lobby = session.lobby;
    final peer = message['_peer'] as String?;
    switch (message['type']) {
      case 'join':
        _hostJoin(lobby, message, peer);
      case 'leave':
        final id = message['id'] as String? ?? '';
        final key = message['key'];
        if (key is! String || !sameProof(_proofs[id], roomProof(key))) return;
        publish(lobby.without(id));
      case 'disconnected':
        if (message['_local'] != true) return;
        final id = _peers.remove(peer);
        if (id != null) publish(lobby.without(id));
    }
  }

  void _hostJoin(Lobby lobby, RoomMessage message, String? peer) {
    final LobbySeat seat;
    try {
      seat = LobbySeat.fromJson(
        Map<String, dynamic>.from(message['seat'] as Map),
      );
    } on Object {
      return;
    }
    final proof = message['proof'];
    if (!isRoomProof(proof)) return;
    final known = lobby.seat(seat.id);
    if (known == null || known.status == SeatStatus.left) {
      _proofs[seat.id] = proof as String;
    }
    if (!sameProof(_proofs[seat.id], proof)) return;
    if (peer != null) _peers[peer] = seat.id;
    publish(lobby.withRequest(seat));
  }

  @override
  void publish(Lobby lobby) {
    final session = _current;
    if (session == null || !session.isHost) return;
    _set(LobbySession(lobby, secret: session.secret));
    _broadcastSealed('state', jsonEncode(lobby.toJson()));
  }

  void _broadcastSealed(String type, String body) {
    final seal = _seal;
    final session = _current;
    if (seal == null || session == null) return;
    final n = ++_sequence;
    _broadcast({
      'type': type,
      'n': n,
      'body': body,
      'sig': seal.sign(_signed(session.lobby.code, type, n, body)),
    });
  }

  void _broadcast(RoomMessage message) {
    for (final channel in _channels) {
      channel.send(message);
    }
  }

  @override
  Future<LobbySession> join(RoomLink link, LobbySeat me) async {
    await leave();
    final secret = link.secret;
    _seal = secret == null ? null : RoomSeal(secret);
    final key = newRoomSecret();
    _leaveKey = key;
    final channel = await _connect(link);
    _channels.add(channel);
    final answered = Completer<LobbySession>();
    _subscriptions.add(
      channel.messages.listen(
        (m) => _guestReceive(m, link.code, me.id, answered),
      ),
    );
    final ask = {'type': 'join', 'seat': me.toJson(), 'proof': roomProof(key)};
    channel.send(ask);
    final retry = Timer.periodic(
      const Duration(seconds: 2),
      (_) => channel.send(ask),
    );
    try {
      return await answered.future.timeout(answerTimeout);
    } on TimeoutException {
      await leave();
      throw const LobbyNotFound();
    } finally {
      retry.cancel();
    }
  }

  Future<RoomChannel> _connect(RoomLink link) async {
    final secret = link.secret;
    try {
      if (link.lan != null && lanSupported) {
        return await _network.joinLan(link.lan!, link.code, secret: secret);
      }
      if (lanSupported) {
        final address = await _network.discoverLan(link.code, secret: secret);
        if (address != null) {
          return await _network.joinLan(address, link.code, secret: secret);
        }
      }
    } on Object {
      if (!remoteSupported) throw const LobbyUnreachable();
    }
    if (remoteSupported) return _network.remote(link.code);
    throw const LobbyNotFound();
  }

  String? _opened(RoomMessage message, String code, String type) {
    final n = message['n'];
    final body = message['body'];
    if (n is! int || body is! String) return null;
    final seal = _seal;
    if (seal == null) return body;
    if (n <= _sequence) return null;
    if (!seal.verify(_signed(code, type, n, body), message['sig'])) {
      return null;
    }
    _sequence = n;
    return body;
  }

  void _guestReceive(
    RoomMessage message,
    String code,
    String me,
    Completer<LobbySession> answered,
  ) {
    switch (message['type']) {
      case 'state':
        final body = _opened(message, code, 'state');
        if (body == null) return;
        try {
          final lobby = Lobby.fromJson(
            Map<String, dynamic>.from(jsonDecode(body) as Map),
          );
          if (lobby.code != code || lobby.seat(me) == null) return;
          _set(LobbySession(lobby, me: me));
          if (!answered.isCompleted) answered.complete(_current);
        } on Object {
          return;
        }
      case 'closed':
        if (_opened(message, code, 'closed') != null) _end(me);
      case 'disconnected':
        if (message['_local'] == true) _end(me);
    }
  }

  void _end(String me) {
    final session = _current;
    if (session != null && !session.isHost) {
      _set(LobbySession(session.lobby, me: me, ended: true));
    }
  }

  @override
  Future<void> leave() async {
    final session = _current;
    if (session != null && !session.ended) {
      if (session.isHost) {
        _broadcastSealed('closed', '');
      } else {
        _broadcast({'type': 'leave', 'id': session.me, 'key': _leaveKey});
      }
    }
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    for (final channel in _channels) {
      await channel.close();
    }
    _subscriptions.clear();
    _channels.clear();
    _peers.clear();
    _proofs.clear();
    _seal = null;
    _leaveKey = null;
    _sequence = 0;
    if (_current != null) _set(null);
  }
}
