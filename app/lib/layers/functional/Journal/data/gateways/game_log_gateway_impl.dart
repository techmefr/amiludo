import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';
import 'package:amiludo/layers/functional/Journal/domain/gateways/game_log_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class GameLogGatewayImpl extends StoredDocument<GameLog>
    implements GameLogGateway {
  GameLogGatewayImpl(super.store)
    : super(
        id: 'journal',
        empty: const GameLog(),
        fromJson: GameLog.fromJson,
        toJson: (log) => log.toJson(),
        legacyId: 'journal-legacy',
      );

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}
