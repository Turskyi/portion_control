// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BodyWeightEntriesTable extends BodyWeightEntries
    with TableInfo<$BodyWeightEntriesTable, BodyWeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, weight, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weight_entries';
  @override
  VerificationContext validateIntegrity(Insertable<BodyWeightEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyWeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeightEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $BodyWeightEntriesTable createAlias(String alias) {
    return $BodyWeightEntriesTable(attachedDatabase, alias);
  }
}

class BodyWeightEntry extends DataClass implements Insertable<BodyWeightEntry> {
  final int id;

  /// For storing [weight] (in kilograms or pounds).
  final double weight;

  /// The [date] the weight was recorded.
  final DateTime date;
  const BodyWeightEntry(
      {required this.id, required this.weight, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weight'] = Variable<double>(weight);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  BodyWeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightEntriesCompanion(
      id: Value(id),
      weight: Value(weight),
      date: Value(date),
    );
  }

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeightEntry(
      id: serializer.fromJson<int>(json['id']),
      weight: serializer.fromJson<double>(json['weight']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weight': serializer.toJson<double>(weight),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  BodyWeightEntry copyWith({int? id, double? weight, DateTime? date}) =>
      BodyWeightEntry(
        id: id ?? this.id,
        weight: weight ?? this.weight,
        date: date ?? this.date,
      );
  BodyWeightEntry copyWithCompanion(BodyWeightEntriesCompanion data) {
    return BodyWeightEntry(
      id: data.id.present ? data.id.value : this.id,
      weight: data.weight.present ? data.weight.value : this.weight,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightEntry(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weight, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeightEntry &&
          other.id == this.id &&
          other.weight == this.weight &&
          other.date == this.date);
}

class BodyWeightEntriesCompanion extends UpdateCompanion<BodyWeightEntry> {
  final Value<int> id;
  final Value<double> weight;
  final Value<DateTime> date;
  const BodyWeightEntriesCompanion({
    this.id = const Value.absent(),
    this.weight = const Value.absent(),
    this.date = const Value.absent(),
  });
  BodyWeightEntriesCompanion.insert({
    this.id = const Value.absent(),
    required double weight,
    required DateTime date,
  })  : weight = Value(weight),
        date = Value(date);
  static Insertable<BodyWeightEntry> custom({
    Expression<int>? id,
    Expression<double>? weight,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weight != null) 'weight': weight,
      if (date != null) 'date': date,
    });
  }

  BodyWeightEntriesCompanion copyWith(
      {Value<int>? id, Value<double>? weight, Value<DateTime>? date}) {
    return BodyWeightEntriesCompanion(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BodyWeightEntriesTable bodyWeightEntries =
      $BodyWeightEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [bodyWeightEntries];
}

typedef $$BodyWeightEntriesTableCreateCompanionBuilder
    = BodyWeightEntriesCompanion Function({
  Value<int> id,
  required double weight,
  required DateTime date,
});
typedef $$BodyWeightEntriesTableUpdateCompanionBuilder
    = BodyWeightEntriesCompanion Function({
  Value<int> id,
  Value<double> weight,
  Value<DateTime> date,
});

class $$BodyWeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightEntriesTable> {
  $$BodyWeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));
}

class $$BodyWeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightEntriesTable> {
  $$BodyWeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));
}

class $$BodyWeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightEntriesTable> {
  $$BodyWeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$BodyWeightEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BodyWeightEntriesTable,
    BodyWeightEntry,
    $$BodyWeightEntriesTableFilterComposer,
    $$BodyWeightEntriesTableOrderingComposer,
    $$BodyWeightEntriesTableAnnotationComposer,
    $$BodyWeightEntriesTableCreateCompanionBuilder,
    $$BodyWeightEntriesTableUpdateCompanionBuilder,
    (
      BodyWeightEntry,
      BaseReferences<_$AppDatabase, $BodyWeightEntriesTable, BodyWeightEntry>
    ),
    BodyWeightEntry,
    PrefetchHooks Function()> {
  $$BodyWeightEntriesTableTableManager(
      _$AppDatabase db, $BodyWeightEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              BodyWeightEntriesCompanion(
            id: id,
            weight: weight,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double weight,
            required DateTime date,
          }) =>
              BodyWeightEntriesCompanion.insert(
            id: id,
            weight: weight,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BodyWeightEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BodyWeightEntriesTable,
    BodyWeightEntry,
    $$BodyWeightEntriesTableFilterComposer,
    $$BodyWeightEntriesTableOrderingComposer,
    $$BodyWeightEntriesTableAnnotationComposer,
    $$BodyWeightEntriesTableCreateCompanionBuilder,
    $$BodyWeightEntriesTableUpdateCompanionBuilder,
    (
      BodyWeightEntry,
      BaseReferences<_$AppDatabase, $BodyWeightEntriesTable, BodyWeightEntry>
    ),
    BodyWeightEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BodyWeightEntriesTableTableManager get bodyWeightEntries =>
      $$BodyWeightEntriesTableTableManager(_db, _db.bodyWeightEntries);
}
