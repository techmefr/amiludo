import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_generator.dart';

class LoadSheetGeneratorUseCase {
  LoadSheetGeneratorUseCase(this._tables);

  final SheetTablesGateway _tables;

  Future<SheetGenerator> call({RandomTools? random}) async =>
      SheetGenerator(await _tables.load(), random ?? RandomTools());
}
