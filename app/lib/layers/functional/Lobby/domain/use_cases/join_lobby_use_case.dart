import 'package:amiludo/layers/functional/Lobby/domain/entities/lobby.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';
import 'package:amiludo/layers/technical/Network/room_link.dart';

class JoinLobbyUseCase {
  JoinLobbyUseCase(this._lobbies, this._workspace);

  final LobbyGateway _lobbies;
  final WorkspaceGateway _workspace;

  Future<LobbySession> call(String input, {required String name, int? color}) {
    final link = RoomLink.parse(input);
    final trimmed = name.trim();
    if (link == null || link.kind != RoomKind.join) {
      throw const FormatException('Code invalide');
    }
    if (trimmed.isEmpty || trimmed.length > 40) {
      throw const FormatException('Prénom invalide');
    }
    final data = _workspace.current;
    if (data.nickname != trimmed) {
      _workspace.save(data.copyWith(nickname: trimmed));
    }
    return _lobbies.join(
      link,
      LobbySeat(id: newRoomCode(12), name: trimmed, color: color ?? 0xff4f8cff),
    );
  }
}
