import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Sharing/domain/entities/session_bundle.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';

class BuildSessionBundleUseCase {
  BuildSessionBundleUseCase(this._workspace, this._library);

  final WorkspaceGateway _workspace;
  final LibraryGateway _library;

  SessionBundle call({
    List<String> shelfGameIds = const [],
    List<String> templateIds = const [],
    List<String> characterIds = const [],
  }) {
    final data = _workspace.current;
    final games = _library.current.games
        .where((g) => shelfGameIds.contains(g.id))
        .toList();
    final wanted = {...templateIds, for (final g in games) ...g.templateIds};
    final templates = [
      ...data.templates,
      ...GameTemplate.builtIn,
    ].where((t) => wanted.remove(t.id)).toList();
    final packNames = templates.map((t) => t.name).toSet();
    return SessionBundle(
      games: games,
      templates: templates,
      characters: data.characters
          .where(
            (c) =>
                characterIds.contains(c.id) || packNames.contains(c.packName),
          )
          .toList(),
      playerNames: data.playerNames,
    );
  }
}
