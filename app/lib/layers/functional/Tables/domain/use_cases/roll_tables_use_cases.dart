import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';
import 'package:amiludo/layers/functional/Tables/domain/gateways/roll_tables_gateway.dart';

class ReadRollTablesUseCase {
  ReadRollTablesUseCase(this._tables);
  final RollTablesGateway _tables;

  RollTables call() => _tables.current;
}

class SaveRollTablesUseCase {
  SaveRollTablesUseCase(this._tables);
  final RollTablesGateway _tables;

  Future<void> call(RollTables tables) => _tables.save(tables);
}
