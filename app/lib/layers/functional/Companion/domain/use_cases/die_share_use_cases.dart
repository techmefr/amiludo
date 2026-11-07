import 'dart:convert';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_bundle.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_refs.dart';
import 'package:amiludo/layers/functional/Companion/domain/gateways/die_gateways.dart';
import 'package:amiludo/layers/functional/Companion/domain/use_cases/die_use_cases.dart';

class EmbedDiceUseCase {
  EmbedDiceUseCase(this._export, this._library);
  final ExportDiceUseCase _export;
  final DieLibraryGateway _library;

  Future<String> call(String json) async {
    final map = Map<String, dynamic>.from(jsonDecode(json) as Map);
    final ids = collectDesignIds(map).where(_library.current.has).toList();
    if (ids.isEmpty) return json;
    map[embeddedDiceKey] = jsonDecode(await _export(ids));
    return jsonEncode(map);
  }
}

class ReadEmbeddedDiceUseCase {
  ReadEmbeddedDiceUseCase(this._library);
  final DieLibraryGateway _library;

  ({DieBundle bundle, Set<String> clashes})? call(String text) {
    final raw = jsonDecode(text);
    if (raw is! Map || raw[embeddedDiceKey] == null) return null;
    final bundle = DieBundle.fromJson(raw[embeddedDiceKey]);
    return (bundle: bundle, clashes: _library.current.clashes(bundle.designs));
  }
}

class AcceptEmbeddedDiceUseCase {
  AcceptEmbeddedDiceUseCase(this._import);
  final ImportDiceUseCase _import;

  Future<String> call(String text, DieBundle bundle, ClashPolicy policy) async {
    final ids = await _import(bundle, policy);
    return jsonEncode(
      rewriteDesignRefs(jsonDecode(text), ids.designs, ids.images),
    );
  }
}
