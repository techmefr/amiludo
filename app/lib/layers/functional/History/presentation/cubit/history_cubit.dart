import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/choose_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/delete_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/save_game_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';

class HistoryCubit extends Cubit<Workspace> {
  HistoryCubit(
    ReadWorkspaceUseCase readWorkspace,
    WatchWorkspaceUseCase watchWorkspace,
    this._saveGame,
    this._chooseGame,
    this._deleteGame,
    this._importBackup,
    this._eraseWorkspace,
    this._exportBackup,
  ) : super(readWorkspace()) {
    _subscription = watchWorkspace().listen(emit);
  }

  final SaveGameUseCase _saveGame;
  final ChooseGameUseCase _chooseGame;
  final DeleteGameUseCase _deleteGame;
  final ImportBackupUseCase _importBackup;
  final EraseWorkspaceUseCase _eraseWorkspace;
  final ExportBackupUseCase _exportBackup;
  late final StreamSubscription<Workspace> _subscription;

  Future<void> saveGame(GameSession game) => _saveGame(game);

  Future<void> chooseGame(String id) => _chooseGame(id);

  Future<void> deleteGame(String id) => _deleteGame(id);

  Future<void> importBackup(String text) => _importBackup(text);

  Future<void> erase() => _eraseWorkspace();

  String exportBackup() => _exportBackup();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
