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
  Future<HostedRoom> hostLan(String code) => LanHostedRoom.open(code);

  @override
  Future<RoomChannel> joinLan(String address, String code) =>
      LanClientRoom.connect(address, code);

  @override
  Future<String?> discoverLan(String code) => discoverLanRoom(code);

  @override
  Future<RoomChannel> remote(String code) => RemoteRoom.open(code);
}
