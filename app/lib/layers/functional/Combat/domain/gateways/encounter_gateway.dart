import 'package:amiludo/layers/functional/Combat/domain/entities/encounter.dart';

abstract class EncounterGateway {
  Encounter get current;
  Stream<Encounter> get changes;
  Future<void> save(Encounter encounter);
}
