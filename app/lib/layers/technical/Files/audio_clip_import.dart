import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

class AudioClip {
  const AudioClip({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });
  final String name, mimeType;
  final Uint8List bytes;
}

class AudioClipTooLarge implements Exception {
  const AudioClipTooLarge(this.maxMegabytes);
  final int maxMegabytes;
}

const audioExtensions = ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'flac'];

const _mimeByExtension = {
  'mp3': 'audio/mpeg',
  'wav': 'audio/wav',
  'ogg': 'audio/ogg',
  'm4a': 'audio/mp4',
  'aac': 'audio/aac',
  'flac': 'audio/flac',
};

String? audioMimeType(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0) return null;
  return _mimeByExtension[fileName.substring(dot + 1).toLowerCase()];
}

String audioClipName(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return dot > 0 ? fileName.substring(0, dot) : fileName;
}

class AudioClipImport {
  static Future<List<AudioClip>> pick({int maxMegabytes = 20}) async {
    final files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Audio',
          extensions: audioExtensions,
          uniformTypeIdentifiers: ['public.audio'],
        ),
      ],
    );
    final clips = <AudioClip>[];
    for (final file in files) {
      final mimeType = audioMimeType(file.name);
      if (mimeType == null) continue;
      if (await file.length() > maxMegabytes * 1000000) {
        throw AudioClipTooLarge(maxMegabytes);
      }
      clips.add(
        AudioClip(
          name: audioClipName(file.name),
          bytes: await file.readAsBytes(),
          mimeType: mimeType,
        ),
      );
    }
    return clips;
  }
}
