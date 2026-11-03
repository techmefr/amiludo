import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class WatchShelfUseCase {
  WatchShelfUseCase(this._library);

  final LibraryGateway _library;

  Stream<Shelf> call() => _library.changes;
}
