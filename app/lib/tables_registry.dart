import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Tables/data/gateways/roll_tables_gateway_impl.dart';
import 'package:amiludo/layers/functional/Tables/domain/gateways/roll_tables_gateway.dart';
import 'package:amiludo/layers/functional/Tables/domain/use_cases/roll_tables_use_cases.dart';

void registerTables() {
  getIt
    ..registerLazySingleton<RollTablesGatewayImpl>(
      () => RollTablesGatewayImpl(getIt()),
    )
    ..registerLazySingleton<RollTablesGateway>(
      () => getIt<RollTablesGatewayImpl>(),
    )
    ..registerFactory(() => ReadRollTablesUseCase(getIt()))
    ..registerFactory(() => SaveRollTablesUseCase(getIt()));
}
