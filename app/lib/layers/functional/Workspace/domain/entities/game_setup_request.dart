import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

class GameSetupRequest {
  const GameSetupRequest({this.template, this.names});

  static const path = '/setup';

  final GameTemplate? template;
  final List<String>? names;
}
