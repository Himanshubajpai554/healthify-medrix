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

abstract class HospitalUserAccessRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalUserAccessRecord._({
    this.id,
    required this.hospitalKey,
    required this.userKey,
    required this.userName,
    required this.email,
    required this.role,
    required this.department,
    required this.isActive,
    required this.lastActive,
  });

  factory HospitalUserAccessRecord({
    int? id,
    required String hospitalKey,
    required String userKey,
    required String userName,
    required String email,
    required String role,
    required String department,
    required bool isActive,
    required DateTime lastActive,
  }) = _HospitalUserAccessRecordImpl;

  factory HospitalUserAccessRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalUserAccessRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      userKey: jsonSerialization['userKey'] as String,
      userName: jsonSerialization['userName'] as String,
      email: jsonSerialization['email'] as String,
      role: jsonSerialization['role'] as String,
      department: jsonSerialization['department'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      lastActive: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActive'],
      ),
    );
  }

  static final t = HospitalUserAccessRecordTable();

  static const db = HospitalUserAccessRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String userKey;

  String userName;

  String email;

  String role;

  String department;

  bool isActive;

  DateTime lastActive;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalUserAccessRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalUserAccessRecord copyWith({
    int? id,
    String? hospitalKey,
    String? userKey,
    String? userName,
    String? email,
    String? role,
    String? department,
    bool? isActive,
    DateTime? lastActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalUserAccessRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'userKey': userKey,
      'userName': userName,
      'email': email,
      'role': role,
      'department': department,
      'isActive': isActive,
      'lastActive': lastActive.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalUserAccessRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'userKey': userKey,
      'userName': userName,
      'email': email,
      'role': role,
      'department': department,
      'isActive': isActive,
      'lastActive': lastActive.toJson(),
    };
  }

  static HospitalUserAccessRecordInclude include() {
    return HospitalUserAccessRecordInclude._();
  }

  static HospitalUserAccessRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalUserAccessRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalUserAccessRecordTable>? orderByList,
    HospitalUserAccessRecordInclude? include,
  }) {
    return HospitalUserAccessRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalUserAccessRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalUserAccessRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalUserAccessRecordImpl extends HospitalUserAccessRecord {
  _HospitalUserAccessRecordImpl({
    int? id,
    required String hospitalKey,
    required String userKey,
    required String userName,
    required String email,
    required String role,
    required String department,
    required bool isActive,
    required DateTime lastActive,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         userKey: userKey,
         userName: userName,
         email: email,
         role: role,
         department: department,
         isActive: isActive,
         lastActive: lastActive,
       );

  /// Returns a shallow copy of this [HospitalUserAccessRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalUserAccessRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? userKey,
    String? userName,
    String? email,
    String? role,
    String? department,
    bool? isActive,
    DateTime? lastActive,
  }) {
    return HospitalUserAccessRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      userKey: userKey ?? this.userKey,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class HospitalUserAccessRecordUpdateTable
    extends _i1.UpdateTable<HospitalUserAccessRecordTable> {
  HospitalUserAccessRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> userKey(String value) => _i1.ColumnValue(
    table.userKey,
    value,
  );

  _i1.ColumnValue<String, String> userName(String value) => _i1.ColumnValue(
    table.userName,
    value,
  );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<String, String> department(String value) => _i1.ColumnValue(
    table.department,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastActive(DateTime value) =>
      _i1.ColumnValue(
        table.lastActive,
        value,
      );
}

class HospitalUserAccessRecordTable extends _i1.Table<int?> {
  HospitalUserAccessRecordTable({super.tableRelation})
    : super(tableName: 'hospital_user_access') {
    updateTable = HospitalUserAccessRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    userKey = _i1.ColumnString(
      'userKey',
      this,
    );
    userName = _i1.ColumnString(
      'userName',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
    );
    department = _i1.ColumnString(
      'department',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
    lastActive = _i1.ColumnDateTime(
      'lastActive',
      this,
    );
  }

  late final HospitalUserAccessRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString userKey;

  late final _i1.ColumnString userName;

  late final _i1.ColumnString email;

  late final _i1.ColumnString role;

  late final _i1.ColumnString department;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime lastActive;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    userKey,
    userName,
    email,
    role,
    department,
    isActive,
    lastActive,
  ];
}

class HospitalUserAccessRecordInclude extends _i1.IncludeObject {
  HospitalUserAccessRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalUserAccessRecord.t;
}

class HospitalUserAccessRecordIncludeList extends _i1.IncludeList {
  HospitalUserAccessRecordIncludeList._({
    _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalUserAccessRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalUserAccessRecord.t;
}

class HospitalUserAccessRecordRepository {
  const HospitalUserAccessRecordRepository._();

  /// Returns a list of [HospitalUserAccessRecord]s matching the given query parameters.
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
  Future<List<HospitalUserAccessRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalUserAccessRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalUserAccessRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalUserAccessRecord>(
      where: where?.call(HospitalUserAccessRecord.t),
      orderBy: orderBy?.call(HospitalUserAccessRecord.t),
      orderByList: orderByList?.call(HospitalUserAccessRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalUserAccessRecord] matching the given query parameters.
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
  Future<HospitalUserAccessRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalUserAccessRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalUserAccessRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalUserAccessRecord>(
      where: where?.call(HospitalUserAccessRecord.t),
      orderBy: orderBy?.call(HospitalUserAccessRecord.t),
      orderByList: orderByList?.call(HospitalUserAccessRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalUserAccessRecord] by its [id] or null if no such row exists.
  Future<HospitalUserAccessRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalUserAccessRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalUserAccessRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalUserAccessRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalUserAccessRecord>> insert(
    _i1.DatabaseSession session,
    List<HospitalUserAccessRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalUserAccessRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalUserAccessRecord] and returns the inserted row.
  ///
  /// The returned [HospitalUserAccessRecord] will have its `id` field set.
  Future<HospitalUserAccessRecord> insertRow(
    _i1.DatabaseSession session,
    HospitalUserAccessRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalUserAccessRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalUserAccessRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalUserAccessRecord>> update(
    _i1.DatabaseSession session,
    List<HospitalUserAccessRecord> rows, {
    _i1.ColumnSelections<HospitalUserAccessRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalUserAccessRecord>(
      rows,
      columns: columns?.call(HospitalUserAccessRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalUserAccessRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalUserAccessRecord> updateRow(
    _i1.DatabaseSession session,
    HospitalUserAccessRecord row, {
    _i1.ColumnSelections<HospitalUserAccessRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalUserAccessRecord>(
      row,
      columns: columns?.call(HospitalUserAccessRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalUserAccessRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalUserAccessRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalUserAccessRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalUserAccessRecord>(
      id,
      columnValues: columnValues(HospitalUserAccessRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalUserAccessRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalUserAccessRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalUserAccessRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalUserAccessRecordTable>? orderBy,
    _i1.OrderByListBuilder<HospitalUserAccessRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalUserAccessRecord>(
      columnValues: columnValues(HospitalUserAccessRecord.t.updateTable),
      where: where(HospitalUserAccessRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalUserAccessRecord.t),
      orderByList: orderByList?.call(HospitalUserAccessRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalUserAccessRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalUserAccessRecord>> delete(
    _i1.DatabaseSession session,
    List<HospitalUserAccessRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalUserAccessRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalUserAccessRecord].
  Future<HospitalUserAccessRecord> deleteRow(
    _i1.DatabaseSession session,
    HospitalUserAccessRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalUserAccessRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalUserAccessRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalUserAccessRecord>(
      where: where(HospitalUserAccessRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalUserAccessRecord>(
      where: where?.call(HospitalUserAccessRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalUserAccessRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalUserAccessRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalUserAccessRecord>(
      where: where(HospitalUserAccessRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
