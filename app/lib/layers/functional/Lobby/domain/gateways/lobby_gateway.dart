import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';

abstract class LobbyGateway {
  bool get lanSupported;

  bool get remoteSupported;

  LobbySession? get current;

  Stream<LobbySession?> watch();

  Future<LobbySession> host(
    Lobby draft, {
    required bool lan,
    required bool remote,
  });

  Future<LobbySession> join(RoomLink link, LobbySeat me);

  void publish(Lobby lobby);

  Future<void> leave();
}
