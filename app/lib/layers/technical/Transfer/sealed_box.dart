import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class SealedBox {
  static final _algorithm = AesGcm.with256bits();

  static String newKey() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
  }

  static SecretKey _secret(String key) {
    final bytes = base64Url.decode(base64Url.normalize(key.trim()));
    if (bytes.length != 32) throw const FormatException('Clé invalide');
    return SecretKey(bytes);
  }

  static Future<Map<String, String>> seal(List<int> data, String key) async {
    final box = await _algorithm.encrypt(data, secretKey: _secret(key));
    return {
      'nonce': base64Encode(box.nonce),
      'mac': base64Encode(box.mac.bytes),
      'data': base64Encode(box.cipherText),
    };
  }

  static Future<List<int>> open(Map<String, dynamic> sealed, String key) async {
    final box = SecretBox(
      base64Decode(sealed['data'] as String),
      nonce: base64Decode(sealed['nonce'] as String),
      mac: Mac(base64Decode(sealed['mac'] as String)),
    );
    try {
      return await _algorithm.decrypt(box, secretKey: _secret(key));
    } on SecretBoxAuthenticationError {
      throw const FormatException('Clé incorrecte ou fichier altéré');
    }
  }
}
