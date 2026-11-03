import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';

class ToggleLobbyOpenUseCase {
  ToggleLobbyOpenUseCase(this._lobbies);

  final LobbyGateway _lobbies;

  void call() {
    final session = _lobbies.current;
    if (session == null || !session.isHost) return;
    _lobbies.publish(session.lobby.copyWith(open: !session.lobby.open));
  }
}
