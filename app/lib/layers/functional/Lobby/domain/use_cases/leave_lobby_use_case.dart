import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';

class LeaveLobbyUseCase {
  LeaveLobbyUseCase(this._lobbies);

  final LobbyGateway _lobbies;

  Future<void> call() => _lobbies.leave();
}
