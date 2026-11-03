import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening_agenda.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';

class FetchEveningUseCase {
  FetchEveningUseCase(this._evenings, this._remote);

  final EveningsGateway _evenings;
  final EveningRemoteGateway _remote;

  Future<Evening?> call(String code) async {
    final clean = normalizeRoomCode(code);
    if (clean == null) throw const FormatException('Code invalide');
    final before = _evenings.current.evenings;
    if (!_remote.available) {
      return before.where((e) => e.code == clean).firstOrNull;
    }
    final remote = await _remote.fetch(clean);
    final evenings = _evenings.current.evenings;
    final known = evenings.where((e) => e.code == clean).firstOrNull;
    if (remote == null) return known;
    final merged = Evening.fromJson({
      ...remote.toJson(),
      'id': known?.id ?? 'evening-$clean',
    }, mine: known?.mine ?? false);
    await _evenings.save(
      EveningAgenda(
        evenings: [merged, ...evenings.where((e) => e.code != clean)],
      ),
    );
    return merged;
  }
}
