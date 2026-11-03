import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class RemoveEveningUseCase {
  RemoveEveningUseCase(this._workspace, this._remote);

  final WorkspaceGateway _workspace;
  final EveningRemoteGateway _remote;

  Future<void> call(String id) async {
    final evening = _workspace.current.evenings
        .where((e) => e.id == id)
        .firstOrNull;
    if (evening == null) return;
    if (evening.mine && evening.published && _remote.available) {
      await _remote.remove(evening.code);
    }
    final data = _workspace.current;
    await _workspace.save(
      data.copyWith(evenings: data.evenings.where((e) => e.id != id).toList()),
    );
  }
}
