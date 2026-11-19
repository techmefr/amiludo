import 'dart:typed_data';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart'
    show StoreDatabase;
import 'package:amiludo/layers/technical/Storage/stored_document.dart';

class SoundLibraryGatewayImpl extends StoredDocument<SoundLibrary>
    implements SoundLibraryGateway {
  SoundLibraryGatewayImpl(super.store)
    : super(
        id: 'sounds',
        empty: const SoundLibrary(),
        fromJson: SoundLibrary.fromJson,
        toJson: (library) => library.toJson(),
      );

  @override
  Map<String, Object?> backup() => current.isEmpty ? const {} : super.backup();
}

class SoundBlobGatewayImpl implements SoundBlobGateway {
  SoundBlobGatewayImpl(this._database);

  final StoreDatabase _database;

  @override
  Future<void> put(String id, Uint8List bytes, String mimeType) =>
      _database.writeBlob(id, bytes, mimeType);

  @override
  Future<SoundBlobData?> get(String id) async {
    final blob = await _database.readBlob(id);
    return blob == null ? null : SoundBlobData(blob.bytes, blob.mimeType);
  }

  @override
  Future<bool> exists(String id) async => await _database.readBlob(id) != null;

  @override
  Future<void> delete(String id) => _database.deleteBlob(id);
}
