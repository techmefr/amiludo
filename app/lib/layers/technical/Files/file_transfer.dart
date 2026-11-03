import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

class FileTransfer {
  static Future<String?> openJson({int maxMegabytes = 20}) async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'JSON',
          extensions: ['json'],
          uniformTypeIdentifiers: ['public.json'],
        ),
      ],
    );
    if (file == null) return null;
    if (await file.length() > maxMegabytes * 1000000) {
      throw FormatException(
        'Fichier trop volumineux ($maxMegabytes Mo maximum)',
      );
    }
    return file.readAsString();
  }

  static Future<Uint8List?> openImage() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
          mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
          uniformTypeIdentifiers: ['public.image'],
        ),
      ],
    );
    return file?.readAsBytes();
  }

  static Future<void> shareText(
    String text,
    String filename, {
    String mime = 'application/json',
  }) async {
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(text)),
      mimeType: mime,
      name: filename,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: [filename],
        downloadFallbackEnabled: true,
      ),
    );
  }
}
