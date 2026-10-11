/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;

abstract class HospitalOperationalRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalOperationalRecord._({
    this.id,
    required this.hospitalKey,
    required this.collection,
    required this.recordKey,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HospitalOperationalRecord({
    int? id,
    required String hospitalKey,
    required String collection,
    required String recordKey,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HospitalOperationalRecordImpl;

  factory HospitalOperationalRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalOperationalRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      collection: jsonSerialization['collection'] as String,
      recordKey: jsonSerialization['recordKey'] as String,
      payload: jsonSerialization['payload'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = HospitalOperationalRecordTable();

  static const db = HospitalOperationalRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String collection;

  String recordKey;

  String payload;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalOperationalRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalOperationalRecord copyWith({
    int? id,
    String? hospitalKey,
    String? collection,
    String? recordKey,
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalOperationalRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'collection': collection,
      'recordKey': recordKey,
      'payload': payload,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalOperationalRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'collection': collection,
      'recordKey': recordKey,
      'payload': payload,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static HospitalOperationalRecordInclude include() {
    return HospitalOperationalRecordInclude._();
  }

  static HospitalOperationalRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalOperationalRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalOperationalRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalOperationalRecordTable>? orderByList,
    HospitalOperationalRecordInclude? include,
  }) {
    return HospitalOperationalRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalOperationalRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalOperationalRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalOperationalRecordImpl extends HospitalOperationalRecord {
  _HospitalOperationalRecordImpl({
    int? id,
    required String hospitalKey,
    required String collection,
    required String recordKey,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         collection: collection,
         recordKey: recordKey,
         payload: payload,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [HospitalOperationalRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalOperationalRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? collection,
    String? recordKey,
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HospitalOperationalRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      collection: collection ?? this.collection,
      recordKey: recordKey ?? this.recordKey,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HospitalOperationalRecordUpdateTable
    extends _i1.UpdateTable<HospitalOperationalRecordTable> {
  HospitalOperationalRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> collection(String value) => _i1.ColumnValue(
    table.collection,
    value,
  );

  _i1.ColumnValue<String, String> recordKey(String value) => _i1.ColumnValue(
    table.recordKey,
    value,
  );

  _i1.ColumnValue<String, String> payload(String value) => _i1.ColumnValue(
    table.payload,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class HospitalOperationalRecordTable extends _i1.Table<int?> {
  HospitalOperationalRecordTable({super.tableRelation})
    : super(tableName: 'hospital_operational_record') {
    updateTable = HospitalOperationalRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    collection = _i1.ColumnString(
      'collection',
      this,
    );
    recordKey = _i1.ColumnString(
      'recordKey',
      this,
    );
    payload = _i1.ColumnString(
      'payload',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final HospitalOperationalRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString collection;

  late final _i1.ColumnString recordKey;

  late final _i1.ColumnString payload;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    collection,
    recordKey,
    payload,
    createdAt,
    updatedAt,
  ];
}

class HospitalOperationalRecordInclude extends _i1.IncludeObject {
  HospitalOperationalRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalOperationalRecord.t;
}

class HospitalOperationalRecordIncludeList extends _i1.IncludeList {
  HospitalOperationalRecordIncludeList._({
    _i1.WhereExpressionBuilder<HospitalOperationalRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalOperationalRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalOperationalRecord.t;
}

class HospitalOperationalRecordRepository {
  const HospitalOperationalRecordRepository._();

  /// Returns a list of [HospitalOperationalRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<HospitalOperationalRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalOperationalRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalOperationalRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalOperationalRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalOperationalRecord>(
      where: where?.call(HospitalOperationalRecord.t),
      orderBy: orderBy?.call(HospitalOperationalRecord.t),
      orderByList: orderByList?.call(HospitalOperationalRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalOperationalRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<HospitalOperationalRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalOperationalRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalOperationalRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalOperationalRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalOperationalRecord>(
      where: where?.call(HospitalOperationalRecord.t),
      orderBy: orderBy?.call(HospitalOperationalRecord.t),
      orderByList: orderByList?.call(HospitalOperationalRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalOperationalRecord] by its [id] or null if no such row exists.
  Future<HospitalOperationalRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalOperationalRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalOperationalRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalOperationalRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalOperationalRecord>> insert(
    _i1.DatabaseSession session,
    List<HospitalOperationalRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalOperationalRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalOperationalRecord] and returns the inserted row.
  ///
  /// The returned [HospitalOperationalRecord] will have its `id` field set.
  Future<HospitalOperationalRecord> insertRow(
    _i1.DatabaseSession session,
    HospitalOperationalRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalOperationalRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalOperationalRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalOperationalRecord>> update(
    _i1.DatabaseSession session,
    List<HospitalOperationalRecord> rows, {
    _i1.ColumnSelections<HospitalOperationalRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalOperationalRecord>(
      rows,
      columns: columns?.call(HospitalOperationalRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalOperationalRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalOperationalRecord> updateRow(
    _i1.DatabaseSession session,
    HospitalOperationalRecord row, {
    _i1.ColumnSelections<HospitalOperationalRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalOperationalRecord>(
      row,
      columns: columns?.call(HospitalOperationalRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalOperationalRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalOperationalRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalOperationalRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalOperationalRecord>(
      id,
      columnValues: columnValues(HospitalOperationalRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalOperationalRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalOperationalRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalOperationalRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalOperationalRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalOperationalRecordTable>? orderBy,
    _i1.OrderByListBuilder<HospitalOperationalRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalOperationalRecord>(
      columnValues: columnValues(HospitalOperationalRecord.t.updateTable),
      where: where(HospitalOperationalRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalOperationalRecord.t),
      orderByList: orderByList?.call(HospitalOperationalRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalOperationalRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalOperationalRecord>> delete(
    _i1.DatabaseSession session,
    List<HospitalOperationalRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalOperationalRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalOperationalRecord].
  Future<HospitalOperationalRecord> deleteRow(
    _i1.DatabaseSession session,
    HospitalOperationalRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalOperationalRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalOperationalRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalOperationalRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalOperationalRecord>(
      where: where(HospitalOperationalRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalOperationalRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalOperationalRecord>(
      where: where?.call(HospitalOperationalRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalOperationalRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalOperationalRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalOperationalRecord>(
      where: where(HospitalOperationalRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
