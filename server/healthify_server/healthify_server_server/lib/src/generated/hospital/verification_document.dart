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

abstract class VerificationDocumentRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  VerificationDocumentRecord._({
    this.id,
    required this.hospitalKey,
    required this.title,
    required this.documentType,
    required this.fileUrl,
    required this.uploadDate,
    required this.status,
  });

  factory VerificationDocumentRecord({
    int? id,
    required String hospitalKey,
    required String title,
    required String documentType,
    required String fileUrl,
    required DateTime uploadDate,
    required String status,
  }) = _VerificationDocumentRecordImpl;

  factory VerificationDocumentRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return VerificationDocumentRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      title: jsonSerialization['title'] as String,
      documentType: jsonSerialization['documentType'] as String,
      fileUrl: jsonSerialization['fileUrl'] as String,
      uploadDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['uploadDate'],
      ),
      status: jsonSerialization['status'] as String,
    );
  }

  static final t = VerificationDocumentRecordTable();

  static const db = VerificationDocumentRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String title;

  String documentType;

  String fileUrl;

  DateTime uploadDate;

  String status;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [VerificationDocumentRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  VerificationDocumentRecord copyWith({
    int? id,
    String? hospitalKey,
    String? title,
    String? documentType,
    String? fileUrl,
    DateTime? uploadDate,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VerificationDocumentRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'title': title,
      'documentType': documentType,
      'fileUrl': fileUrl,
      'uploadDate': uploadDate.toJson(),
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VerificationDocumentRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'title': title,
      'documentType': documentType,
      'fileUrl': fileUrl,
      'uploadDate': uploadDate.toJson(),
      'status': status,
    };
  }

  static VerificationDocumentRecordInclude include() {
    return VerificationDocumentRecordInclude._();
  }

  static VerificationDocumentRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<VerificationDocumentRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VerificationDocumentRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VerificationDocumentRecordTable>? orderByList,
    VerificationDocumentRecordInclude? include,
  }) {
    return VerificationDocumentRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VerificationDocumentRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(VerificationDocumentRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VerificationDocumentRecordImpl extends VerificationDocumentRecord {
  _VerificationDocumentRecordImpl({
    int? id,
    required String hospitalKey,
    required String title,
    required String documentType,
    required String fileUrl,
    required DateTime uploadDate,
    required String status,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         title: title,
         documentType: documentType,
         fileUrl: fileUrl,
         uploadDate: uploadDate,
         status: status,
       );

  /// Returns a shallow copy of this [VerificationDocumentRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  VerificationDocumentRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? title,
    String? documentType,
    String? fileUrl,
    DateTime? uploadDate,
    String? status,
  }) {
    return VerificationDocumentRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
    );
  }
}

class VerificationDocumentRecordUpdateTable
    extends _i1.UpdateTable<VerificationDocumentRecordTable> {
  VerificationDocumentRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> documentType(String value) => _i1.ColumnValue(
    table.documentType,
    value,
  );

  _i1.ColumnValue<String, String> fileUrl(String value) => _i1.ColumnValue(
    table.fileUrl,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> uploadDate(DateTime value) =>
      _i1.ColumnValue(
        table.uploadDate,
        value,
      );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );
}

class VerificationDocumentRecordTable extends _i1.Table<int?> {
  VerificationDocumentRecordTable({super.tableRelation})
    : super(tableName: 'verification_document') {
    updateTable = VerificationDocumentRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    documentType = _i1.ColumnString(
      'documentType',
      this,
    );
    fileUrl = _i1.ColumnString(
      'fileUrl',
      this,
    );
    uploadDate = _i1.ColumnDateTime(
      'uploadDate',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
  }

  late final VerificationDocumentRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString title;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnString fileUrl;

  late final _i1.ColumnDateTime uploadDate;

  late final _i1.ColumnString status;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    title,
    documentType,
    fileUrl,
    uploadDate,
    status,
  ];
}

class VerificationDocumentRecordInclude extends _i1.IncludeObject {
  VerificationDocumentRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => VerificationDocumentRecord.t;
}

class VerificationDocumentRecordIncludeList extends _i1.IncludeList {
  VerificationDocumentRecordIncludeList._({
    _i1.WhereExpressionBuilder<VerificationDocumentRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(VerificationDocumentRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => VerificationDocumentRecord.t;
}

class VerificationDocumentRecordRepository {
  const VerificationDocumentRecordRepository._();

  /// Returns a list of [VerificationDocumentRecord]s matching the given query parameters.
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
  Future<List<VerificationDocumentRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<VerificationDocumentRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VerificationDocumentRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VerificationDocumentRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<VerificationDocumentRecord>(
      where: where?.call(VerificationDocumentRecord.t),
      orderBy: orderBy?.call(VerificationDocumentRecord.t),
      orderByList: orderByList?.call(VerificationDocumentRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [VerificationDocumentRecord] matching the given query parameters.
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
  Future<VerificationDocumentRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<VerificationDocumentRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<VerificationDocumentRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VerificationDocumentRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<VerificationDocumentRecord>(
      where: where?.call(VerificationDocumentRecord.t),
      orderBy: orderBy?.call(VerificationDocumentRecord.t),
      orderByList: orderByList?.call(VerificationDocumentRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [VerificationDocumentRecord] by its [id] or null if no such row exists.
  Future<VerificationDocumentRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<VerificationDocumentRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [VerificationDocumentRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [VerificationDocumentRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<VerificationDocumentRecord>> insert(
    _i1.DatabaseSession session,
    List<VerificationDocumentRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<VerificationDocumentRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [VerificationDocumentRecord] and returns the inserted row.
  ///
  /// The returned [VerificationDocumentRecord] will have its `id` field set.
  Future<VerificationDocumentRecord> insertRow(
    _i1.DatabaseSession session,
    VerificationDocumentRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<VerificationDocumentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [VerificationDocumentRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<VerificationDocumentRecord>> update(
    _i1.DatabaseSession session,
    List<VerificationDocumentRecord> rows, {
    _i1.ColumnSelections<VerificationDocumentRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<VerificationDocumentRecord>(
      rows,
      columns: columns?.call(VerificationDocumentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VerificationDocumentRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<VerificationDocumentRecord> updateRow(
    _i1.DatabaseSession session,
    VerificationDocumentRecord row, {
    _i1.ColumnSelections<VerificationDocumentRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<VerificationDocumentRecord>(
      row,
      columns: columns?.call(VerificationDocumentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VerificationDocumentRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<VerificationDocumentRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<VerificationDocumentRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<VerificationDocumentRecord>(
      id,
      columnValues: columnValues(VerificationDocumentRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [VerificationDocumentRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<VerificationDocumentRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<VerificationDocumentRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<VerificationDocumentRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VerificationDocumentRecordTable>? orderBy,
    _i1.OrderByListBuilder<VerificationDocumentRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<VerificationDocumentRecord>(
      columnValues: columnValues(VerificationDocumentRecord.t.updateTable),
      where: where(VerificationDocumentRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VerificationDocumentRecord.t),
      orderByList: orderByList?.call(VerificationDocumentRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [VerificationDocumentRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<VerificationDocumentRecord>> delete(
    _i1.DatabaseSession session,
    List<VerificationDocumentRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<VerificationDocumentRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [VerificationDocumentRecord].
  Future<VerificationDocumentRecord> deleteRow(
    _i1.DatabaseSession session,
    VerificationDocumentRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<VerificationDocumentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<VerificationDocumentRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<VerificationDocumentRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<VerificationDocumentRecord>(
      where: where(VerificationDocumentRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<VerificationDocumentRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<VerificationDocumentRecord>(
      where: where?.call(VerificationDocumentRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [VerificationDocumentRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<VerificationDocumentRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<VerificationDocumentRecord>(
      where: where(VerificationDocumentRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
