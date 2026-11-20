import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_share.dart';

const soundShareTopic = 'snd';

class LobbySoundTransport implements SoundShareTransport {
  LobbySoundTransport(this._lobby);

  final LobbyGateway _lobby;

  @override
  Stream<ShareIncoming> get incoming => _lobby.appMessages
      .where((m) => m.topic == soundShareTopic)
      .map((m) => ShareIncoming(m.from, m.body));

  @override
  void sendToHost(Map<String, Object?> message) =>
      _lobby.sendApp(soundShareTopic, message);

  @override
  void broadcast(Map<String, Object?> message) =>
      _lobby.sendApp(soundShareTopic, message);
}

SoundShare? soundShareForLobby(LobbyGateway lobby, SoundBlobGateway blobs) {
  final session = lobby.current;
  if (session == null || !lobby.canSendApp) return null;
  return SoundShare(
    LobbySoundTransport(lobby),
    blobs,
    selfId: session.me ?? 'host',
    isHost: session.isHost,
  );
}
