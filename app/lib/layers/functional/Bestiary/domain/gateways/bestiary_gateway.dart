import 'package:amiludo/layers/functional/Bestiary/domain/entities/bestiary.dart';

abstract class BestiaryGateway {
  Bestiary get current;
  Stream<Bestiary> get changes;
  Future<void> save(Bestiary bestiary);
}
