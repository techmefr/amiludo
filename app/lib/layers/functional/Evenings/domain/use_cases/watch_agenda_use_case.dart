import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';

class WatchAgendaUseCase {
  WatchAgendaUseCase(this._evenings);

  final EveningsGateway _evenings;

  Stream<EveningAgenda> call() => _evenings.changes;
}
