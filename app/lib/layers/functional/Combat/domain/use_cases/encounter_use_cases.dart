import 'package:amiludo/layers/functional/Combat/domain/entities/encounter.dart';
import 'package:amiludo/layers/functional/Combat/domain/gateways/encounter_gateway.dart';

class ReadEncounterUseCase {
  ReadEncounterUseCase(this._encounters);
  final EncounterGateway _encounters;

  Encounter call() => _encounters.current;
}

class SaveEncounterUseCase {
  SaveEncounterUseCase(this._encounters);
  final EncounterGateway _encounters;

  Future<void> call(Encounter encounter) => _encounters.save(encounter);
}
