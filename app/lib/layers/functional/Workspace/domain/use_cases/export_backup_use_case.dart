import 'dart:convert';

import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Storage/backup_section.dart';

class ExportBackupUseCase {
  ExportBackupUseCase(this._workspace, this._sections);

  final WorkspaceGateway _workspace;
  final List<BackupSection> _sections;

  String call() => jsonEncode({
    ..._workspace.current.toJson(),
    for (final section in _sections) ...section.backup(),
  });
}
