import 'dart:convert';

import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class ImportBackupUseCase {
  ImportBackupUseCase(this._workspace);

  final WorkspaceGateway _workspace;

  Future<void> call(String text) async {
    if (text.length > 20000000) {
      throw const FormatException('Fichier trop volumineux');
    }
    final imported = Workspace.fromJson(
      Map<String, dynamic>.from(jsonDecode(text) as Map),
    );
    await _workspace.save(
      imported.copyWith(
        clock: imported.clock.pause(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
