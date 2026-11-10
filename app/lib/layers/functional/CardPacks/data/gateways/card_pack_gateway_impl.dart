import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/gateways/card_pack_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class CardPackGatewayImpl extends StoredDocument<CardPackSession?>
    implements CardPackGateway {
  CardPackGatewayImpl(super.store)
    : super(
        id: 'card_packs',
        empty: null,
        fromJson: _decode,
        toJson: (session) => {'cardPacks': session?.toJson()},
      );

  static CardPackSession? _decode(Map<String, dynamic> json) {
    final stored = json['cardPacks'];
    if (stored is! Map) return null;
    return CardPackSession.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Map<String, Object?> backup() => current == null ? const {} : super.backup();
}
