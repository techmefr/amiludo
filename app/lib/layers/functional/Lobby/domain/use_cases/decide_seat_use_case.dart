import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';

class DecideSeatUseCase {
  DecideSeatUseCase(this._lobbies);

  final LobbyGateway _lobbies;

  void call(String seatId, {required bool accept}) {
    final session = _lobbies.current;
    if (session == null || !session.isHost) return;
    _lobbies.publish(session.lobby.decide(seatId, accept: accept));
  }
}
