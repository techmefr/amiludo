import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';

class SaveEveningUseCase {
  SaveEveningUseCase(this._evenings, this._remote);

  final EveningsGateway _evenings;
  final EveningRemoteGateway _remote;

  Future<void> call(Evening evening) async {
    if (evening.title.trim().isEmpty || evening.title.length > 80) {
      throw const FormatException('Titre invalide');
    }
    if (evening.published && evening.mine && _remote.available) {
      await _remote.publish(evening);
    }
    final evenings = _evenings.current.evenings;
    await _evenings.save(
      EveningAgenda(
        evenings: [evening, ...evenings.where((e) => e.id != evening.id)],
      ),
    );
  }
}
