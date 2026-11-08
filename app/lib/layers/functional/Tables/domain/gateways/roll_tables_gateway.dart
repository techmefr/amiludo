import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';

abstract class RollTablesGateway {
  RollTables get current;
  Stream<RollTables> get changes;
  Future<void> save(RollTables tables);
}
