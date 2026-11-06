import 'dart:typed_data';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_library.dart';

abstract class DieLibraryGateway {
  DieLibrary get current;
  Stream<DieLibrary> get changes;
  Future<void> save(DieLibrary library);
}

abstract class DieImageGateway {
  Future<Uint8List?> read(String id);
  Future<void> write(String id, List<int> bytes);
  Future<void> delete(String id);
}
