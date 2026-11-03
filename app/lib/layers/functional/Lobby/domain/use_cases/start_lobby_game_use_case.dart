import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';

class StartLobbyGameUseCase {
  StartLobbyGameUseCase(this._lobbies);

  final LobbyGateway _lobbies;

  List<String> call() {
    final session = _lobbies.current;
    if (session == null || !session.isHost) return const [];
    final lobby = session.lobby.copyWith(open: false, started: true);
    _lobbies.publish(lobby);
    return lobby.playerNames;
  }
}
