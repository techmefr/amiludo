import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Appearance/domain/use_cases/change_appearance_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/start_game_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/retry_save_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_save_failures_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_state.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit(
    this._loadWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    WatchSaveFailuresUseCase watchSaveFailures,
    this._retrySave,
    this._startGame,
    this._changeAppearance,
  ) : super(const WorkspaceState()) {
    _changes = watchWorkspace().listen(
      (workspace) => emit(state.copyWith(workspace: workspace)),
    );
    _saveFailures = watchSaveFailures().listen(
      (failed) => emit(state.copyWith(saveFailed: failed)),
    );
  }

  final LoadWorkspaceUseCase _loadWorkspace;
  final RetrySaveUseCase _retrySave;
  final StartGameUseCase _startGame;
  final ChangeAppearanceUseCase _changeAppearance;
  late final StreamSubscription<Workspace> _changes;
  late final StreamSubscription<bool> _saveFailures;

  Future<void> load() async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    try {
      await _loadWorkspace();
      emit(state.copyWith(status: WorkspaceStatus.ready));
    } catch (_) {
      emit(state.copyWith(status: WorkspaceStatus.failure));
    }
  }

  Future<void> retrySave() => _retrySave();

  Future<void> startGame(
    String title,
    List<String> names,
    GameTemplate template,
  ) => _startGame(title, names, template);

  Future<void> changeAppearance(Appearance appearance) =>
      _changeAppearance(appearance);

  @override
  Future<void> close() async {
    await _changes.cancel();
    await _saveFailures.cancel();
    return super.close();
  }
}
