import 'dart:typed_data';

import 'package:amiludo/layers/functional/Memories/domain/gateways/photo_gateway.dart';

class ReadPhotoUseCase {
  ReadPhotoUseCase(this._photos);

  final PhotoGateway _photos;

  Future<Uint8List?> call(String id) => _photos.read(id);
}
