import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Network/room_code.dart';

class FetchEveningUseCase {
  FetchEveningUseCase(this._workspace, this._remote);

  final WorkspaceGateway _workspace;
  final EveningRemoteGateway _remote;

  Future<Evening?> call(String code) async {
    final clean = normalizeRoomCode(code);
    if (clean == null) throw const FormatException('Code invalide');
    final data = _workspace.current;
    final known = data.evenings.where((e) => e.code == clean).firstOrNull;
    if (!_remote.available) return known;
    final remote = await _remote.fetch(clean);
    if (remote == null) return known;
    final merged = Evening.fromJson({
      ...remote.toJson(),
      'id': known?.id ?? 'evening-$clean',
    }, mine: known?.mine ?? false);
    await _workspace.save(
      data.copyWith(
        evenings: [merged, ...data.evenings.where((e) => e.code != clean)],
      ),
    );
    return merged;
  }
}
