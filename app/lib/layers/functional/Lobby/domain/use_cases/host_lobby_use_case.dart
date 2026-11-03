import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class HostLobbyUseCase {
  HostLobbyUseCase(this._lobbies, this._workspace);

  final LobbyGateway _lobbies;
  final WorkspaceGateway _workspace;

  Future<LobbySession> call({
    required String title,
    required String name,
    required int seats,
    required bool lan,
    required bool remote,
  }) {
    final host = name.trim();
    if (host.isEmpty || host.length > 40) {
      throw const FormatException('Prénom invalide');
    }
    final data = _workspace.current;
    if (data.nickname != host) _workspace.save(data.copyWith(nickname: host));
    return _lobbies.host(
      Lobby(
        title: title.trim().isEmpty ? 'Partie' : title.trim(),
        hostName: host,
        seats: seats.clamp(2, 32),
      ),
      lan: lan,
      remote: remote,
    );
  }
}
