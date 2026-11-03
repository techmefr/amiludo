import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SaveEveningUseCase {
  SaveEveningUseCase(this._workspace, this._remote);

  final WorkspaceGateway _workspace;
  final EveningRemoteGateway _remote;

  Future<void> call(Evening evening) async {
    if (evening.title.trim().isEmpty || evening.title.length > 80) {
      throw const FormatException('Titre invalide');
    }
    if (evening.published && evening.mine && _remote.available) {
      await _remote.publish(evening);
    }
    final data = _workspace.current;
    await _workspace.save(
      data.copyWith(
        evenings: [evening, ...data.evenings.where((e) => e.id != evening.id)],
      ),
    );
  }
}
