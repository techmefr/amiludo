import 'dart:convert';
import 'dart:typed_data';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';

const dieBundleFormat = 'amiludo-dice';
const maxBundleChars = 5000000;
const maxImagePixels = 256;
const maxBundleDesigns = 200;
const _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
const _allowedKeys = {'format', 'version', 'designs', 'images'};

bool validPng(Uint8List bytes) {
  if (bytes.length < 24 || bytes.length > 400000) return false;
  for (var i = 0; i < 8; i++) {
    if (bytes[i] != _pngSignature[i]) return false;
  }
  final data = ByteData.sublistView(bytes);
  final w = data.getUint32(16), h = data.getUint32(20);
  return w >= 1 && h >= 1 && w <= maxImagePixels && h <= maxImagePixels;
}

class DieBundle {
  const DieBundle(this.designs, this.images);

  factory DieBundle.decode(String text) {
    if (text.length > maxBundleChars) {
      throw const FormatException('Fichier trop volumineux');
    }
    return DieBundle.fromJson(jsonDecode(text));
  }

  factory DieBundle.fromJson(Object? raw) {
    if (raw is! Map ||
        raw['format'] != dieBundleFormat ||
        raw['version'] != 1 ||
        raw.keys.any((k) => !_allowedKeys.contains(k))) {
      throw const FormatException('Fichier de dés invalide');
    }
    final list = raw['designs'];
    if (list is! List || list.isEmpty || list.length > maxBundleDesigns) {
      throw const FormatException('Fichier de dés invalide');
    }
    final designs = [
      for (final d in list)
        DieDesign.fromJson(Map<String, dynamic>.from(d as Map)),
    ];
    final images = <String, Uint8List>{};
    final rawImages = raw['images'] ?? const {};
    if (rawImages is! Map) {
      throw const FormatException('Fichier de dés invalide');
    }
    for (final e in rawImages.entries) {
      final bytes = base64Decode(e.value as String);
      if (!validPng(bytes)) throw const FormatException('Image invalide');
      images['${e.key}'] = bytes;
    }
    for (final d in designs) {
      if (d.imageIds.any((id) => !images.containsKey(id))) {
        throw const FormatException('Image manquante');
      }
    }
    return DieBundle(designs, images);
  }

  final List<DieDesign> designs;
  final Map<String, Uint8List> images;

  String encode() => jsonEncode(toJson());

  Map<String, Object?> toJson() {
    final used = {for (final d in designs) ...d.imageIds};
    return {
      'format': dieBundleFormat,
      'version': 1,
      'designs': designs.map((d) => d.toJson()).toList(),
      'images': {
        for (final id in used)
          if (images[id] != null) id: base64Encode(images[id]!),
      },
    };
  }

  DieBundle remapped(String Function() newId) => remappedWithIds(newId).bundle;

  ({DieBundle bundle, Map<String, String> images}) remappedWithIds(
    String Function() newId,
  ) {
    final ids = {
      for (final d in designs)
        for (final id in d.imageIds) id: newId(),
    };
    final bundle = DieBundle(
      [
        for (final d in designs)
          d.copyWith(
            faces: [
              for (final f in d.faces)
                f.kind == DieFaceKind.image
                    ? f.copyWith(value: ids[f.value])
                    : f,
            ],
          ),
      ],
      {for (final e in ids.entries) e.value: images[e.key]!},
    );
    return (bundle: bundle, images: ids);
  }
}
