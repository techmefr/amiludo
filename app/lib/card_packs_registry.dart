import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/CardPacks/data/gateways/card_pack_gateway_impl.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/gateways/card_pack_gateway.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/use_cases/card_pack_use_cases.dart';

void registerCardPacks() {
  getIt
    ..registerLazySingleton<CardPackGatewayImpl>(
      () => CardPackGatewayImpl(getIt()),
    )
    ..registerLazySingleton<CardPackGateway>(() => getIt<CardPackGatewayImpl>())
    ..registerFactory(() => ReadCardPackSessionUseCase(getIt()))
    ..registerFactory(() => SaveCardPackSessionUseCase(getIt()));
}
