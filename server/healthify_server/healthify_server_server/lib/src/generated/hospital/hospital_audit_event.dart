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

abstract class HospitalAuditEvent
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalAuditEvent._({
    this.id,
    required this.hospitalKey,
    required this.actorUserIdentifier,
    required this.action,
    required this.collection,
    required this.recordKey,
    required this.occurredAt,
    required this.details,
  });

  factory HospitalAuditEvent({
    int? id,
    required String hospitalKey,
    required String actorUserIdentifier,
    required String action,
    required String collection,
    required String recordKey,
    required DateTime occurredAt,
    required String details,
  }) = _HospitalAuditEventImpl;

  factory HospitalAuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return HospitalAuditEvent(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      actorUserIdentifier: jsonSerialization['actorUserIdentifier'] as String,
      action: jsonSerialization['action'] as String,
      collection: jsonSerialization['collection'] as String,
      recordKey: jsonSerialization['recordKey'] as String,
      occurredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      details: jsonSerialization['details'] as String,
    );
  }

  static final t = HospitalAuditEventTable();

  static const db = HospitalAuditEventRepository._();

  @override
  int? id;

  String hospitalKey;

  String actorUserIdentifier;

  String action;

  String collection;

  String recordKey;

  DateTime occurredAt;

  String details;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalAuditEvent copyWith({
    int? id,
    String? hospitalKey,
    String? actorUserIdentifier,
    String? action,
    String? collection,
    String? recordKey,
    DateTime? occurredAt,
    String? details,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalAuditEvent',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'actorUserIdentifier': actorUserIdentifier,
      'action': action,
      'collection': collection,
      'recordKey': recordKey,
      'occurredAt': occurredAt.toJson(),
      'details': details,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalAuditEvent',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'actorUserIdentifier': actorUserIdentifier,
      'action': action,
      'collection': collection,
      'recordKey': recordKey,
      'occurredAt': occurredAt.toJson(),
      'details': details,
    };
  }

  static HospitalAuditEventInclude include() {
    return HospitalAuditEventInclude._();
  }

  static HospitalAuditEventIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalAuditEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalAuditEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalAuditEventTable>? orderByList,
    HospitalAuditEventInclude? include,
  }) {
    return HospitalAuditEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalAuditEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalAuditEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalAuditEventImpl extends HospitalAuditEvent {
  _HospitalAuditEventImpl({
    int? id,
    required String hospitalKey,
    required String actorUserIdentifier,
    required String action,
    required String collection,
    required String recordKey,
    required DateTime occurredAt,
    required String details,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         actorUserIdentifier: actorUserIdentifier,
         action: action,
         collection: collection,
         recordKey: recordKey,
         occurredAt: occurredAt,
         details: details,
       );

  /// Returns a shallow copy of this [HospitalAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalAuditEvent copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? actorUserIdentifier,
    String? action,
    String? collection,
    String? recordKey,
    DateTime? occurredAt,
    String? details,
  }) {
    return HospitalAuditEvent(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      actorUserIdentifier: actorUserIdentifier ?? this.actorUserIdentifier,
      action: action ?? this.action,
      collection: collection ?? this.collection,
      recordKey: recordKey ?? this.recordKey,
      occurredAt: occurredAt ?? this.occurredAt,
      details: details ?? this.details,
    );
  }
}

class HospitalAuditEventUpdateTable
    extends _i1.UpdateTable<HospitalAuditEventTable> {
  HospitalAuditEventUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> actorUserIdentifier(String value) =>
      _i1.ColumnValue(
        table.actorUserIdentifier,
        value,
      );

  _i1.ColumnValue<String, String> action(String value) => _i1.ColumnValue(
    table.action,
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

  _i1.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _i1.ColumnValue(
        table.occurredAt,
        value,
      );

  _i1.ColumnValue<String, String> details(String value) => _i1.ColumnValue(
    table.details,
    value,
  );
}

class HospitalAuditEventTable extends _i1.Table<int?> {
  HospitalAuditEventTable({super.tableRelation})
    : super(tableName: 'hospital_audit_event') {
    updateTable = HospitalAuditEventUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    actorUserIdentifier = _i1.ColumnString(
      'actorUserIdentifier',
      this,
    );
    action = _i1.ColumnString(
      'action',
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
    occurredAt = _i1.ColumnDateTime(
      'occurredAt',
      this,
    );
    details = _i1.ColumnString(
      'details',
      this,
    );
  }

  late final HospitalAuditEventUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString actorUserIdentifier;

  late final _i1.ColumnString action;

  late final _i1.ColumnString collection;

  late final _i1.ColumnString recordKey;

  late final _i1.ColumnDateTime occurredAt;

  late final _i1.ColumnString details;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    actorUserIdentifier,
    action,
    collection,
    recordKey,
    occurredAt,
    details,
  ];
}

class HospitalAuditEventInclude extends _i1.IncludeObject {
  HospitalAuditEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalAuditEvent.t;
}

class HospitalAuditEventIncludeList extends _i1.IncludeList {
  HospitalAuditEventIncludeList._({
    _i1.WhereExpressionBuilder<HospitalAuditEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalAuditEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalAuditEvent.t;
}

class HospitalAuditEventRepository {
  const HospitalAuditEventRepository._();

  /// Returns a list of [HospitalAuditEvent]s matching the given query parameters.
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
  Future<List<HospitalAuditEvent>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalAuditEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalAuditEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalAuditEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalAuditEvent>(
      where: where?.call(HospitalAuditEvent.t),
      orderBy: orderBy?.call(HospitalAuditEvent.t),
      orderByList: orderByList?.call(HospitalAuditEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalAuditEvent] matching the given query parameters.
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
  Future<HospitalAuditEvent?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalAuditEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalAuditEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalAuditEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalAuditEvent>(
      where: where?.call(HospitalAuditEvent.t),
      orderBy: orderBy?.call(HospitalAuditEvent.t),
      orderByList: orderByList?.call(HospitalAuditEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalAuditEvent] by its [id] or null if no such row exists.
  Future<HospitalAuditEvent?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalAuditEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalAuditEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalAuditEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalAuditEvent>> insert(
    _i1.DatabaseSession session,
    List<HospitalAuditEvent> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalAuditEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalAuditEvent] and returns the inserted row.
  ///
  /// The returned [HospitalAuditEvent] will have its `id` field set.
  Future<HospitalAuditEvent> insertRow(
    _i1.DatabaseSession session,
    HospitalAuditEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalAuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalAuditEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalAuditEvent>> update(
    _i1.DatabaseSession session,
    List<HospitalAuditEvent> rows, {
    _i1.ColumnSelections<HospitalAuditEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalAuditEvent>(
      rows,
      columns: columns?.call(HospitalAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalAuditEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalAuditEvent> updateRow(
    _i1.DatabaseSession session,
    HospitalAuditEvent row, {
    _i1.ColumnSelections<HospitalAuditEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalAuditEvent>(
      row,
      columns: columns?.call(HospitalAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalAuditEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalAuditEvent?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalAuditEventUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalAuditEvent>(
      id,
      columnValues: columnValues(HospitalAuditEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalAuditEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalAuditEvent>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalAuditEventUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalAuditEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalAuditEventTable>? orderBy,
    _i1.OrderByListBuilder<HospitalAuditEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalAuditEvent>(
      columnValues: columnValues(HospitalAuditEvent.t.updateTable),
      where: where(HospitalAuditEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalAuditEvent.t),
      orderByList: orderByList?.call(HospitalAuditEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalAuditEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalAuditEvent>> delete(
    _i1.DatabaseSession session,
    List<HospitalAuditEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalAuditEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalAuditEvent].
  Future<HospitalAuditEvent> deleteRow(
    _i1.DatabaseSession session,
    HospitalAuditEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalAuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalAuditEvent>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalAuditEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalAuditEvent>(
      where: where(HospitalAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalAuditEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalAuditEvent>(
      where: where?.call(HospitalAuditEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalAuditEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalAuditEventTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalAuditEvent>(
      where: where(HospitalAuditEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
