import 'dart:typed_data';

abstract class PhotoGateway {
  Future<Uint8List?> read(String id);
  Future<void> write(String id, List<int> bytes);
  Future<void> delete(String id);
}
