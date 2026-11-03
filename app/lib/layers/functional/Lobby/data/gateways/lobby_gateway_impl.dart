import 'dart:async';

import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';

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
  LobbySession? _current;

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

  @override
  Future<LobbySession> host(
    Lobby draft, {
    required bool lan,
    required bool remote,
  }) async {
    await leave();
    final code = newRoomCode(6);
    String? address;
    if (lan && lanSupported) {
      final room = await _network.hostLan(code);
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
      LobbySession(draft.copyWith(code: code, lan: address, remote: online)),
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
        try {
          final seat = LobbySeat.fromJson(
            Map<String, dynamic>.from(message['seat'] as Map),
          );
          if (peer != null) _peers[peer] = seat.id;
          publish(lobby.withRequest(seat));
        } on Object {
          return;
        }
      case 'leave':
        publish(lobby.without(message['id'] as String? ?? ''));
      case 'disconnected':
        final id = _peers.remove(peer);
        if (id != null) publish(lobby.without(id));
    }
  }

  @override
  void publish(Lobby lobby) {
    final session = _current;
    if (session == null || !session.isHost) return;
    _set(LobbySession(lobby));
    _broadcast({'type': 'state', 'lobby': lobby.toJson()});
  }

  void _broadcast(RoomMessage message) {
    for (final channel in _channels) {
      channel.send(message);
    }
  }

  @override
  Future<LobbySession> join(RoomLink link, LobbySeat me) async {
    await leave();
    final channel = await _connect(link);
    _channels.add(channel);
    final answered = Completer<LobbySession>();
    _subscriptions.add(
      channel.messages.listen(
        (m) => _guestReceive(m, link.code, me.id, answered),
      ),
    );
    final ask = {'type': 'join', 'seat': me.toJson()};
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
    try {
      if (link.lan != null && lanSupported) {
        return await _network.joinLan(link.lan!, link.code);
      }
      if (lanSupported) {
        final address = await _network.discoverLan(link.code);
        if (address != null) return await _network.joinLan(address, link.code);
      }
    } on Object {
      if (!remoteSupported) throw const LobbyUnreachable();
    }
    if (remoteSupported) return _network.remote(link.code);
    throw const LobbyNotFound();
  }

  void _guestReceive(
    RoomMessage message,
    String code,
    String me,
    Completer<LobbySession> answered,
  ) {
    switch (message['type']) {
      case 'state':
        try {
          final lobby = Lobby.fromJson(
            Map<String, dynamic>.from(message['lobby'] as Map),
          );
          if (lobby.code != code || lobby.seat(me) == null) return;
          _set(LobbySession(lobby, me: me));
          if (!answered.isCompleted) answered.complete(_current);
        } on Object {
          return;
        }
      case 'closed' || 'disconnected':
        final session = _current;
        if (session != null && !session.isHost) {
          _set(LobbySession(session.lobby, me: me, ended: true));
        }
    }
  }

  @override
  Future<void> leave() async {
    final session = _current;
    if (session != null && !session.ended) {
      _broadcast(
        session.isHost
            ? {'type': 'closed'}
            : {'type': 'leave', 'id': session.me},
      );
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
    if (_current != null) _set(null);
  }
}
