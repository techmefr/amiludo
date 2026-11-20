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

class $SoundBlobsTable extends SoundBlobs
    with TableInfo<$SoundBlobsTable, SoundBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SoundBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bytes, mimeType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sound_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SoundBlob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SoundBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SoundBlob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
    );
  }

  @override
  $SoundBlobsTable createAlias(String alias) {
    return $SoundBlobsTable(attachedDatabase, alias);
  }
}

class SoundBlob extends DataClass implements Insertable<SoundBlob> {
  final String id;
  final Uint8List bytes;
  final String mimeType;
  const SoundBlob({
    required this.id,
    required this.bytes,
    required this.mimeType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['mime_type'] = Variable<String>(mimeType);
    return map;
  }

  SoundBlobsCompanion toCompanion(bool nullToAbsent) {
    return SoundBlobsCompanion(
      id: Value(id),
      bytes: Value(bytes),
      mimeType: Value(mimeType),
    );
  }

  factory SoundBlob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SoundBlob(
      id: serializer.fromJson<String>(json['id']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'mimeType': serializer.toJson<String>(mimeType),
    };
  }

  SoundBlob copyWith({String? id, Uint8List? bytes, String? mimeType}) =>
      SoundBlob(
        id: id ?? this.id,
        bytes: bytes ?? this.bytes,
        mimeType: mimeType ?? this.mimeType,
      );
  SoundBlob copyWithCompanion(SoundBlobsCompanion data) {
    return SoundBlob(
      id: data.id.present ? data.id.value : this.id,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SoundBlob(')
          ..write('id: $id, ')
          ..write('bytes: $bytes, ')
          ..write('mimeType: $mimeType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(bytes), mimeType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoundBlob &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.mimeType == this.mimeType);
}

class SoundBlobsCompanion extends UpdateCompanion<SoundBlob> {
  final Value<String> id;
  final Value<Uint8List> bytes;
  final Value<String> mimeType;
  final Value<int> rowid;
  const SoundBlobsCompanion({
    this.id = const Value.absent(),
    this.bytes = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SoundBlobsCompanion.insert({
    required String id,
    required Uint8List bytes,
    required String mimeType,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bytes = Value(bytes),
       mimeType = Value(mimeType);
  static Insertable<SoundBlob> custom({
    Expression<String>? id,
    Expression<Uint8List>? bytes,
    Expression<String>? mimeType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bytes != null) 'bytes': bytes,
      if (mimeType != null) 'mime_type': mimeType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SoundBlobsCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? bytes,
    Value<String>? mimeType,
    Value<int>? rowid,
  }) {
    return SoundBlobsCompanion(
      id: id ?? this.id,
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SoundBlobsCompanion(')
          ..write('id: $id, ')
          ..write('bytes: $bytes, ')
          ..write('mimeType: $mimeType, ')
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
  late final $SoundBlobsTable soundBlobs = $SoundBlobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedDocuments,
    soundBlobs,
  ];
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
typedef $$SoundBlobsTableCreateCompanionBuilder = SoundBlobsCompanion Function({
  required String id,
  required Uint8List bytes,
  required String mimeType,
  Value<int> rowid,
});
typedef $$SoundBlobsTableUpdateCompanionBuilder = SoundBlobsCompanion Function({
  Value<String> id,
  Value<Uint8List> bytes,
  Value<String> mimeType,
  Value<int> rowid,
});

class $$SoundBlobsTableFilterComposer
    extends Composer<_$StoreDatabase, $SoundBlobsTable> {
  $$SoundBlobsTableFilterComposer({
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

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SoundBlobsTableOrderingComposer
    extends Composer<_$StoreDatabase, $SoundBlobsTable> {
  $$SoundBlobsTableOrderingComposer({
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

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SoundBlobsTableAnnotationComposer
    extends Composer<_$StoreDatabase, $SoundBlobsTable> {
  $$SoundBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);
}

class $$SoundBlobsTableTableManager
    extends
        RootTableManager<
          _$StoreDatabase,
          $SoundBlobsTable,
          SoundBlob,
          $$SoundBlobsTableFilterComposer,
          $$SoundBlobsTableOrderingComposer,
          $$SoundBlobsTableAnnotationComposer,
          $$SoundBlobsTableCreateCompanionBuilder,
          $$SoundBlobsTableUpdateCompanionBuilder,
          (
            SoundBlob,
            BaseReferences<_$StoreDatabase, $SoundBlobsTable, SoundBlob>,
          ),
          SoundBlob,
          PrefetchHooks Function()
        > {
  $$SoundBlobsTableTableManager(_$StoreDatabase db, $SoundBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SoundBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SoundBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SoundBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SoundBlobsCompanion(
                id: id,
                bytes: bytes,
                mimeType: mimeType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List bytes,
                required String mimeType,
                Value<int> rowid = const Value.absent(),
              }) => SoundBlobsCompanion.insert(
                id: id,
                bytes: bytes,
                mimeType: mimeType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SoundBlobsTable, SoundBlob>(table),
                  BaseReferences<_$StoreDatabase, $SoundBlobsTable, SoundBlob>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SoundBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$StoreDatabase,
      $SoundBlobsTable,
      SoundBlob,
      $$SoundBlobsTableFilterComposer,
      $$SoundBlobsTableOrderingComposer,
      $$SoundBlobsTableAnnotationComposer,
      $$SoundBlobsTableCreateCompanionBuilder,
      $$SoundBlobsTableUpdateCompanionBuilder,
      (SoundBlob, BaseReferences<_$StoreDatabase, $SoundBlobsTable, SoundBlob>),
      SoundBlob,
      PrefetchHooks Function()
    >;

class $StoreDatabaseManager {
  final _$StoreDatabase _db;
  $StoreDatabaseManager(this._db);
  $$StoredDocumentsTableTableManager get storedDocuments =>
      $$StoredDocumentsTableTableManager(_db, _db.storedDocuments);
  $$SoundBlobsTableTableManager get soundBlobs =>
      $$SoundBlobsTableTableManager(_db, _db.soundBlobs);
}
