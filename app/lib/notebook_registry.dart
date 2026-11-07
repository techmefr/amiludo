import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Notebook/data/gateways/notebook_gateways_impl.dart';
import 'package:amiludo/layers/functional/Notebook/domain/gateways/notebook_gateways.dart';
import 'package:amiludo/layers/functional/Notebook/domain/use_cases/notebook_use_cases.dart';

void registerNotebook() {
  getIt
    ..registerLazySingleton<NotebookGatewayImpl>(
      () => NotebookGatewayImpl(getIt()),
    )
    ..registerLazySingleton<NotebookGateway>(() => getIt<NotebookGatewayImpl>())
    ..registerLazySingleton<NotebookImageGateway>(
      () => NotebookImageGatewayImpl(getIt()),
    )
    ..registerFactory(() => ReadNotebookUseCase(getIt()))
    ..registerFactory(() => WatchNotebookUseCase(getIt()))
    ..registerFactory(() => SaveCampaignUseCase(getIt(), getIt()))
    ..registerFactory(() => DeleteCampaignUseCase(getIt(), getIt()))
    ..registerFactory(() => ExportCampaignUseCase(getIt(), getIt()))
    ..registerFactory(() => ImportCampaignUseCase(getIt(), getIt()))
    ..registerFactory(() => ImportNotebookImageUseCase(getIt()))
    ..registerFactory(() => ReadNotebookImageUseCase(getIt()));
}
