import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

Uint8List packJson(Object? value) => Uint8List.fromList(
  GZipEncoder().encodeBytes(utf8.encode(jsonEncode(value))),
);

Object? unpackJson(List<int> bytes, {int maxBytes = 50000000}) {
  if (bytes.length > maxBytes) {
    throw const FormatException('Données trop volumineuses');
  }
  final text = GZipDecoder().decodeBytes(bytes);
  if (text.length > maxBytes * 4) {
    throw const FormatException('Données trop volumineuses');
  }
  return jsonDecode(utf8.decode(text));
}
