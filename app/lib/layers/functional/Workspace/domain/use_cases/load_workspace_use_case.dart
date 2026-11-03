import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Storage/backup_section.dart';

class LoadWorkspaceUseCase {
  LoadWorkspaceUseCase(this._workspace, this._sections);

  final WorkspaceGateway _workspace;
  final List<BackupSection> _sections;

  Future<Workspace> call() async {
    for (final section in _sections) {
      await section.load();
    }
    return _workspace.load();
  }
}
