import 'package:amiludo/layers/functional/Bestiary/domain/entities/bestiary.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/gateways/bestiary_gateway.dart';

class ReadBestiaryUseCase {
  ReadBestiaryUseCase(this._bestiary);
  final BestiaryGateway _bestiary;

  Bestiary call() => _bestiary.current;
}

class SaveBestiaryUseCase {
  SaveBestiaryUseCase(this._bestiary);
  final BestiaryGateway _bestiary;

  Future<void> call(Bestiary bestiary) => _bestiary.save(bestiary);
}
