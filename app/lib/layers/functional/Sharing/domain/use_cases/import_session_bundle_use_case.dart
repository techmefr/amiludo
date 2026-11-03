import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Sharing/domain/entities/session_bundle.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class SessionImport {
  const SessionImport(this.games, this.templates, this.characters);

  final int games, templates, characters;
}

class ImportSessionBundleUseCase {
  ImportSessionBundleUseCase(this._workspace, this._library);

  final WorkspaceGateway _workspace;
  final LibraryGateway _library;

  Future<SessionImport> call(SessionBundle bundle) async {
    final data = _workspace.current;
    final builtIn = GameTemplate.builtIn.map((t) => t.id).toSet();
    final templates = bundle.templates
        .where((t) => !builtIn.contains(t.id))
        .toList();
    final ids = templates.map((t) => t.id).toSet();
    final games = bundle.games.map((g) => g.id).toSet();
    final characters = bundle.characters.map((c) => c.id).toSet();
    await _library.save(
      Shelf(
        games: [
          ...bundle.games,
          ..._library.current.games.where((g) => !games.contains(g.id)),
        ],
      ),
    );
    await _workspace.save(
      data.copyWith(
        templates: [
          ...templates,
          ...data.templates.where((t) => !ids.contains(t.id)),
        ],
        characters: [
          ...bundle.characters,
          ...data.characters.where((c) => !characters.contains(c.id)),
        ],
        playerNames: bundle.playerNames.isEmpty
            ? data.playerNames
            : bundle.playerNames,
      ),
    );
    return SessionImport(
      bundle.games.length,
      templates.length,
      bundle.characters.length,
    );
  }
}
