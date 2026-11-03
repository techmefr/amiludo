typedef RoomMessage = Map<String, dynamic>;

abstract class RoomChannel {
  Stream<RoomMessage> get messages;

  void send(RoomMessage message);

  Future<void> close();
}

abstract class HostedRoom implements RoomChannel {
  String get address;
}

class RoomHostUnverified implements Exception {
  const RoomHostUnverified();
}

abstract class RoomNetwork {
  bool get lanSupported;

  bool get remoteSupported;

  Future<HostedRoom> hostLan(String code, String secret);

  Future<RoomChannel> joinLan(String address, String code, {String? secret});

  Future<String?> discoverLan(String code, {String? secret});

  Future<RoomChannel> remote(String code);
}
