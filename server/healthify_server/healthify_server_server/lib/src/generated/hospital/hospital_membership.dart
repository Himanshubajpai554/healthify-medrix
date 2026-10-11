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

abstract class HospitalMembershipRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalMembershipRecord._({
    this.id,
    required this.hospitalKey,
    required this.userIdentifier,
    required this.role,
    required this.isActive,
  });

  factory HospitalMembershipRecord({
    int? id,
    required String hospitalKey,
    required String userIdentifier,
    required String role,
    required bool isActive,
  }) = _HospitalMembershipRecordImpl;

  factory HospitalMembershipRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalMembershipRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      userIdentifier: jsonSerialization['userIdentifier'] as String,
      role: jsonSerialization['role'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  static final t = HospitalMembershipRecordTable();

  static const db = HospitalMembershipRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String userIdentifier;

  String role;

  bool isActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalMembershipRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalMembershipRecord copyWith({
    int? id,
    String? hospitalKey,
    String? userIdentifier,
    String? role,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalMembershipRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'userIdentifier': userIdentifier,
      'role': role,
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalMembershipRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'userIdentifier': userIdentifier,
      'role': role,
      'isActive': isActive,
    };
  }

  static HospitalMembershipRecordInclude include() {
    return HospitalMembershipRecordInclude._();
  }

  static HospitalMembershipRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalMembershipRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalMembershipRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalMembershipRecordTable>? orderByList,
    HospitalMembershipRecordInclude? include,
  }) {
    return HospitalMembershipRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalMembershipRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalMembershipRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalMembershipRecordImpl extends HospitalMembershipRecord {
  _HospitalMembershipRecordImpl({
    int? id,
    required String hospitalKey,
    required String userIdentifier,
    required String role,
    required bool isActive,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         userIdentifier: userIdentifier,
         role: role,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [HospitalMembershipRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalMembershipRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? userIdentifier,
    String? role,
    bool? isActive,
  }) {
    return HospitalMembershipRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      userIdentifier: userIdentifier ?? this.userIdentifier,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}

class HospitalMembershipRecordUpdateTable
    extends _i1.UpdateTable<HospitalMembershipRecordTable> {
  HospitalMembershipRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> userIdentifier(String value) =>
      _i1.ColumnValue(
        table.userIdentifier,
        value,
      );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );
}

class HospitalMembershipRecordTable extends _i1.Table<int?> {
  HospitalMembershipRecordTable({super.tableRelation})
    : super(tableName: 'hospital_membership') {
    updateTable = HospitalMembershipRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    userIdentifier = _i1.ColumnString(
      'userIdentifier',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
  }

  late final HospitalMembershipRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString userIdentifier;

  late final _i1.ColumnString role;

  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    userIdentifier,
    role,
    isActive,
  ];
}

class HospitalMembershipRecordInclude extends _i1.IncludeObject {
  HospitalMembershipRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalMembershipRecord.t;
}

class HospitalMembershipRecordIncludeList extends _i1.IncludeList {
  HospitalMembershipRecordIncludeList._({
    _i1.WhereExpressionBuilder<HospitalMembershipRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalMembershipRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalMembershipRecord.t;
}

class HospitalMembershipRecordRepository {
  const HospitalMembershipRecordRepository._();

  /// Returns a list of [HospitalMembershipRecord]s matching the given query parameters.
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
  Future<List<HospitalMembershipRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalMembershipRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalMembershipRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalMembershipRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalMembershipRecord>(
      where: where?.call(HospitalMembershipRecord.t),
      orderBy: orderBy?.call(HospitalMembershipRecord.t),
      orderByList: orderByList?.call(HospitalMembershipRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalMembershipRecord] matching the given query parameters.
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
  Future<HospitalMembershipRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalMembershipRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalMembershipRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalMembershipRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalMembershipRecord>(
      where: where?.call(HospitalMembershipRecord.t),
      orderBy: orderBy?.call(HospitalMembershipRecord.t),
      orderByList: orderByList?.call(HospitalMembershipRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalMembershipRecord] by its [id] or null if no such row exists.
  Future<HospitalMembershipRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalMembershipRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalMembershipRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalMembershipRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalMembershipRecord>> insert(
    _i1.DatabaseSession session,
    List<HospitalMembershipRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalMembershipRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalMembershipRecord] and returns the inserted row.
  ///
  /// The returned [HospitalMembershipRecord] will have its `id` field set.
  Future<HospitalMembershipRecord> insertRow(
    _i1.DatabaseSession session,
    HospitalMembershipRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalMembershipRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalMembershipRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalMembershipRecord>> update(
    _i1.DatabaseSession session,
    List<HospitalMembershipRecord> rows, {
    _i1.ColumnSelections<HospitalMembershipRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalMembershipRecord>(
      rows,
      columns: columns?.call(HospitalMembershipRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalMembershipRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalMembershipRecord> updateRow(
    _i1.DatabaseSession session,
    HospitalMembershipRecord row, {
    _i1.ColumnSelections<HospitalMembershipRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalMembershipRecord>(
      row,
      columns: columns?.call(HospitalMembershipRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalMembershipRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalMembershipRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalMembershipRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalMembershipRecord>(
      id,
      columnValues: columnValues(HospitalMembershipRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalMembershipRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalMembershipRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalMembershipRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalMembershipRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalMembershipRecordTable>? orderBy,
    _i1.OrderByListBuilder<HospitalMembershipRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalMembershipRecord>(
      columnValues: columnValues(HospitalMembershipRecord.t.updateTable),
      where: where(HospitalMembershipRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalMembershipRecord.t),
      orderByList: orderByList?.call(HospitalMembershipRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalMembershipRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalMembershipRecord>> delete(
    _i1.DatabaseSession session,
    List<HospitalMembershipRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalMembershipRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalMembershipRecord].
  Future<HospitalMembershipRecord> deleteRow(
    _i1.DatabaseSession session,
    HospitalMembershipRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalMembershipRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalMembershipRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalMembershipRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalMembershipRecord>(
      where: where(HospitalMembershipRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalMembershipRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalMembershipRecord>(
      where: where?.call(HospitalMembershipRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalMembershipRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalMembershipRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalMembershipRecord>(
      where: where(HospitalMembershipRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
