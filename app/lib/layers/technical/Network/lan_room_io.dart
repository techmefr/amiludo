import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amiludo/layers/technical/Network/room_channel.dart';

const lanDiscoveryPort = 47474;
const _maxMessage = 64 * 1024;
const _maxPeers = 16;

RoomMessage? _decode(Object? data) {
  if (data is! String || data.length > _maxMessage) return null;
  try {
    final value = jsonDecode(data);
    return value is Map ? Map<String, dynamic>.from(value) : null;
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
  LanHostedRoom._(this._server, this._discovery, this.address, this.code) {
    _server.listen(_accept);
    _discovery?.listen(_answer);
  }

  final HttpServer _server;
  final RawDatagramSocket? _discovery;
  final String code;
  @override
  final String address;
  final _peers = <String, WebSocket>{};
  final _messages = StreamController<RoomMessage>.broadcast();
  var _next = 0;

  static Future<LanHostedRoom> open(String code) async {
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
    return LanHostedRoom._(server, discovery, '$ip:${server.port}', code);
  }

  void _answer(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _discovery?.receive();
    if (datagram == null) return;
    if (utf8.decode(datagram.data, allowMalformed: true) != 'AMILUDO?$code') {
      return;
    }
    _discovery?.send(
      utf8.encode('AMILUDO!$code!${_server.port}'),
      datagram.address,
      datagram.port,
    );
  }

  Future<void> _accept(HttpRequest request) async {
    if (request.uri.path != '/room/$code' ||
        !WebSocketTransformer.isUpgradeRequest(request) ||
        _peers.length >= _maxPeers) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    final peer = 'peer${_next++}';
    _peers[peer] = socket;
    socket.listen(
      (data) {
        final message = _decode(data);
        if (message != null) _emit(_messages, {...message, '_peer': peer});
      },
      onDone: () {
        _peers.remove(peer);
        _emit(_messages, {'type': 'disconnected', '_peer': peer});
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
  LanClientRoom._(this._socket) {
    _socket.listen(
      (data) {
        final message = _decode(data);
        if (message != null) _emit(_messages, message);
      },
      onDone: () => _emit(_messages, {'type': 'disconnected'}),
      cancelOnError: true,
    );
  }

  final WebSocket _socket;
  final _messages = StreamController<RoomMessage>.broadcast();

  static Future<LanClientRoom> connect(String address, String code) async {
    final socket = await WebSocket.connect('ws://$address/room/$code')
        .timeout(const Duration(seconds: 6));
    return LanClientRoom._(socket);
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
  Duration wait = const Duration(seconds: 2),
}) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
    ..broadcastEnabled = true;
  final found = Completer<String?>();
  final prefix = 'AMILUDO!$code!';
  socket.listen((event) {
    final datagram = event == RawSocketEvent.read ? socket.receive() : null;
    if (datagram == null || found.isCompleted) return;
    final text = utf8.decode(datagram.data, allowMalformed: true);
    final port = int.tryParse(text.replaceFirst(prefix, ''));
    if (text.startsWith(prefix) && port != null) {
      found.complete('${datagram.address.address}:$port');
    }
  });
  final ask = utf8.encode('AMILUDO?$code');
  for (final target in ['255.255.255.255', '127.0.0.1']) {
    socket.send(ask, InternetAddress(target), lanDiscoveryPort);
  }
  final address = await found.future.timeout(wait, onTimeout: () => null);
  socket.close();
  return address;
}

const lanRoomsSupported = true;
