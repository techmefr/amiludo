import 'package:amiludo/layers/functional/Library/domain/entities/imported_game.dart';

abstract class CollectionImportGateway {
  bool get available;
  Future<List<ImportedGame>> collection(String username);
}
