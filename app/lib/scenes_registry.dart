import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Scenes/data/gateways/storyline_gateway_impl.dart';
import 'package:amiludo/layers/functional/Scenes/domain/gateways/storyline_gateway.dart';
import 'package:amiludo/layers/functional/Scenes/domain/use_cases/storyline_use_cases.dart';

void registerScenes() {
  getIt
    ..registerLazySingleton<StorylineGatewayImpl>(
      () => StorylineGatewayImpl(getIt()),
    )
    ..registerLazySingleton<StorylineGateway>(
      () => getIt<StorylineGatewayImpl>(),
    )
    ..registerFactory(() => ReadStorylineUseCase(getIt()))
    ..registerFactory(() => SaveStorylineUseCase(getIt()));
}
