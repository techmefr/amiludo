import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/data_wipe_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Storage/backup_section.dart';

class EraseWorkspaceUseCase {
  EraseWorkspaceUseCase(this._workspace, this._sections, this._wipe);

  final WorkspaceGateway _workspace;
  final List<BackupSection> _sections;
  final DataWipeGateway _wipe;

  Future<void> call() async {
    for (final section in _sections) {
      await section.restore(const {})();
    }
    await _workspace.save(const Workspace());
    await _wipe();
  }
}
