import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class EveningsGatewayImpl extends StoredDocument<EveningAgenda>
    implements EveningsGateway {
  EveningsGatewayImpl(super.store)
    : super(
        id: 'evenings',
        empty: const EveningAgenda(),
        fromJson: EveningAgenda.fromJson,
        toJson: (agenda) => agenda.toJson(),
      );
}
