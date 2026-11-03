import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';

abstract class EveningRemoteGateway {
  bool get available;

  Future<void> publish(Evening evening);

  Future<Evening?> fetch(String code);

  Future<Evening> answer(String code, Rsvp rsvp);

  Future<void> remove(String code);
}
