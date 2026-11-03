import 'package:amiludo/layers/technical/Network/room_channel.dart';

class LanHostedRoom {
  static Future<HostedRoom> open(String code, {String? secret}) =>
      throw UnsupportedError('Réseau local indisponible sur le web');
}

class LanClientRoom {
  static Future<RoomChannel> connect(
    String address,
    String code, {
    String? secret,
  }) => throw UnsupportedError('Réseau local indisponible sur le web');
}

Future<String?> discoverLanRoom(String code, {String? secret}) async => null;

const lanRoomsSupported = false;
