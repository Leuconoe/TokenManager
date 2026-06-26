// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TokenEntriesTable extends TokenEntries
    with TableInfo<$TokenEntriesTable, TokenEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceNameMeta =
      const VerificationMeta('serviceName');
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
      'service_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _issuedAtMeta =
      const VerificationMeta('issuedAt');
  @override
  late final GeneratedColumn<int> issuedAt = GeneratedColumn<int>(
      'issued_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serviceName,
        url,
        issuedAt,
        expiresAt,
        note,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TokenEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
          _serviceNameMeta,
          serviceName.isAcceptableOrUnknown(
              data['service_name']!, _serviceNameMeta));
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('issued_at')) {
      context.handle(_issuedAtMeta,
          issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TokenEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_name'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      issuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}issued_at']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expires_at']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TokenEntriesTable createAlias(String alias) {
    return $TokenEntriesTable(attachedDatabase, alias);
  }
}

class TokenEntryRow extends DataClass implements Insertable<TokenEntryRow> {
  final String id;
  final String serviceName;
  final String url;
  final int? issuedAt;
  final int? expiresAt;
  final String note;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const TokenEntryRow(
      {required this.id,
      required this.serviceName,
      required this.url,
      this.issuedAt,
      this.expiresAt,
      required this.note,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_name'] = Variable<String>(serviceName);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || issuedAt != null) {
      map['issued_at'] = Variable<int>(issuedAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  TokenEntriesCompanion toCompanion(bool nullToAbsent) {
    return TokenEntriesCompanion(
      id: Value(id),
      serviceName: Value(serviceName),
      url: Value(url),
      issuedAt: issuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      note: Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TokenEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenEntryRow(
      id: serializer.fromJson<String>(json['id']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      url: serializer.fromJson<String>(json['url']),
      issuedAt: serializer.fromJson<int?>(json['issuedAt']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceName': serializer.toJson<String>(serviceName),
      'url': serializer.toJson<String>(url),
      'issuedAt': serializer.toJson<int?>(issuedAt),
      'expiresAt': serializer.toJson<int?>(expiresAt),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  TokenEntryRow copyWith(
          {String? id,
          String? serviceName,
          String? url,
          Value<int?> issuedAt = const Value.absent(),
          Value<int?> expiresAt = const Value.absent(),
          String? note,
          int? createdAt,
          int? updatedAt,
          Value<int?> deletedAt = const Value.absent()}) =>
      TokenEntryRow(
        id: id ?? this.id,
        serviceName: serviceName ?? this.serviceName,
        url: url ?? this.url,
        issuedAt: issuedAt.present ? issuedAt.value : this.issuedAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  TokenEntryRow copyWithCompanion(TokenEntriesCompanion data) {
    return TokenEntryRow(
      id: data.id.present ? data.id.value : this.id,
      serviceName:
          data.serviceName.present ? data.serviceName.value : this.serviceName,
      url: data.url.present ? data.url.value : this.url,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenEntryRow(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('url: $url, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serviceName, url, issuedAt, expiresAt,
      note, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenEntryRow &&
          other.id == this.id &&
          other.serviceName == this.serviceName &&
          other.url == this.url &&
          other.issuedAt == this.issuedAt &&
          other.expiresAt == this.expiresAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TokenEntriesCompanion extends UpdateCompanion<TokenEntryRow> {
  final Value<String> id;
  final Value<String> serviceName;
  final Value<String> url;
  final Value<int?> issuedAt;
  final Value<int?> expiresAt;
  final Value<String> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const TokenEntriesCompanion({
    this.id = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.url = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokenEntriesCompanion.insert({
    required String id,
    required String serviceName,
    this.url = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        serviceName = Value(serviceName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TokenEntryRow> custom({
    Expression<String>? id,
    Expression<String>? serviceName,
    Expression<String>? url,
    Expression<int>? issuedAt,
    Expression<int>? expiresAt,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceName != null) 'service_name': serviceName,
      if (url != null) 'url': url,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokenEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? serviceName,
      Value<String>? url,
      Value<int?>? issuedAt,
      Value<int?>? expiresAt,
      Value<String>? note,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return TokenEntriesCompanion(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      url: url ?? this.url,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<int>(issuedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenEntriesCompanion(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('url: $url, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TokenEntriesTable tokenEntries = $TokenEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tokenEntries];
}

typedef $$TokenEntriesTableCreateCompanionBuilder = TokenEntriesCompanion
    Function({
  required String id,
  required String serviceName,
  Value<String> url,
  Value<int?> issuedAt,
  Value<int?> expiresAt,
  Value<String> note,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$TokenEntriesTableUpdateCompanionBuilder = TokenEntriesCompanion
    Function({
  Value<String> id,
  Value<String> serviceName,
  Value<String> url,
  Value<int?> issuedAt,
  Value<int?> expiresAt,
  Value<String> note,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$TokenEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TokenEntriesTable> {
  $$TokenEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TokenEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TokenEntriesTable> {
  $$TokenEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TokenEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokenEntriesTable> {
  $$TokenEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TokenEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TokenEntriesTable,
    TokenEntryRow,
    $$TokenEntriesTableFilterComposer,
    $$TokenEntriesTableOrderingComposer,
    $$TokenEntriesTableAnnotationComposer,
    $$TokenEntriesTableCreateCompanionBuilder,
    $$TokenEntriesTableUpdateCompanionBuilder,
    (
      TokenEntryRow,
      BaseReferences<_$AppDatabase, $TokenEntriesTable, TokenEntryRow>
    ),
    TokenEntryRow,
    PrefetchHooks Function()> {
  $$TokenEntriesTableTableManager(_$AppDatabase db, $TokenEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> serviceName = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int?> issuedAt = const Value.absent(),
            Value<int?> expiresAt = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokenEntriesCompanion(
            id: id,
            serviceName: serviceName,
            url: url,
            issuedAt: issuedAt,
            expiresAt: expiresAt,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String serviceName,
            Value<String> url = const Value.absent(),
            Value<int?> issuedAt = const Value.absent(),
            Value<int?> expiresAt = const Value.absent(),
            Value<String> note = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokenEntriesCompanion.insert(
            id: id,
            serviceName: serviceName,
            url: url,
            issuedAt: issuedAt,
            expiresAt: expiresAt,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TokenEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TokenEntriesTable,
    TokenEntryRow,
    $$TokenEntriesTableFilterComposer,
    $$TokenEntriesTableOrderingComposer,
    $$TokenEntriesTableAnnotationComposer,
    $$TokenEntriesTableCreateCompanionBuilder,
    $$TokenEntriesTableUpdateCompanionBuilder,
    (
      TokenEntryRow,
      BaseReferences<_$AppDatabase, $TokenEntriesTable, TokenEntryRow>
    ),
    TokenEntryRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TokenEntriesTableTableManager get tokenEntries =>
      $$TokenEntriesTableTableManager(_db, _db.tokenEntries);
}
