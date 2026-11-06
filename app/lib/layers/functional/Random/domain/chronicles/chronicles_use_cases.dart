import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';

class LoadChroniclesUseCase {
  LoadChroniclesUseCase(this._catalog, this._runs);

  final ChroniclesCatalogGateway _catalog;
  final ChroniclesRunGateway _runs;

  Future<ChroniclesData> catalog() => _catalog.load();

  ChroniclesRun? resume(ChroniclesData data) {
    final stored = _runs.stored;
    if (stored == null) return null;
    try {
      return ChroniclesRun.fromJson(stored, data);
    } on Object {
      return null;
    }
  }
}

class SaveChroniclesRunUseCase {
  SaveChroniclesRunUseCase(this._runs);

  final ChroniclesRunGateway _runs;

  Future<void> call(ChroniclesRun? run) => _runs.saveRun(run?.toJson());
}
