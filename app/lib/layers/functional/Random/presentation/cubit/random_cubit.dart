import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Random/domain/use_cases/remove_character_use_case.dart';
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
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final ToggleFavoriteToolUseCase _toggleFavoriteTool;
  final SaveCharacterUseCase _saveCharacter;
  final RemoveCharacterUseCase _removeCharacter;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> toggleFavorite(String tool) => _toggleFavoriteTool(tool);

  Future<void> saveCharacter(GameCharacter character) =>
      _saveCharacter(character);

  Future<void> removeCharacter(String id) => _removeCharacter(id);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
