import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';

abstract class SheetTablesGateway {
  Future<SheetTables> load();
}
