import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';

abstract class LibraryGateway {
  Shelf get current;
  Stream<Shelf> get changes;
  Future<void> save(Shelf shelf);
}
