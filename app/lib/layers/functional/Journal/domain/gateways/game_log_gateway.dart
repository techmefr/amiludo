import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';

abstract class GameLogGateway {
  GameLog get current;
  Stream<GameLog> get changes;
  Future<void> save(GameLog log);
}
