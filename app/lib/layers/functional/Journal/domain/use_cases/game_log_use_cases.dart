import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';
import 'package:amiludo/layers/functional/Journal/domain/gateways/game_log_gateway.dart';

class ReadGameLogUseCase {
  ReadGameLogUseCase(this._log);
  final GameLogGateway _log;

  GameLog call() => _log.current;
}

class SaveGameLogUseCase {
  SaveGameLogUseCase(this._log);
  final GameLogGateway _log;

  Future<void> call(GameLog log) => _log.save(log);
}
