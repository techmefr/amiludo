import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

final _secretPattern = RegExp(r'^[A-Za-z0-9_-]{22}$');
final _proofPattern = RegExp(r'^[0-9a-f]{64}$');

String newRoomSecret([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List.generate(16, (_) => source.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

bool isRoomSecret(String? value) =>
    value != null && _secretPattern.hasMatch(value);

bool isRoomProof(Object? value) =>
    value is String && _proofPattern.hasMatch(value);

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

String roomProof(String secret) => _hex(
  const DartSha256().hashSync(utf8.encode('amiludo-proof:$secret')).bytes,
);

String roomFingerprint(String code) =>
    _hex(const DartSha256().hashSync(utf8.encode('amiludo-room:$code')).bytes)
        .substring(0, 32);

bool sameProof(Object? left, Object? right) {
  if (left is! String || right is! String || left.length != right.length) {
    return false;
  }
  var difference = 0;
  for (var i = 0; i < left.length; i++) {
    difference |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
  }
  return difference == 0;
}

class RoomSeal {
  RoomSeal(String secret)
    : _key = SecretKeyData(base64Url.decode(base64Url.normalize(secret)));

  static const _hmac = DartHmac(DartSha256());

  final SecretKeyData _key;

  String sign(String text) => _hex(
    _hmac
        .calculateMacSync(
          utf8.encode(text),
          secretKeyData: _key,
          nonce: const [],
        )
        .bytes,
  );

  bool verify(String text, Object? signature) =>
      sameProof(sign(text), signature);
}
