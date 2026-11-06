import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';

abstract class ChroniclesCatalogGateway {
  Future<ChroniclesData> load();
}

abstract class ChroniclesRunGateway {
  Map<String, dynamic>? get stored;
  Future<void> saveRun(Map<String, Object?>? run);
}
