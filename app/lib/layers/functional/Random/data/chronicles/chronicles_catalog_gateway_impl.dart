import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_gateways.dart';

const chroniclesAsset = 'assets/chronicles/chronicles-data.json';

class ChroniclesCatalogGatewayImpl implements ChroniclesCatalogGateway {
  ChroniclesCatalogGatewayImpl([AssetBundle? bundle])
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<ChroniclesData> load() async => ChroniclesData.fromJson(
    jsonDecode(await _bundle.loadString(chroniclesAsset))
        as Map<String, dynamic>,
  );
}
