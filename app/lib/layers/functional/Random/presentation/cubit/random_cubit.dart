import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Lobby/domain/use_cases/watch_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/clear_character_draft_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/read_character_draft_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/remove_character_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/save_character_draft_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/save_character_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/toggle_favorite_tool_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class RandomCubit extends Cubit<Workspace> {
  RandomCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._toggleFavoriteTool,
    this._saveCharacter,
    this._removeCharacter,
    this._lobby,
    this._readDraft,
    this._saveDraft,
    this._clearDraft,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final ToggleFavoriteToolUseCase _toggleFavoriteTool;
  final SaveCharacterUseCase _saveCharacter;
  final RemoveCharacterUseCase _removeCharacter;
  final WatchLobbyUseCase _lobby;
  final ReadCharacterDraftUseCase _readDraft;
  final SaveCharacterDraftUseCase _saveDraft;
  final ClearCharacterDraftUseCase _clearDraft;
  late final StreamSubscription<Workspace> _subscription;

  List<String> get lobbyNames {
    final session = _lobby.current;
    if (session == null || session.ended) return const [];
    return session.lobby.playerNames;
  }

  Future<void> toggleFavorite(String tool) => _toggleFavoriteTool(tool);

  Future<void> saveCharacter(GameCharacter character) =>
      _saveCharacter(character);

  Future<void> removeCharacter(String id) => _removeCharacter(id);

  CharacterDraft? draftFor(String packName) => _readDraft(packName);

  Future<void> saveDraft(CharacterDraft draft) => _saveDraft(draft);

  Future<void> clearDraft() => _clearDraft();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
