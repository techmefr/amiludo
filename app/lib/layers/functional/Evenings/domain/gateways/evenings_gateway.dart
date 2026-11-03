import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';

abstract class EveningsGateway {
  EveningAgenda get current;
  Stream<EveningAgenda> get changes;
  Future<void> save(EveningAgenda agenda);
}
