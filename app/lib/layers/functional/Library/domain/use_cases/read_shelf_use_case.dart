import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';

class ReadShelfUseCase {
  ReadShelfUseCase(this._library);

  final LibraryGateway _library;

  Shelf call() => _library.current;
}
