import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_catalog.dart';
import 'package:amiludo/layers/functional/Templates/domain/gateways/pack_catalog_gateway.dart';

class PackCatalogGatewayImpl implements PackCatalogGateway {
  static const _url =
      'https://techmefr.github.io/amiludo/community/catalog.json';
  static const _asset = 'assets/community/catalog.json';
  static const _maximumBytes = 2000000;

  @override
  Future<List<GameTemplate>> bundled() async =>
      PackCatalog.decode(await rootBundle.loadString(_asset));

  @override
  Future<List<GameTemplate>> fetch() async {
    final client = http.Client();
    try {
      return await (() async {
        final response = await client.send(
          http.Request('GET', Uri.parse(_url)),
        );
        if (response.statusCode != 200) {
          throw const FormatException(
            'La galerie ne répond pas. Réessayez plus tard.',
          );
        }
        final bytes = <int>[];
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          if (bytes.length > _maximumBytes) {
            throw const FormatException('Catalogue trop volumineux');
          }
        }
        return PackCatalog.decode(utf8.decode(bytes));
      })().timeout(const Duration(seconds: 20));
    } finally {
      client.close();
    }
  }
}
