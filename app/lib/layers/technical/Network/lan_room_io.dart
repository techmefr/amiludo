import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amiludo/layers/technical/Network/room_channel.dart';
import 'package:amiludo/layers/technical/Network/room_seal.dart';

const lanDiscoveryPort = 47474;
const _maxMessage = 64 * 1024;
const _maxPeers = 16;

RoomMessage? _decode(Object? data) {
  if (data is! String || data.length > _maxMessage) return null;
  try {
    final value = jsonDecode(data);
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value)
      ..removeWhere((key, _) => key.startsWith('_'));
  } on FormatException {
    return null;
  }
}

void _emit(StreamController<RoomMessage> messages, RoomMessage message) {
  if (!messages.isClosed) messages.add(message);
}

Future<String> _localAddress() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      final ip = address.address;
      if (ip.startsWith('192.168.') ||
          ip.startsWith('10.') ||
          RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(ip)) {
        return ip;
      }
    }
  }
  return InternetAddress.loopbackIPv4.address;
}

class LanHostedRoom implements HostedRoom {
  LanHostedRoom._(
    this._server,
    this._discovery,
    this.address,
    this.code,
    this._seal,
  ) : _room = roomFingerprint(code) {
    _server.listen(_accept);
    _discovery?.listen(_answer);
  }

  final HttpServer _server;
  final RawDatagramSocket? _discovery;
  final RoomSeal _seal;
  final String _room;
  final String code;
  @override
  final String address;
  final _peers = <String, WebSocket>{};
  final _messages = StreamController<RoomMessage>.broadcast();
  var _next = 0;

  static Future<LanHostedRoom> open(String code, {String? secret}) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    RawDatagramSocket? discovery;
    try {
      discovery = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        lanDiscoveryPort,
        reuseAddress: true,
      );
    } on SocketException {
      discovery = null;
    }
    final ip = await _localAddress();
    final seal = RoomSeal(secret ?? newRoomSecret());
    return LanHostedRoom._(server, discovery, '$ip:${server.port}', code, seal);
  }

  void _answer(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _discovery?.receive();
    if (datagram == null) return;
    final ask = utf8.decode(datagram.data, allowMalformed: true).split('?');
    if (ask.length != 3 || ask[0] != 'AMILUDO' || ask[1] != _room) return;
    final nonce = ask[2];
    if (!isRoomSecret(nonce)) return;
    final port = _server.port;
    final proof = _seal.sign('lan|$_room|$nonce|$port');
    _discovery?.send(
      utf8.encode('AMILUDO!$_room!$port!$proof'),
      datagram.address,
      datagram.port,
    );
  }

  Future<void> _accept(HttpRequest request) async {
    final nonce = request.uri.queryParameters['n'];
    if (request.uri.path != '/room/$_room' ||
        !isRoomSecret(nonce) ||
        !WebSocketTransformer.isUpgradeRequest(request) ||
        _peers.length >= _maxPeers) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    final peer = 'peer${_next++}';
    _peers[peer] = socket;
    socket.add(
      jsonEncode({'type': 'hello', 'proof': _seal.sign('ws|$_room|$nonce')}),
    );
    socket.listen(
      (data) {
        final message = _decode(data);
        if (message != null) _emit(_messages, {...message, '_peer': peer});
      },
      onDone: () {
        _peers.remove(peer);
        _emit(_messages, {
          'type': 'disconnected',
          '_peer': peer,
          '_local': true,
        });
      },
      cancelOnError: true,
    );
  }

  @override
  Stream<RoomMessage> get messages => _messages.stream;

  @override
  void send(RoomMessage message) {
    final text = jsonEncode(message);
    for (final socket in _peers.values) {
      socket.add(text);
    }
  }

  @override
  Future<void> close() async {
    for (final socket in [..._peers.values]) {
      await socket.close();
    }
    _discovery?.close();
    await _server.close(force: true);
    await _messages.close();
  }
}

class LanClientRoom implements RoomChannel {
  LanClientRoom._(this._socket, this._expected, this._seal) {
    _greeted.future.ignore();
    _socket.listen(
      _receive,
      onDone: () {
        if (!_greeted.isCompleted) {
          _greeted.completeError(const RoomHostUnverified());
        }
        _emit(_messages, {'type': 'disconnected', '_local': true});
      },
      cancelOnError: true,
    );
  }

  final WebSocket _socket;
  final String _expected;
  final RoomSeal? _seal;
  final _greeted = Completer<void>();
  final _messages = StreamController<RoomMessage>.broadcast();

  static Future<LanClientRoom> connect(
    String address,
    String code, {
    String? secret,
  }) async {
    final room = roomFingerprint(code);
    final nonce = newRoomSecret();
    final socket = await WebSocket.connect('ws://$address/room/$room?n=$nonce')
        .timeout(const Duration(seconds: 6));
    final client = LanClientRoom._(
      socket,
      'ws|$room|$nonce',
      secret == null ? null : RoomSeal(secret),
    );
    try {
      await client._greeted.future.timeout(const Duration(seconds: 6));
    } on Object {
      await client.close();
      rethrow;
    }
    return client;
  }

  void _receive(Object? data) {
    final message = _decode(data);
    if (message == null) return;
    if (_greeted.isCompleted) {
      _emit(_messages, message);
    } else if (message['type'] == 'hello') {
      final seal = _seal;
      if (seal == null || seal.verify(_expected, message['proof'])) {
        _greeted.complete();
      } else {
        _greeted.completeError(const RoomHostUnverified());
      }
    }
  }

  @override
  Stream<RoomMessage> get messages => _messages.stream;

  @override
  void send(RoomMessage message) => _socket.add(jsonEncode(message));

  @override
  Future<void> close() async {
    await _socket.close();
    await _messages.close();
  }
}

Future<String?> discoverLanRoom(
  String code, {
  String? secret,
  Duration wait = const Duration(seconds: 2),
}) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
    ..broadcastEnabled = true;
  final found = Completer<String?>();
  final room = roomFingerprint(code);
  final nonce = newRoomSecret();
  final seal = secret == null ? null : RoomSeal(secret);
  socket.listen((event) {
    final datagram = event == RawSocketEvent.read ? socket.receive() : null;
    if (datagram == null || found.isCompleted) return;
    final reply = utf8.decode(datagram.data, allowMalformed: true).split('!');
    if (reply.length != 4 || reply[0] != 'AMILUDO' || reply[1] != room) return;
    final port = int.tryParse(reply[2]);
    if (port == null) return;
    if (seal != null && !seal.verify('lan|$room|$nonce|$port', reply[3])) {
      return;
    }
    found.complete('${datagram.address.address}:$port');
  });
  final ask = utf8.encode('AMILUDO?$room?$nonce');
  for (final target in ['255.255.255.255', '127.0.0.1']) {
    socket.send(ask, InternetAddress(target), lanDiscoveryPort);
  }
  final address = await found.future.timeout(wait, onTimeout: () => null);
  socket.close();
  return address;
}

const lanRoomsSupported = true;
