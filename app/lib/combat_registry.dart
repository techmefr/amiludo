import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Combat/data/gateways/encounter_gateway_impl.dart';
import 'package:amiludo/layers/functional/Combat/domain/gateways/encounter_gateway.dart';
import 'package:amiludo/layers/functional/Combat/domain/use_cases/encounter_use_cases.dart';

void registerCombat() {
  getIt
    ..registerLazySingleton<EncounterGatewayImpl>(
      () => EncounterGatewayImpl(getIt()),
    )
    ..registerLazySingleton<EncounterGateway>(
      () => getIt<EncounterGatewayImpl>(),
    )
    ..registerFactory(() => ReadEncounterUseCase(getIt()))
    ..registerFactory(() => SaveEncounterUseCase(getIt()));
}
