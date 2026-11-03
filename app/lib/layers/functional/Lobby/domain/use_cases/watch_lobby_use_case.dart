import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';

class WatchLobbyUseCase {
  WatchLobbyUseCase(this._lobbies);

  final LobbyGateway _lobbies;

  LobbySession? get current => _lobbies.current;

  bool get lanSupported => _lobbies.lanSupported;

  bool get remoteSupported => _lobbies.remoteSupported;

  Stream<LobbySession?> call() => _lobbies.watch();
}
