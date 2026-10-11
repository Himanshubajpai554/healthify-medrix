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

abstract class HospitalInfoRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalInfoRecord._({
    this.id,
    required this.hospitalKey,
    required this.name,
    required this.code,
    required this.tagline,
    required this.address,
    required this.phone,
    required this.email,
    required this.emergencyHotline,
    required this.totalBedCapacity,
    required this.icuCapacity,
    required this.activeDoctorCount,
    required this.totalStaffCount,
  });

  factory HospitalInfoRecord({
    int? id,
    required String hospitalKey,
    required String name,
    required String code,
    required String tagline,
    required String address,
    required String phone,
    required String email,
    required String emergencyHotline,
    required int totalBedCapacity,
    required int icuCapacity,
    required int activeDoctorCount,
    required int totalStaffCount,
  }) = _HospitalInfoRecordImpl;

  factory HospitalInfoRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return HospitalInfoRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      name: jsonSerialization['name'] as String,
      code: jsonSerialization['code'] as String,
      tagline: jsonSerialization['tagline'] as String,
      address: jsonSerialization['address'] as String,
      phone: jsonSerialization['phone'] as String,
      email: jsonSerialization['email'] as String,
      emergencyHotline: jsonSerialization['emergencyHotline'] as String,
      totalBedCapacity: jsonSerialization['totalBedCapacity'] as int,
      icuCapacity: jsonSerialization['icuCapacity'] as int,
      activeDoctorCount: jsonSerialization['activeDoctorCount'] as int,
      totalStaffCount: jsonSerialization['totalStaffCount'] as int,
    );
  }

  static final t = HospitalInfoRecordTable();

  static const db = HospitalInfoRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String name;

  String code;

  String tagline;

  String address;

  String phone;

  String email;

  String emergencyHotline;

  int totalBedCapacity;

  int icuCapacity;

  int activeDoctorCount;

  int totalStaffCount;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalInfoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalInfoRecord copyWith({
    int? id,
    String? hospitalKey,
    String? name,
    String? code,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? emergencyHotline,
    int? totalBedCapacity,
    int? icuCapacity,
    int? activeDoctorCount,
    int? totalStaffCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalInfoRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'name': name,
      'code': code,
      'tagline': tagline,
      'address': address,
      'phone': phone,
      'email': email,
      'emergencyHotline': emergencyHotline,
      'totalBedCapacity': totalBedCapacity,
      'icuCapacity': icuCapacity,
      'activeDoctorCount': activeDoctorCount,
      'totalStaffCount': totalStaffCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalInfoRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'name': name,
      'code': code,
      'tagline': tagline,
      'address': address,
      'phone': phone,
      'email': email,
      'emergencyHotline': emergencyHotline,
      'totalBedCapacity': totalBedCapacity,
      'icuCapacity': icuCapacity,
      'activeDoctorCount': activeDoctorCount,
      'totalStaffCount': totalStaffCount,
    };
  }

  static HospitalInfoRecordInclude include() {
    return HospitalInfoRecordInclude._();
  }

  static HospitalInfoRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalInfoRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalInfoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalInfoRecordTable>? orderByList,
    HospitalInfoRecordInclude? include,
  }) {
    return HospitalInfoRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalInfoRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalInfoRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalInfoRecordImpl extends HospitalInfoRecord {
  _HospitalInfoRecordImpl({
    int? id,
    required String hospitalKey,
    required String name,
    required String code,
    required String tagline,
    required String address,
    required String phone,
    required String email,
    required String emergencyHotline,
    required int totalBedCapacity,
    required int icuCapacity,
    required int activeDoctorCount,
    required int totalStaffCount,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         name: name,
         code: code,
         tagline: tagline,
         address: address,
         phone: phone,
         email: email,
         emergencyHotline: emergencyHotline,
         totalBedCapacity: totalBedCapacity,
         icuCapacity: icuCapacity,
         activeDoctorCount: activeDoctorCount,
         totalStaffCount: totalStaffCount,
       );

  /// Returns a shallow copy of this [HospitalInfoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalInfoRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? name,
    String? code,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? emergencyHotline,
    int? totalBedCapacity,
    int? icuCapacity,
    int? activeDoctorCount,
    int? totalStaffCount,
  }) {
    return HospitalInfoRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      name: name ?? this.name,
      code: code ?? this.code,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emergencyHotline: emergencyHotline ?? this.emergencyHotline,
      totalBedCapacity: totalBedCapacity ?? this.totalBedCapacity,
      icuCapacity: icuCapacity ?? this.icuCapacity,
      activeDoctorCount: activeDoctorCount ?? this.activeDoctorCount,
      totalStaffCount: totalStaffCount ?? this.totalStaffCount,
    );
  }
}

class HospitalInfoRecordUpdateTable
    extends _i1.UpdateTable<HospitalInfoRecordTable> {
  HospitalInfoRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> code(String value) => _i1.ColumnValue(
    table.code,
    value,
  );

  _i1.ColumnValue<String, String> tagline(String value) => _i1.ColumnValue(
    table.tagline,
    value,
  );

  _i1.ColumnValue<String, String> address(String value) => _i1.ColumnValue(
    table.address,
    value,
  );

  _i1.ColumnValue<String, String> phone(String value) => _i1.ColumnValue(
    table.phone,
    value,
  );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> emergencyHotline(String value) =>
      _i1.ColumnValue(
        table.emergencyHotline,
        value,
      );

  _i1.ColumnValue<int, int> totalBedCapacity(int value) => _i1.ColumnValue(
    table.totalBedCapacity,
    value,
  );

  _i1.ColumnValue<int, int> icuCapacity(int value) => _i1.ColumnValue(
    table.icuCapacity,
    value,
  );

  _i1.ColumnValue<int, int> activeDoctorCount(int value) => _i1.ColumnValue(
    table.activeDoctorCount,
    value,
  );

  _i1.ColumnValue<int, int> totalStaffCount(int value) => _i1.ColumnValue(
    table.totalStaffCount,
    value,
  );
}

class HospitalInfoRecordTable extends _i1.Table<int?> {
  HospitalInfoRecordTable({super.tableRelation})
    : super(tableName: 'hospital_info') {
    updateTable = HospitalInfoRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    code = _i1.ColumnString(
      'code',
      this,
    );
    tagline = _i1.ColumnString(
      'tagline',
      this,
    );
    address = _i1.ColumnString(
      'address',
      this,
    );
    phone = _i1.ColumnString(
      'phone',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    emergencyHotline = _i1.ColumnString(
      'emergencyHotline',
      this,
    );
    totalBedCapacity = _i1.ColumnInt(
      'totalBedCapacity',
      this,
    );
    icuCapacity = _i1.ColumnInt(
      'icuCapacity',
      this,
    );
    activeDoctorCount = _i1.ColumnInt(
      'activeDoctorCount',
      this,
    );
    totalStaffCount = _i1.ColumnInt(
      'totalStaffCount',
      this,
    );
  }

  late final HospitalInfoRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString name;

  late final _i1.ColumnString code;

  late final _i1.ColumnString tagline;

  late final _i1.ColumnString address;

  late final _i1.ColumnString phone;

  late final _i1.ColumnString email;

  late final _i1.ColumnString emergencyHotline;

  late final _i1.ColumnInt totalBedCapacity;

  late final _i1.ColumnInt icuCapacity;

  late final _i1.ColumnInt activeDoctorCount;

  late final _i1.ColumnInt totalStaffCount;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    name,
    code,
    tagline,
    address,
    phone,
    email,
    emergencyHotline,
    totalBedCapacity,
    icuCapacity,
    activeDoctorCount,
    totalStaffCount,
  ];
}

class HospitalInfoRecordInclude extends _i1.IncludeObject {
  HospitalInfoRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalInfoRecord.t;
}

class HospitalInfoRecordIncludeList extends _i1.IncludeList {
  HospitalInfoRecordIncludeList._({
    _i1.WhereExpressionBuilder<HospitalInfoRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalInfoRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalInfoRecord.t;
}

class HospitalInfoRecordRepository {
  const HospitalInfoRecordRepository._();

  /// Returns a list of [HospitalInfoRecord]s matching the given query parameters.
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
  Future<List<HospitalInfoRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalInfoRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalInfoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalInfoRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalInfoRecord>(
      where: where?.call(HospitalInfoRecord.t),
      orderBy: orderBy?.call(HospitalInfoRecord.t),
      orderByList: orderByList?.call(HospitalInfoRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalInfoRecord] matching the given query parameters.
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
  Future<HospitalInfoRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalInfoRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalInfoRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalInfoRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalInfoRecord>(
      where: where?.call(HospitalInfoRecord.t),
      orderBy: orderBy?.call(HospitalInfoRecord.t),
      orderByList: orderByList?.call(HospitalInfoRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalInfoRecord] by its [id] or null if no such row exists.
  Future<HospitalInfoRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalInfoRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalInfoRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalInfoRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalInfoRecord>> insert(
    _i1.DatabaseSession session,
    List<HospitalInfoRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalInfoRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalInfoRecord] and returns the inserted row.
  ///
  /// The returned [HospitalInfoRecord] will have its `id` field set.
  Future<HospitalInfoRecord> insertRow(
    _i1.DatabaseSession session,
    HospitalInfoRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalInfoRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalInfoRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalInfoRecord>> update(
    _i1.DatabaseSession session,
    List<HospitalInfoRecord> rows, {
    _i1.ColumnSelections<HospitalInfoRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalInfoRecord>(
      rows,
      columns: columns?.call(HospitalInfoRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalInfoRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalInfoRecord> updateRow(
    _i1.DatabaseSession session,
    HospitalInfoRecord row, {
    _i1.ColumnSelections<HospitalInfoRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalInfoRecord>(
      row,
      columns: columns?.call(HospitalInfoRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalInfoRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalInfoRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalInfoRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalInfoRecord>(
      id,
      columnValues: columnValues(HospitalInfoRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalInfoRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalInfoRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalInfoRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalInfoRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalInfoRecordTable>? orderBy,
    _i1.OrderByListBuilder<HospitalInfoRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalInfoRecord>(
      columnValues: columnValues(HospitalInfoRecord.t.updateTable),
      where: where(HospitalInfoRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalInfoRecord.t),
      orderByList: orderByList?.call(HospitalInfoRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalInfoRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalInfoRecord>> delete(
    _i1.DatabaseSession session,
    List<HospitalInfoRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalInfoRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalInfoRecord].
  Future<HospitalInfoRecord> deleteRow(
    _i1.DatabaseSession session,
    HospitalInfoRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalInfoRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalInfoRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalInfoRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalInfoRecord>(
      where: where(HospitalInfoRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalInfoRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalInfoRecord>(
      where: where?.call(HospitalInfoRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalInfoRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalInfoRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalInfoRecord>(
      where: where(HospitalInfoRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
