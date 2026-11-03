import 'package:amiludo/layers/technical/Network/lan_room.dart';
import 'package:amiludo/layers/technical/Network/remote_config.dart';
import 'package:amiludo/layers/technical/Network/remote_room.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';

class RoomNetworkImpl implements RoomNetwork {
  @override
  bool get lanSupported => lanRoomsSupported;

  @override
  bool get remoteSupported => RemoteConfig.configured;

  @override
  Future<HostedRoom> hostLan(String code, String secret) =>
      LanHostedRoom.open(code, secret: secret);

  @override
  Future<RoomChannel> joinLan(String address, String code, {String? secret}) =>
      LanClientRoom.connect(address, code, secret: secret);

  @override
  Future<String?> discoverLan(String code, {String? secret}) =>
      discoverLanRoom(code, secret: secret);

  @override
  Future<RoomChannel> remote(String code) => RemoteRoom.open(code);
}
