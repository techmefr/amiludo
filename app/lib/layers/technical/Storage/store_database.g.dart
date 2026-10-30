// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_database.dart';

// ignore_for_file: type=lint
class $StoredDocumentsTable extends StoredDocuments
    with TableInfo<$StoredDocumentsTable, StoredDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $StoredDocumentsTable createAlias(String alias) {
    return $StoredDocumentsTable(attachedDatabase, alias);
  }
}

class StoredDocument extends DataClass implements Insertable<StoredDocument> {
  final String id;
  final String payload;
  const StoredDocument({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  StoredDocumentsCompanion toCompanion(bool nullToAbsent) {
    return StoredDocumentsCompanion(id: Value(id), payload: Value(payload));
  }

  factory StoredDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDocument(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  StoredDocument copyWith({String? id, String? payload}) =>
      StoredDocument(id: id ?? this.id, payload: payload ?? this.payload);
  StoredDocument copyWithCompanion(StoredDocumentsCompanion data) {
    return StoredDocument(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDocument(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDocument &&
          other.id == this.id &&
          other.payload == this.payload);
}

class StoredDocumentsCompanion extends UpdateCompanion<StoredDocument> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const StoredDocumentsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredDocumentsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<StoredDocument> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredDocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return StoredDocumentsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StoreDatabase extends GeneratedDatabase {
  _$StoreDatabase(QueryExecutor e) : super(e);
  $StoreDatabaseManager get managers => $StoreDatabaseManager(this);
  late final $StoredDocumentsTable storedDocuments = $StoredDocumentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [storedDocuments];
}

typedef $$StoredDocumentsTableCreateCompanionBuilder =
    StoredDocumentsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$StoredDocumentsTableUpdateCompanionBuilder =
    StoredDocumentsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

class $$StoredDocumentsTableFilterComposer
    extends Composer<_$StoreDatabase, $StoredDocumentsTable> {
  $$StoredDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredDocumentsTableOrderingComposer
    extends Composer<_$StoreDatabase, $StoredDocumentsTable> {
  $$StoredDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredDocumentsTableAnnotationComposer
    extends Composer<_$StoreDatabase, $StoredDocumentsTable> {
  $$StoredDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$StoredDocumentsTableTableManager
    extends
        RootTableManager<
          _$StoreDatabase,
          $StoredDocumentsTable,
          StoredDocument,
          $$StoredDocumentsTableFilterComposer,
          $$StoredDocumentsTableOrderingComposer,
          $$StoredDocumentsTableAnnotationComposer,
          $$StoredDocumentsTableCreateCompanionBuilder,
          $$StoredDocumentsTableUpdateCompanionBuilder,
          (
            StoredDocument,
            BaseReferences<
              _$StoreDatabase,
              $StoredDocumentsTable,
              StoredDocument
            >,
          ),
          StoredDocument,
          PrefetchHooks Function()
        > {
  $$StoredDocumentsTableTableManager(
    _$StoreDatabase db,
    $StoredDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredDocumentsCompanion(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => StoredDocumentsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoredDocumentsTable, StoredDocument>(table),
                  BaseReferences<
                    _$StoreDatabase,
                    $StoredDocumentsTable,
                    StoredDocument
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$StoreDatabase,
      $StoredDocumentsTable,
      StoredDocument,
      $$StoredDocumentsTableFilterComposer,
      $$StoredDocumentsTableOrderingComposer,
      $$StoredDocumentsTableAnnotationComposer,
      $$StoredDocumentsTableCreateCompanionBuilder,
      $$StoredDocumentsTableUpdateCompanionBuilder,
      (
        StoredDocument,
        BaseReferences<_$StoreDatabase, $StoredDocumentsTable, StoredDocument>,
      ),
      StoredDocument,
      PrefetchHooks Function()
    >;

class $StoreDatabaseManager {
  final _$StoreDatabase _db;
  $StoreDatabaseManager(this._db);
  $$StoredDocumentsTableTableManager get storedDocuments =>
      $$StoredDocumentsTableTableManager(_db, _db.storedDocuments);
}
