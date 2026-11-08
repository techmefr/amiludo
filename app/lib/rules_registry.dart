import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Rules/data/gateways/rule_book_gateway_impl.dart';
import 'package:amiludo/layers/functional/Rules/domain/gateways/rule_book_gateway.dart';
import 'package:amiludo/layers/functional/Rules/domain/use_cases/rule_book_use_cases.dart';

void registerRules() {
  getIt
    ..registerLazySingleton<RuleBookGatewayImpl>(
      () => RuleBookGatewayImpl(getIt()),
    )
    ..registerLazySingleton<RuleBookGateway>(() => getIt<RuleBookGatewayImpl>())
    ..registerFactory(() => ReadRuleBookUseCase(getIt()))
    ..registerFactory(() => SaveRuleBookUseCase(getIt()));
}
