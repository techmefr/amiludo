import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';

class ReadAgendaUseCase {
  ReadAgendaUseCase(this._evenings);

  final EveningsGateway _evenings;

  EveningAgenda call() => _evenings.current;
}
