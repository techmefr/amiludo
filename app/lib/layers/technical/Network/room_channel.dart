typedef RoomMessage = Map<String, dynamic>;

abstract class RoomChannel {
  Stream<RoomMessage> get messages;

  void send(RoomMessage message);

  Future<void> close();
}

abstract class HostedRoom implements RoomChannel {
  String get address;
}

abstract class RoomNetwork {
  bool get lanSupported;

  bool get remoteSupported;

  Future<HostedRoom> hostLan(String code);

  Future<RoomChannel> joinLan(String address, String code);

  Future<String?> discoverLan(String code);

  Future<RoomChannel> remote(String code);
}
