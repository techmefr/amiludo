import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

class FileTransfer {
  static Future<String?> openJson() async {
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
    if (await file.length() > 20000000) {
      throw const FormatException('Fichier trop volumineux (20 Mo maximum)');
    }
    return file.readAsString();
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
