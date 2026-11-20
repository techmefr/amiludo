import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Sounds/data/gateways/sound_gateways_impl.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

void registerSounds() {
  getIt
    ..registerLazySingleton<ClipOutput>(AudioplayersClipOutput.new)
    ..registerLazySingleton<SoundLibraryGatewayImpl>(
      () => SoundLibraryGatewayImpl(getIt()),
    )
    ..registerLazySingleton<SoundLibraryGateway>(
      () => getIt<SoundLibraryGatewayImpl>(),
    )
    ..registerLazySingleton<SoundBlobGateway>(
      () => SoundBlobGatewayImpl(getIt<StoreDatabase>()),
    )
    ..registerFactory(() => SoundSetUseCases(getIt(), getIt()))
    ..registerFactory(() => PlaylistEngine(getIt(), getIt()))
    ..registerFactory(() => PadPlayer(getIt(), getIt()));
}
