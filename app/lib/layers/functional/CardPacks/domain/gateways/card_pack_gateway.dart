import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';

abstract class CardPackGateway {
  CardPackSession? get current;
  Stream<CardPackSession?> get changes;
  Future<void> save(CardPackSession? session);
}
