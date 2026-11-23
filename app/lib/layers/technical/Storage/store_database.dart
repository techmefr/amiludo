import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'store_database.g.dart';

class StoredDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class SoundBlobs extends Table {
  TextColumn get id => text()();
  BlobColumn get bytes => blob()();
  TextColumn get mimeType => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredDocuments, SoundBlobs])
class StoreDatabase extends _$StoreDatabase {
  StoreDatabase()
    : super(
        driftDatabase(
          name: 'table_companion_v1',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.dart.js'),
          ),
        ),
      );
  StoreDatabase.forTesting(super.executor);
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(soundBlobs);
    },
  );
  Future<String?> readDocument(String id) async => (await (select(
    storedDocuments,
  )..where((t) => t.id.equals(id))).getSingleOrNull())?.payload;
  Future<void> writeDocument(String id, String payload) => transaction(
    () => into(storedDocuments).insertOnConflictUpdate(
      StoredDocumentsCompanion.insert(id: id, payload: payload),
    ),
  );
  Future<void> writeBlob(String id, List<int> bytes, String mimeType) =>
      into(soundBlobs).insertOnConflictUpdate(
        SoundBlobsCompanion.insert(
          id: id,
          bytes: Uint8List.fromList(bytes),
          mimeType: mimeType,
        ),
      );
  Future<SoundBlob?> readBlob(String id) =>
      (select(soundBlobs)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> deleteBlob(String id) =>
      (delete(soundBlobs)..where((t) => t.id.equals(id))).go();
  Future<void> clearAll() async {
    await delete(storedDocuments).go();
    await delete(soundBlobs).go();
  }

  Future<void> deleteDocument(String id) =>
      (delete(storedDocuments)..where((t) => t.id.equals(id))).go();
}
