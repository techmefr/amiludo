import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/World/data/gateways/world_atlas_gateway_impl.dart';
import 'package:amiludo/layers/functional/World/domain/gateways/world_atlas_gateway.dart';
import 'package:amiludo/layers/functional/World/domain/use_cases/world_atlas_use_cases.dart';

void registerWorld() {
  getIt
    ..registerLazySingleton<WorldAtlasGatewayImpl>(
      () => WorldAtlasGatewayImpl(getIt()),
    )
    ..registerLazySingleton<WorldAtlasGateway>(
      () => getIt<WorldAtlasGatewayImpl>(),
    )
    ..registerFactory(() => ReadWorldAtlasUseCase(getIt()))
    ..registerFactory(() => SaveWorldAtlasUseCase(getIt()));
}
