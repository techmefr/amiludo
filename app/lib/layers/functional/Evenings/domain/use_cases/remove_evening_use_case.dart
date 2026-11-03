import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';

class RemoveEveningUseCase {
  RemoveEveningUseCase(this._evenings, this._remote);

  final EveningsGateway _evenings;
  final EveningRemoteGateway _remote;

  Future<void> call(String id) async {
    final evening = _evenings.current.evenings
        .where((e) => e.id == id)
        .firstOrNull;
    if (evening == null) return;
    if (evening.mine && evening.published && _remote.available) {
      await _remote.remove(evening.code);
    }
    final evenings = _evenings.current.evenings;
    await _evenings.save(
      EveningAgenda(evenings: evenings.where((e) => e.id != id).toList()),
    );
  }
}
