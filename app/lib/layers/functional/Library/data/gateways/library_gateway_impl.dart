import 'package:amiludo/layers/functional/Library/domain/entities/shelf.dart';
import 'package:amiludo/layers/functional/Library/domain/gateways/library_gateway.dart';
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class LibraryGatewayImpl extends StoredDocument<Shelf>
    implements LibraryGateway {
  LibraryGatewayImpl(super.store)
    : super(
        id: 'library',
        empty: const Shelf(),
        fromJson: Shelf.fromJson,
        toJson: (shelf) => shelf.toJson(),
      );
}
