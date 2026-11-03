import 'dart:convert';

import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/technical/Storage/backup_section.dart';

class ImportBackupUseCase {
  ImportBackupUseCase(this._workspace, this._sections);

  final WorkspaceGateway _workspace;
  final List<BackupSection> _sections;

  Future<void> call(String text) async {
    if (text.length > 20000000) {
      throw const FormatException('Fichier trop volumineux');
    }
    final backup = Map<String, dynamic>.from(jsonDecode(text) as Map);
    final imported = Workspace.fromJson(backup);
    final restorations = [for (final s in _sections) s.restore(backup)];
    for (final restore in restorations) {
      await restore();
    }
    await _workspace.save(
      imported.copyWith(
        clock: imported.clock.pause(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
