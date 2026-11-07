import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_gateways.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';

const sheetAsset = 'assets/chronicles/character-sheet-data.json';

class SheetTablesGatewayImpl implements SheetTablesGateway {
  SheetTablesGatewayImpl(this._chronicles, [AssetBundle? bundle])
    : _bundle = bundle ?? rootBundle;

  final ChroniclesCatalogGateway _chronicles;
  final AssetBundle _bundle;

  @override
  Future<SheetTables> load() async {
    final tables = SheetTables.fromJson(
      jsonDecode(await _bundle.loadString(sheetAsset)) as Map<String, dynamic>,
    );
    return tables.withChronicles(await _chronicles.load());
  }
}
