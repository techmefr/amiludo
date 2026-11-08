import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Journal/data/gateways/game_log_gateway_impl.dart';
import 'package:amiludo/layers/functional/Journal/domain/gateways/game_log_gateway.dart';
import 'package:amiludo/layers/functional/Journal/domain/use_cases/game_log_use_cases.dart';

void registerJournal() {
  getIt
    ..registerLazySingleton<GameLogGatewayImpl>(
      () => GameLogGatewayImpl(getIt()),
    )
    ..registerLazySingleton<GameLogGateway>(() => getIt<GameLogGatewayImpl>())
    ..registerFactory(() => ReadGameLogUseCase(getIt()))
    ..registerFactory(() => SaveGameLogUseCase(getIt()));
}
