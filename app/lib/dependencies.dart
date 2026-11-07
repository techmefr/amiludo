import 'package:get_it/get_it.dart';

import 'package:amiludo/layers/functional/Campaign/data/gateways/campaign_gateway_impl.dart';
import 'package:amiludo/layers/functional/Campaign/domain/gateways/campaign_gateway.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/complete_mission_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/load_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/read_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/reset_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Campaign/domain/use_cases/watch_campaign_use_case.dart';
import 'package:amiludo/layers/functional/Account/data/gateways/account_gateway_impl.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/change_password_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/reset_password_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/send_sign_in_link_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/verify_email_code_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/save_nickname_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_in_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_out_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/sign_up_use_case.dart';
import 'package:amiludo/layers/functional/Account/domain/use_cases/watch_account_use_case.dart';
import 'package:amiludo/layers/functional/Admin/data/gateways/user_admin_gateway_impl.dart';
import 'package:amiludo/layers/functional/Admin/domain/gateways/user_admin_gateway.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/invite_user_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/list_users_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/remove_user_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/set_user_admin_use_case.dart';
import 'package:amiludo/layers/functional/Admin/domain/use_cases/set_user_blocked_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/data/gateways/evening_remote_gateway_impl.dart';
import 'package:amiludo/layers/functional/Evenings/data/gateways/evenings_gateway_impl.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evenings_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/answer_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/fetch_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/publish_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/read_agenda_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/remove_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/save_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/watch_agenda_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/data/gateways/lobby_gateway_impl.dart';
import 'package:amiludo/layers/functional/Lobby/domain/gateways/lobby_gateway.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/decide_seat_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/host_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/join_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/leave_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/start_lobby_game_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/toggle_lobby_open_use_case.dart';
import 'package:amiludo/layers/functional/Lobby/domain/use_cases/watch_lobby_use_case.dart';
import 'package:amiludo/layers/functional/Companion/data/accelerometer_turn_sensor.dart';
import 'package:amiludo/layers/functional/Companion/data/gateways/map_gateways_impl.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/map_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/map_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/data/gateways/die_gateways_impl.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_share_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_use_cases.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_shake_source.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_turns.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';
import 'package:amiludo/layers/technical/Network/room_network_impl.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/change_appearance_use_case.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/remove_style_profile_use_case.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/save_style_profile_use_case.dart';
import 'package:amiludo/layers/functional/Friends/data/gateways/friends_gateway_impl.dart';
import 'package:amiludo/layers/functional/Friends/domain/gateways/friends_gateway.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/read_friends_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/remove_friend_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_friend_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/save_reviews_use_case.dart';
import 'package:amiludo/layers/functional/Friends/domain/use_cases/watch_friends_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/add_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/choose_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/delete_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/finish_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/next_round_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/redo_score_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/reverse_turn_order_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/save_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/set_resource_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/set_status_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/start_game_use_case.dart';
import 'package:amiludo/layers/functional/Game/domain/use_cases/undo_score_use_case.dart';
import 'package:amiludo/layers/functional/Library/data/gateways/library_gateway_impl.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/read_shelf_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/remove_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/save_shelf_game_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/suggest_games_use_case.dart';
import 'package:amiludo/layers/functional/Library/domain/use_cases/watch_shelf_use_case.dart';
import 'package:amiludo/layers/functional/Memories/data/gateways/memories_gateway_impl.dart';
import 'package:amiludo/layers/functional/Random/data/chronicles/chronicles_catalog_gateway_impl.dart';
import 'package:amiludo/layers/functional/Random/data/chronicles/chronicles_run_gateway_impl.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_use_cases.dart';
import 'package:amiludo/layers/functional/Random/data/gateways/character_draft_gateway_impl.dart';
import 'package:amiludo/layers/functional/Random/domain/gateways/character_draft_gateway.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/clear_character_draft_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/read_character_draft_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/save_character_draft_use_case.dart';
import 'package:amiludo/layers/functional/Memories/data/gateways/photo_gateway_impl.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/memories_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/add_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/export_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/import_gallery_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/read_album_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/read_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/remove_photo_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/save_memory_use_case.dart';
import 'package:amiludo/layers/functional/Memories/domain/use_cases/watch_album_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/remove_character_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/save_character_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/toggle_favorite_tool_use_case.dart';
import 'package:amiludo/layers/functional/Sharing/domain/use_cases/build_session_bundle_use_case.dart';
import 'package:amiludo/layers/functional/Sharing/domain/use_cases/import_session_bundle_use_case.dart';
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
import 'package:amiludo/layers/functional/Workspace/data/gateways/data_wipe_gateway_impl.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/data_wipe_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/data/gateways/workspace_gateway_impl.dart';
import 'package:amiludo/layers/functional/Workspace/domain/gateways/workspace_gateway.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/erase_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/retry_save_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_save_failures_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/backup_section.dart';
import 'package:amiludo/layers/technical/Storage/document_store.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

final getIt = GetIt.instance;

void configureDependencies(StoreDatabase database) {
  if (getIt.isRegistered<StoreDatabase>()) return;
  getIt
    ..registerSingleton<StoreDatabase>(database)
    ..registerLazySingleton<MonotonicTime>(MonotonicTime.new)
    ..registerLazySingleton<DocumentStore>(() => DocumentStore(getIt()))
    ..registerLazySingleton<WorkspaceGateway>(
      () => WorkspaceGatewayImpl(getIt()),
    )
    ..registerLazySingleton<DataWipeGateway>(
      () => DataWipeGatewayImpl(getIt()),
    )
    ..registerLazySingleton<FriendsGatewayImpl>(
      () => FriendsGatewayImpl(getIt()),
    )
    ..registerLazySingleton<FriendsGateway>(() => getIt<FriendsGatewayImpl>())
    ..registerLazySingleton<LibraryGatewayImpl>(
      () => LibraryGatewayImpl(getIt()),
    )
    ..registerLazySingleton<LibraryGateway>(() => getIt<LibraryGatewayImpl>())
    ..registerLazySingleton<MemoriesGatewayImpl>(
      () => MemoriesGatewayImpl(getIt()),
    )
    ..registerLazySingleton<MemoriesGateway>(() => getIt<MemoriesGatewayImpl>())
    ..registerLazySingleton<CampaignGatewayImpl>(
      () => CampaignGatewayImpl(getIt()),
    )
    ..registerLazySingleton<CampaignGateway>(() => getIt<CampaignGatewayImpl>())
    ..registerLazySingleton<CharacterDraftGatewayImpl>(
      () => CharacterDraftGatewayImpl(getIt()),
    )
    ..registerLazySingleton<CharacterDraftGateway>(
      () => getIt<CharacterDraftGatewayImpl>(),
    )
    ..registerLazySingleton<ChroniclesRunGatewayImpl>(
      () => ChroniclesRunGatewayImpl(getIt()),
    )
    ..registerLazySingleton<ChroniclesRunGateway>(
      () => getIt<ChroniclesRunGatewayImpl>(),
    )
    ..registerLazySingleton<DieLibraryGatewayImpl>(
      () => DieLibraryGatewayImpl(getIt()),
    )
    ..registerLazySingleton<DieLibraryGateway>(
      () => getIt<DieLibraryGatewayImpl>(),
    )
    ..registerLazySingleton<DieImageGateway>(
      () => DieImageGatewayImpl(getIt()),
    )
    ..registerLazySingleton<ChroniclesCatalogGateway>(
      ChroniclesCatalogGatewayImpl.new,
    )
    ..registerLazySingleton<List<BackupSection>>(
      () => [
        getIt<FriendsGatewayImpl>(),
        getIt<LibraryGatewayImpl>(),
        getIt<MemoriesGatewayImpl>(),
        getIt<EveningsGatewayImpl>(),
        getIt<CharacterDraftGatewayImpl>(),
        getIt<ChroniclesRunGatewayImpl>(),
        getIt<DieLibraryGatewayImpl>(),
        getIt<MapBoardsGatewayImpl>(),
      ],
    )
    ..registerLazySingleton<EveningsGatewayImpl>(
      () => EveningsGatewayImpl(getIt()),
    )
    ..registerLazySingleton<EveningsGateway>(() => getIt<EveningsGatewayImpl>())
    ..registerLazySingleton<PackCatalogGateway>(PackCatalogGatewayImpl.new)
    ..registerLazySingleton<PhotoGateway>(() => PhotoGatewayImpl(getIt()))
    ..registerLazySingleton<RoomNetwork>(RoomNetworkImpl.new)
    ..registerLazySingleton<LobbyGateway>(() => LobbyGatewayImpl(getIt()))
    ..registerLazySingleton<AccountGateway>(AccountGatewayImpl.new)
    ..registerLazySingleton<EveningRemoteGateway>(EveningRemoteGatewayImpl.new);
  _registerSensors();
  _registerTable();
  _registerCollections();
  _registerGatherings();
  _registerCampaign();
  _registerDice();
  _registerMaps();
}

void _registerSensors() {
  getIt
    ..registerLazySingleton<AccelerometerFeed>(PlatformAccelerometerFeed.new)
    ..registerFactoryParam<ShakeSource, SensorSensitivity, void>(
      (level, _) => AccelerometerShakeSource(getIt(), level),
    )
    ..registerLazySingleton<SoundOutput>(AudioplayersSoundOutput.new)
    ..registerFactoryParam<TrayMotion, SensorSensitivity, void>(
      (level, _) => AccelerometerTrayMotion(getIt(), level),
    )
    ..registerFactoryParam<TurnSensor, SensorSensitivity, void>(
      (level, _) => AccelerometerTurnSensor(AccelerometerTurns(getIt(), level)),
    );
}

void _registerTable() {
  getIt
    ..registerFactory(() => LoadWorkspaceUseCase(getIt(), getIt()))
    ..registerFactory(() => ReadWorkspaceUseCase(getIt()))
    ..registerFactory(() => WatchWorkspaceUseCase(getIt()))
    ..registerFactory(() => WatchSaveFailuresUseCase(getIt()))
    ..registerFactory(() => RetrySaveUseCase(getIt()))
    ..registerFactory(() => ImportBackupUseCase(getIt(), getIt()))
    ..registerFactory(() => ExportBackupUseCase(getIt(), getIt()))
    ..registerFactory(() => EraseWorkspaceUseCase(getIt(), getIt(), getIt()))
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
    ..registerFactory(() => SetResourceUseCase(getIt()))
    ..registerFactory(() => SetStatusUseCase(getIt()))
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
    ..registerFactory(() => ToggleFavoriteToolUseCase(getIt()));
}

void _registerCollections() {
  getIt
    ..registerFactory(() => SaveCharacterUseCase(getIt()))
    ..registerFactory(() => RemoveCharacterUseCase(getIt()))
    ..registerFactory(() => ReadCharacterDraftUseCase(getIt()))
    ..registerFactory(() => SaveCharacterDraftUseCase(getIt()))
    ..registerFactory(() => ClearCharacterDraftUseCase(getIt()))
    ..registerFactory(() => LoadChroniclesUseCase(getIt(), getIt()))
    ..registerFactory(() => SaveChroniclesRunUseCase(getIt()))
    ..registerFactory(() => SaveShelfGameUseCase(getIt()))
    ..registerFactory(() => RemoveShelfGameUseCase(getIt(), getIt()))
    ..registerFactory(() => SuggestGamesUseCase(getIt(), getIt()))
    ..registerFactory(() => ReadShelfUseCase(getIt()))
    ..registerFactory(() => WatchShelfUseCase(getIt()))
    ..registerFactory(() => ReadFriendsUseCase(getIt()))
    ..registerFactory(() => WatchFriendsUseCase(getIt()))
    ..registerFactory(() => SaveFriendUseCase(getIt()))
    ..registerFactory(() => RemoveFriendUseCase(getIt()))
    ..registerFactory(() => SaveReviewsUseCase(getIt()))
    ..registerFactory(() => SaveMemoryUseCase(getIt()))
    ..registerFactory(() => AddPhotoUseCase(getIt(), getIt()))
    ..registerFactory(() => RemovePhotoUseCase(getIt(), getIt()))
    ..registerFactory(() => ReadPhotoUseCase(getIt()))
    ..registerFactory(() => ExportGalleryUseCase(getIt(), getIt(), getIt()))
    ..registerFactory(() => ImportGalleryUseCase(getIt(), getIt(), getIt()))
    ..registerFactory(() => ReadAlbumUseCase(getIt()))
    ..registerFactory(() => WatchAlbumUseCase(getIt()))
    ..registerFactory(() => BuildSessionBundleUseCase(getIt(), getIt()))
    ..registerFactory(() => ImportSessionBundleUseCase(getIt(), getIt()));
}

void _registerGatherings() {
  getIt
    ..registerFactory(() => WatchLobbyUseCase(getIt()))
    ..registerFactory(() => HostLobbyUseCase(getIt(), getIt()))
    ..registerFactory(() => JoinLobbyUseCase(getIt(), getIt()))
    ..registerFactory(() => DecideSeatUseCase(getIt()))
    ..registerFactory(() => ToggleLobbyOpenUseCase(getIt()))
    ..registerFactory(() => StartLobbyGameUseCase(getIt()))
    ..registerFactory(() => LeaveLobbyUseCase(getIt()))
    ..registerFactory(() => WatchAccountUseCase(getIt()))
    ..registerFactory(() => SignUpUseCase(getIt(), getIt()))
    ..registerFactory(() => SignInUseCase(getIt(), getIt()))
    ..registerFactory(() => SignOutUseCase(getIt()))
    ..registerFactory(() => ResetPasswordUseCase(getIt()))
    ..registerFactory(() => SendSignInLinkUseCase(getIt()))
    ..registerFactory(() => VerifyEmailCodeUseCase(getIt()))
    ..registerFactory(() => ChangePasswordUseCase(getIt()))
    ..registerFactory(() => SaveNicknameUseCase(getIt()))
    ..registerFactory(() => SaveEveningUseCase(getIt(), getIt()))
    ..registerFactory(() => RemoveEveningUseCase(getIt(), getIt()))
    ..registerFactory(() => PublishEveningUseCase(getIt(), getIt(), getIt()))
    ..registerFactory(
      () => AnswerEveningUseCase(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerFactory(() => ReadAgendaUseCase(getIt()))
    ..registerFactory(() => WatchAgendaUseCase(getIt()))
    ..registerFactory(() => FetchEveningUseCase(getIt(), getIt()));
  _registerAdmin();
}

void _registerAdmin() {
  getIt
    ..registerLazySingleton<UserAdminGateway>(UserAdminGatewayImpl.new)
    ..registerFactory(() => ListUsersUseCase(getIt()))
    ..registerFactory(() => InviteUserUseCase(getIt()))
    ..registerFactory(() => SetUserAdminUseCase(getIt(), getIt()))
    ..registerFactory(() => SetUserBlockedUseCase(getIt(), getIt()))
    ..registerFactory(() => RemoveUserUseCase(getIt(), getIt()));
}

void _registerCampaign() {
  getIt
    ..registerFactory(() => LoadCampaignUseCase(getIt()))
    ..registerFactory(() => ReadCampaignUseCase(getIt()))
    ..registerFactory(() => WatchCampaignUseCase(getIt()))
    ..registerFactory(() => CompleteMissionUseCase(getIt()))
    ..registerFactory(() => ResetCampaignUseCase(getIt()));
}

void _registerDice() {
  getIt
    ..registerFactory(() => SaveDieUseCase(getIt(), getIt()))
    ..registerFactory(() => RemoveDieUseCase(getIt(), getIt()))
    ..registerFactory(() => DuplicateDieUseCase(getIt(), getIt()))
    ..registerFactory(() => ReadDieImageUseCase(getIt()))
    ..registerFactory(() => ExportDiceUseCase(getIt(), getIt()))
    ..registerFactory(() => PreviewDiceImportUseCase(getIt()))
    ..registerFactory(() => ImportDiceUseCase(getIt(), getIt()))
    ..registerFactory(() => EmbedDiceUseCase(getIt(), getIt()))
    ..registerFactory(() => ReadEmbeddedDiceUseCase(getIt()))
    ..registerFactory(() => AcceptEmbeddedDiceUseCase(getIt()));
}

void _registerMaps() {
  getIt
    ..registerLazySingleton<MapBoardsGatewayImpl>(
      () => MapBoardsGatewayImpl(getIt()),
    )
    ..registerLazySingleton<MapBoardsGateway>(
      () => getIt<MapBoardsGatewayImpl>(),
    )
    ..registerLazySingleton<MapImageGateway>(() => MapImageGatewayImpl(getIt()))
    ..registerFactory(() => ReadMapUseCase(getIt()))
    ..registerFactory(() => SaveMapUseCase(getIt(), getIt()))
    ..registerFactory(() => ImportMapImageUseCase(getIt()))
    ..registerFactory(() => ReadMapImageUseCase(getIt()));
}
