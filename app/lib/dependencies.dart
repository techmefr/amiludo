import 'package:get_it/get_it.dart';

import 'package:amiludo/layers/functional/Appearance/domain/use_cases/change_appearance_use_case.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/remove_style_profile_use_case.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/save_style_profile_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/add_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/choose_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/delete_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/finish_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/next_round_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/redo_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/reverse_turn_order_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/save_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/start_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/undo_score_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/remove_character_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/save_character_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/toggle_favorite_tool_use_case.dart';
import 'package:amiludo/layers/functional/Templates/data/gateways/pack_catalog_gateway_impl.dart';
import 'package:amiludo/layers/functional/Templates/domain/gateways/pack_catalog_gateway.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/add_template_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/fetch_pack_catalog_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/load_bundled_catalog_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/remove_template_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/configure_clock_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/next_turn_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/set_clock_use_case.dart';
import 'package:amiludo/layers/functional/Timer/domain/use_cases/toggle_clock_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/data/gateways/workspace_gateway_impl.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/retry_save_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_save_failures_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

final getIt = GetIt.instance;

void configureDependencies(StoreDatabase database) {
  if (getIt.isRegistered<StoreDatabase>()) return;
  getIt
    ..registerSingleton<StoreDatabase>(database)
    ..registerLazySingleton<MonotonicTime>(MonotonicTime.new)
    ..registerLazySingleton<WorkspaceGateway>(
      () => WorkspaceGatewayImpl(getIt()),
    )
    ..registerLazySingleton<PackCatalogGateway>(PackCatalogGatewayImpl.new)
    ..registerFactory(() => LoadWorkspaceUseCase(getIt()))
    ..registerFactory(() => ReadWorkspaceUseCase(getIt()))
    ..registerFactory(() => WatchWorkspaceUseCase(getIt()))
    ..registerFactory(() => WatchSaveFailuresUseCase(getIt()))
    ..registerFactory(() => RetrySaveUseCase(getIt()))
    ..registerFactory(() => ImportBackupUseCase(getIt()))
    ..registerFactory(() => EraseWorkspaceUseCase(getIt()))
    ..registerFactory(() => StartGameUseCase(getIt(), getIt()))
    ..registerFactory(() => SaveGameUseCase(getIt()))
    ..registerFactory(() => AddScoreUseCase(getIt()))
    ..registerFactory(() => UndoScoreUseCase(getIt()))
    ..registerFactory(() => RedoScoreUseCase(getIt()))
    ..registerFactory(() => NextRoundUseCase(getIt()))
    ..registerFactory(() => FinishGameUseCase(getIt(), getIt()))
    ..registerFactory(() => DeleteGameUseCase(getIt(), getIt()))
    ..registerFactory(() => ChooseGameUseCase(getIt(), getIt()))
    ..registerFactory(() => ReverseTurnOrderUseCase(getIt()))
    ..registerFactory(() => SetClockUseCase(getIt()))
    ..registerFactory(() => ToggleClockUseCase(getIt(), getIt()))
    ..registerFactory(() => ConfigureClockUseCase(getIt()))
    ..registerFactory(() => NextTurnUseCase(getIt(), getIt()))
    ..registerFactory(() => ChangeAppearanceUseCase(getIt()))
    ..registerFactory(() => SaveStyleProfileUseCase(getIt()))
    ..registerFactory(() => RemoveStyleProfileUseCase(getIt()))
    ..registerFactory(() => AddTemplateUseCase(getIt()))
    ..registerFactory(() => RemoveTemplateUseCase(getIt()))
    ..registerFactory(() => LoadBundledCatalogUseCase(getIt()))
    ..registerFactory(() => FetchPackCatalogUseCase(getIt()))
    ..registerFactory(() => ToggleFavoriteToolUseCase(getIt()))
    ..registerFactory(() => SaveCharacterUseCase(getIt()))
    ..registerFactory(() => RemoveCharacterUseCase(getIt()));
}
