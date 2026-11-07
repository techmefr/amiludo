import 'dart:typed_data';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook.dart';

abstract class NotebookGateway {
  Notebook get current;
  Stream<Notebook> get changes;
  Future<void> save(Notebook notebook);
}

abstract class NotebookImageGateway {
  Future<Uint8List?> read(String id);
  Future<void> write(String id, List<int> bytes);
  Future<void> delete(String id);
}
