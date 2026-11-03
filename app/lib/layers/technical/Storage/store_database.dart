import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'store_database.g.dart';

class StoredDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredDocuments])
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
  int get schemaVersion => 1;
  Future<String?> readDocument(String id) async => (await (select(
    storedDocuments,
  )..where((t) => t.id.equals(id))).getSingleOrNull())?.payload;
  Future<void> writeDocument(String id, String payload) => transaction(
    () => into(storedDocuments).insertOnConflictUpdate(
      StoredDocumentsCompanion.insert(id: id, payload: payload),
    ),
  );
  Future<void> deleteDocument(String id) =>
      (delete(storedDocuments)..where((t) => t.id.equals(id))).go();
}
