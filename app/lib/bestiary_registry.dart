import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Bestiary/data/gateways/bestiary_gateway_impl.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/gateways/bestiary_gateway.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/use_cases/bestiary_use_cases.dart';

void registerBestiary() {
  getIt
    ..registerLazySingleton<BestiaryGatewayImpl>(
      () => BestiaryGatewayImpl(getIt()),
    )
    ..registerLazySingleton<BestiaryGateway>(() => getIt<BestiaryGatewayImpl>())
    ..registerFactory(() => ReadBestiaryUseCase(getIt()))
    ..registerFactory(() => SaveBestiaryUseCase(getIt()));
}
