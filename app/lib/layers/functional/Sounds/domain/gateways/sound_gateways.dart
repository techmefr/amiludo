import 'dart:typed_data';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';

class SoundBlobData {
  const SoundBlobData(this.bytes, this.mimeType);
  final Uint8List bytes;
  final String mimeType;
}

abstract class SoundLibraryGateway {
  SoundLibrary get current;
  Stream<SoundLibrary> get changes;
  Future<void> save(SoundLibrary library);
}

abstract class SoundBlobGateway {
  Future<void> put(String id, Uint8List bytes, String mimeType);
  Future<SoundBlobData?> get(String id);
  Future<bool> exists(String id);
  Future<void> delete(String id);
}
