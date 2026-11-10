import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/gateways/card_pack_gateway.dart';

class ReadCardPackSessionUseCase {
  ReadCardPackSessionUseCase(this._sessions);
  final CardPackGateway _sessions;

  CardPackSession? call() => _sessions.current;
}

class SaveCardPackSessionUseCase {
  SaveCardPackSessionUseCase(this._sessions);
  final CardPackGateway _sessions;

  Future<void> call(CardPackSession? session) => _sessions.save(session);
}
