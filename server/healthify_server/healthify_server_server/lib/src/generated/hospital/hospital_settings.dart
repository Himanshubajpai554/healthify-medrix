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

abstract class HospitalSettingsRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalSettingsRecord._({
    this.id,
    required this.hospitalKey,
    required this.timezone,
    required this.defaultCurrency,
    required this.opdOpeningTime,
    required this.opdClosingTime,
    required this.appointmentSlotDurationMinutes,
    required this.autoReleaseExpiredBeds,
    required this.isEmergencyActive,
    required this.emergencyHotline,
    required this.traumaLevel,
    required this.ambulanceCount,
    required this.isHospitalDiscoverable,
    required this.showFacilitiesToPatients,
    required this.showDoctorSchedulesToPatients,
    required this.showBedAvailabilityToPatients,
    required this.showRatingsAndReviews,
    required this.sessionTimeoutMinutes,
    required this.enforceMfaForAdmin,
    required this.enableAuditLogging,
  });

  factory HospitalSettingsRecord({
    int? id,
    required String hospitalKey,
    required String timezone,
    required String defaultCurrency,
    required String opdOpeningTime,
    required String opdClosingTime,
    required int appointmentSlotDurationMinutes,
    required bool autoReleaseExpiredBeds,
    required bool isEmergencyActive,
    required String emergencyHotline,
    required String traumaLevel,
    required int ambulanceCount,
    required bool isHospitalDiscoverable,
    required bool showFacilitiesToPatients,
    required bool showDoctorSchedulesToPatients,
    required bool showBedAvailabilityToPatients,
    required bool showRatingsAndReviews,
    required int sessionTimeoutMinutes,
    required bool enforceMfaForAdmin,
    required bool enableAuditLogging,
  }) = _HospitalSettingsRecordImpl;

  factory HospitalSettingsRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalSettingsRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      timezone: jsonSerialization['timezone'] as String,
      defaultCurrency: jsonSerialization['defaultCurrency'] as String,
      opdOpeningTime: jsonSerialization['opdOpeningTime'] as String,
      opdClosingTime: jsonSerialization['opdClosingTime'] as String,
      appointmentSlotDurationMinutes:
          jsonSerialization['appointmentSlotDurationMinutes'] as int,
      autoReleaseExpiredBeds: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['autoReleaseExpiredBeds'],
      ),
      isEmergencyActive: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isEmergencyActive'],
      ),
      emergencyHotline: jsonSerialization['emergencyHotline'] as String,
      traumaLevel: jsonSerialization['traumaLevel'] as String,
      ambulanceCount: jsonSerialization['ambulanceCount'] as int,
      isHospitalDiscoverable: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isHospitalDiscoverable'],
      ),
      showFacilitiesToPatients: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showFacilitiesToPatients'],
      ),
      showDoctorSchedulesToPatients: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showDoctorSchedulesToPatients'],
      ),
      showBedAvailabilityToPatients: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showBedAvailabilityToPatients'],
      ),
      showRatingsAndReviews: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showRatingsAndReviews'],
      ),
      sessionTimeoutMinutes: jsonSerialization['sessionTimeoutMinutes'] as int,
      enforceMfaForAdmin: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['enforceMfaForAdmin'],
      ),
      enableAuditLogging: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['enableAuditLogging'],
      ),
    );
  }

  static final t = HospitalSettingsRecordTable();

  static const db = HospitalSettingsRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String timezone;

  String defaultCurrency;

  String opdOpeningTime;

  String opdClosingTime;

  int appointmentSlotDurationMinutes;

  bool autoReleaseExpiredBeds;

  bool isEmergencyActive;

  String emergencyHotline;

  String traumaLevel;

  int ambulanceCount;

  bool isHospitalDiscoverable;

  bool showFacilitiesToPatients;

  bool showDoctorSchedulesToPatients;

  bool showBedAvailabilityToPatients;

  bool showRatingsAndReviews;

  int sessionTimeoutMinutes;

  bool enforceMfaForAdmin;

  bool enableAuditLogging;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalSettingsRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalSettingsRecord copyWith({
    int? id,
    String? hospitalKey,
    String? timezone,
    String? defaultCurrency,
    String? opdOpeningTime,
    String? opdClosingTime,
    int? appointmentSlotDurationMinutes,
    bool? autoReleaseExpiredBeds,
    bool? isEmergencyActive,
    String? emergencyHotline,
    String? traumaLevel,
    int? ambulanceCount,
    bool? isHospitalDiscoverable,
    bool? showFacilitiesToPatients,
    bool? showDoctorSchedulesToPatients,
    bool? showBedAvailabilityToPatients,
    bool? showRatingsAndReviews,
    int? sessionTimeoutMinutes,
    bool? enforceMfaForAdmin,
    bool? enableAuditLogging,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalSettingsRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'timezone': timezone,
      'defaultCurrency': defaultCurrency,
      'opdOpeningTime': opdOpeningTime,
      'opdClosingTime': opdClosingTime,
      'appointmentSlotDurationMinutes': appointmentSlotDurationMinutes,
      'autoReleaseExpiredBeds': autoReleaseExpiredBeds,
      'isEmergencyActive': isEmergencyActive,
      'emergencyHotline': emergencyHotline,
      'traumaLevel': traumaLevel,
      'ambulanceCount': ambulanceCount,
      'isHospitalDiscoverable': isHospitalDiscoverable,
      'showFacilitiesToPatients': showFacilitiesToPatients,
      'showDoctorSchedulesToPatients': showDoctorSchedulesToPatients,
      'showBedAvailabilityToPatients': showBedAvailabilityToPatients,
      'showRatingsAndReviews': showRatingsAndReviews,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'enforceMfaForAdmin': enforceMfaForAdmin,
      'enableAuditLogging': enableAuditLogging,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalSettingsRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'timezone': timezone,
      'defaultCurrency': defaultCurrency,
      'opdOpeningTime': opdOpeningTime,
      'opdClosingTime': opdClosingTime,
      'appointmentSlotDurationMinutes': appointmentSlotDurationMinutes,
      'autoReleaseExpiredBeds': autoReleaseExpiredBeds,
      'isEmergencyActive': isEmergencyActive,
      'emergencyHotline': emergencyHotline,
      'traumaLevel': traumaLevel,
      'ambulanceCount': ambulanceCount,
      'isHospitalDiscoverable': isHospitalDiscoverable,
      'showFacilitiesToPatients': showFacilitiesToPatients,
      'showDoctorSchedulesToPatients': showDoctorSchedulesToPatients,
      'showBedAvailabilityToPatients': showBedAvailabilityToPatients,
      'showRatingsAndReviews': showRatingsAndReviews,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'enforceMfaForAdmin': enforceMfaForAdmin,
      'enableAuditLogging': enableAuditLogging,
    };
  }

  static HospitalSettingsRecordInclude include() {
    return HospitalSettingsRecordInclude._();
  }

  static HospitalSettingsRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalSettingsRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalSettingsRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalSettingsRecordTable>? orderByList,
    HospitalSettingsRecordInclude? include,
  }) {
    return HospitalSettingsRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalSettingsRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalSettingsRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalSettingsRecordImpl extends HospitalSettingsRecord {
  _HospitalSettingsRecordImpl({
    int? id,
    required String hospitalKey,
    required String timezone,
    required String defaultCurrency,
    required String opdOpeningTime,
    required String opdClosingTime,
    required int appointmentSlotDurationMinutes,
    required bool autoReleaseExpiredBeds,
    required bool isEmergencyActive,
    required String emergencyHotline,
    required String traumaLevel,
    required int ambulanceCount,
    required bool isHospitalDiscoverable,
    required bool showFacilitiesToPatients,
    required bool showDoctorSchedulesToPatients,
    required bool showBedAvailabilityToPatients,
    required bool showRatingsAndReviews,
    required int sessionTimeoutMinutes,
    required bool enforceMfaForAdmin,
    required bool enableAuditLogging,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         timezone: timezone,
         defaultCurrency: defaultCurrency,
         opdOpeningTime: opdOpeningTime,
         opdClosingTime: opdClosingTime,
         appointmentSlotDurationMinutes: appointmentSlotDurationMinutes,
         autoReleaseExpiredBeds: autoReleaseExpiredBeds,
         isEmergencyActive: isEmergencyActive,
         emergencyHotline: emergencyHotline,
         traumaLevel: traumaLevel,
         ambulanceCount: ambulanceCount,
         isHospitalDiscoverable: isHospitalDiscoverable,
         showFacilitiesToPatients: showFacilitiesToPatients,
         showDoctorSchedulesToPatients: showDoctorSchedulesToPatients,
         showBedAvailabilityToPatients: showBedAvailabilityToPatients,
         showRatingsAndReviews: showRatingsAndReviews,
         sessionTimeoutMinutes: sessionTimeoutMinutes,
         enforceMfaForAdmin: enforceMfaForAdmin,
         enableAuditLogging: enableAuditLogging,
       );

  /// Returns a shallow copy of this [HospitalSettingsRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalSettingsRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? timezone,
    String? defaultCurrency,
    String? opdOpeningTime,
    String? opdClosingTime,
    int? appointmentSlotDurationMinutes,
    bool? autoReleaseExpiredBeds,
    bool? isEmergencyActive,
    String? emergencyHotline,
    String? traumaLevel,
    int? ambulanceCount,
    bool? isHospitalDiscoverable,
    bool? showFacilitiesToPatients,
    bool? showDoctorSchedulesToPatients,
    bool? showBedAvailabilityToPatients,
    bool? showRatingsAndReviews,
    int? sessionTimeoutMinutes,
    bool? enforceMfaForAdmin,
    bool? enableAuditLogging,
  }) {
    return HospitalSettingsRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      timezone: timezone ?? this.timezone,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      opdOpeningTime: opdOpeningTime ?? this.opdOpeningTime,
      opdClosingTime: opdClosingTime ?? this.opdClosingTime,
      appointmentSlotDurationMinutes:
          appointmentSlotDurationMinutes ?? this.appointmentSlotDurationMinutes,
      autoReleaseExpiredBeds:
          autoReleaseExpiredBeds ?? this.autoReleaseExpiredBeds,
      isEmergencyActive: isEmergencyActive ?? this.isEmergencyActive,
      emergencyHotline: emergencyHotline ?? this.emergencyHotline,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      ambulanceCount: ambulanceCount ?? this.ambulanceCount,
      isHospitalDiscoverable:
          isHospitalDiscoverable ?? this.isHospitalDiscoverable,
      showFacilitiesToPatients:
          showFacilitiesToPatients ?? this.showFacilitiesToPatients,
      showDoctorSchedulesToPatients:
          showDoctorSchedulesToPatients ?? this.showDoctorSchedulesToPatients,
      showBedAvailabilityToPatients:
          showBedAvailabilityToPatients ?? this.showBedAvailabilityToPatients,
      showRatingsAndReviews:
          showRatingsAndReviews ?? this.showRatingsAndReviews,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      enforceMfaForAdmin: enforceMfaForAdmin ?? this.enforceMfaForAdmin,
      enableAuditLogging: enableAuditLogging ?? this.enableAuditLogging,
    );
  }
}

class HospitalSettingsRecordUpdateTable
    extends _i1.UpdateTable<HospitalSettingsRecordTable> {
  HospitalSettingsRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> timezone(String value) => _i1.ColumnValue(
    table.timezone,
    value,
  );

  _i1.ColumnValue<String, String> defaultCurrency(String value) =>
      _i1.ColumnValue(
        table.defaultCurrency,
        value,
      );

  _i1.ColumnValue<String, String> opdOpeningTime(String value) =>
      _i1.ColumnValue(
        table.opdOpeningTime,
        value,
      );

  _i1.ColumnValue<String, String> opdClosingTime(String value) =>
      _i1.ColumnValue(
        table.opdClosingTime,
        value,
      );

  _i1.ColumnValue<int, int> appointmentSlotDurationMinutes(int value) =>
      _i1.ColumnValue(
        table.appointmentSlotDurationMinutes,
        value,
      );

  _i1.ColumnValue<bool, bool> autoReleaseExpiredBeds(bool value) =>
      _i1.ColumnValue(
        table.autoReleaseExpiredBeds,
        value,
      );

  _i1.ColumnValue<bool, bool> isEmergencyActive(bool value) => _i1.ColumnValue(
    table.isEmergencyActive,
    value,
  );

  _i1.ColumnValue<String, String> emergencyHotline(String value) =>
      _i1.ColumnValue(
        table.emergencyHotline,
        value,
      );

  _i1.ColumnValue<String, String> traumaLevel(String value) => _i1.ColumnValue(
    table.traumaLevel,
    value,
  );

  _i1.ColumnValue<int, int> ambulanceCount(int value) => _i1.ColumnValue(
    table.ambulanceCount,
    value,
  );

  _i1.ColumnValue<bool, bool> isHospitalDiscoverable(bool value) =>
      _i1.ColumnValue(
        table.isHospitalDiscoverable,
        value,
      );

  _i1.ColumnValue<bool, bool> showFacilitiesToPatients(bool value) =>
      _i1.ColumnValue(
        table.showFacilitiesToPatients,
        value,
      );

  _i1.ColumnValue<bool, bool> showDoctorSchedulesToPatients(bool value) =>
      _i1.ColumnValue(
        table.showDoctorSchedulesToPatients,
        value,
      );

  _i1.ColumnValue<bool, bool> showBedAvailabilityToPatients(bool value) =>
      _i1.ColumnValue(
        table.showBedAvailabilityToPatients,
        value,
      );

  _i1.ColumnValue<bool, bool> showRatingsAndReviews(bool value) =>
      _i1.ColumnValue(
        table.showRatingsAndReviews,
        value,
      );

  _i1.ColumnValue<int, int> sessionTimeoutMinutes(int value) => _i1.ColumnValue(
    table.sessionTimeoutMinutes,
    value,
  );

  _i1.ColumnValue<bool, bool> enforceMfaForAdmin(bool value) => _i1.ColumnValue(
    table.enforceMfaForAdmin,
    value,
  );

  _i1.ColumnValue<bool, bool> enableAuditLogging(bool value) => _i1.ColumnValue(
    table.enableAuditLogging,
    value,
  );
}

class HospitalSettingsRecordTable extends _i1.Table<int?> {
  HospitalSettingsRecordTable({super.tableRelation})
    : super(tableName: 'hospital_settings') {
    updateTable = HospitalSettingsRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    timezone = _i1.ColumnString(
      'timezone',
      this,
    );
    defaultCurrency = _i1.ColumnString(
      'defaultCurrency',
      this,
    );
    opdOpeningTime = _i1.ColumnString(
      'opdOpeningTime',
      this,
    );
    opdClosingTime = _i1.ColumnString(
      'opdClosingTime',
      this,
    );
    appointmentSlotDurationMinutes = _i1.ColumnInt(
      'appointmentSlotDurationMinutes',
      this,
    );
    autoReleaseExpiredBeds = _i1.ColumnBool(
      'autoReleaseExpiredBeds',
      this,
    );
    isEmergencyActive = _i1.ColumnBool(
      'isEmergencyActive',
      this,
    );
    emergencyHotline = _i1.ColumnString(
      'emergencyHotline',
      this,
    );
    traumaLevel = _i1.ColumnString(
      'traumaLevel',
      this,
    );
    ambulanceCount = _i1.ColumnInt(
      'ambulanceCount',
      this,
    );
    isHospitalDiscoverable = _i1.ColumnBool(
      'isHospitalDiscoverable',
      this,
    );
    showFacilitiesToPatients = _i1.ColumnBool(
      'showFacilitiesToPatients',
      this,
    );
    showDoctorSchedulesToPatients = _i1.ColumnBool(
      'showDoctorSchedulesToPatients',
      this,
    );
    showBedAvailabilityToPatients = _i1.ColumnBool(
      'showBedAvailabilityToPatients',
      this,
    );
    showRatingsAndReviews = _i1.ColumnBool(
      'showRatingsAndReviews',
      this,
    );
    sessionTimeoutMinutes = _i1.ColumnInt(
      'sessionTimeoutMinutes',
      this,
    );
    enforceMfaForAdmin = _i1.ColumnBool(
      'enforceMfaForAdmin',
      this,
    );
    enableAuditLogging = _i1.ColumnBool(
      'enableAuditLogging',
      this,
    );
  }

  late final HospitalSettingsRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString timezone;

  late final _i1.ColumnString defaultCurrency;

  late final _i1.ColumnString opdOpeningTime;

  late final _i1.ColumnString opdClosingTime;

  late final _i1.ColumnInt appointmentSlotDurationMinutes;

  late final _i1.ColumnBool autoReleaseExpiredBeds;

  late final _i1.ColumnBool isEmergencyActive;

  late final _i1.ColumnString emergencyHotline;

  late final _i1.ColumnString traumaLevel;

  late final _i1.ColumnInt ambulanceCount;

  late final _i1.ColumnBool isHospitalDiscoverable;

  late final _i1.ColumnBool showFacilitiesToPatients;

  late final _i1.ColumnBool showDoctorSchedulesToPatients;

  late final _i1.ColumnBool showBedAvailabilityToPatients;

  late final _i1.ColumnBool showRatingsAndReviews;

  late final _i1.ColumnInt sessionTimeoutMinutes;

  late final _i1.ColumnBool enforceMfaForAdmin;

  late final _i1.ColumnBool enableAuditLogging;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    timezone,
    defaultCurrency,
    opdOpeningTime,
    opdClosingTime,
    appointmentSlotDurationMinutes,
    autoReleaseExpiredBeds,
    isEmergencyActive,
    emergencyHotline,
    traumaLevel,
    ambulanceCount,
    isHospitalDiscoverable,
    showFacilitiesToPatients,
    showDoctorSchedulesToPatients,
    showBedAvailabilityToPatients,
    showRatingsAndReviews,
    sessionTimeoutMinutes,
    enforceMfaForAdmin,
    enableAuditLogging,
  ];
}

class HospitalSettingsRecordInclude extends _i1.IncludeObject {
  HospitalSettingsRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalSettingsRecord.t;
}

class HospitalSettingsRecordIncludeList extends _i1.IncludeList {
  HospitalSettingsRecordIncludeList._({
    _i1.WhereExpressionBuilder<HospitalSettingsRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalSettingsRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalSettingsRecord.t;
}

class HospitalSettingsRecordRepository {
  const HospitalSettingsRecordRepository._();

  /// Returns a list of [HospitalSettingsRecord]s matching the given query parameters.
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
  Future<List<HospitalSettingsRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalSettingsRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalSettingsRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalSettingsRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalSettingsRecord>(
      where: where?.call(HospitalSettingsRecord.t),
      orderBy: orderBy?.call(HospitalSettingsRecord.t),
      orderByList: orderByList?.call(HospitalSettingsRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalSettingsRecord] matching the given query parameters.
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
  Future<HospitalSettingsRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalSettingsRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalSettingsRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalSettingsRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalSettingsRecord>(
      where: where?.call(HospitalSettingsRecord.t),
      orderBy: orderBy?.call(HospitalSettingsRecord.t),
      orderByList: orderByList?.call(HospitalSettingsRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalSettingsRecord] by its [id] or null if no such row exists.
  Future<HospitalSettingsRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalSettingsRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalSettingsRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalSettingsRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalSettingsRecord>> insert(
    _i1.DatabaseSession session,
    List<HospitalSettingsRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalSettingsRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalSettingsRecord] and returns the inserted row.
  ///
  /// The returned [HospitalSettingsRecord] will have its `id` field set.
  Future<HospitalSettingsRecord> insertRow(
    _i1.DatabaseSession session,
    HospitalSettingsRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalSettingsRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalSettingsRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalSettingsRecord>> update(
    _i1.DatabaseSession session,
    List<HospitalSettingsRecord> rows, {
    _i1.ColumnSelections<HospitalSettingsRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalSettingsRecord>(
      rows,
      columns: columns?.call(HospitalSettingsRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalSettingsRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalSettingsRecord> updateRow(
    _i1.DatabaseSession session,
    HospitalSettingsRecord row, {
    _i1.ColumnSelections<HospitalSettingsRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalSettingsRecord>(
      row,
      columns: columns?.call(HospitalSettingsRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalSettingsRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalSettingsRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalSettingsRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalSettingsRecord>(
      id,
      columnValues: columnValues(HospitalSettingsRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalSettingsRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalSettingsRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalSettingsRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalSettingsRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalSettingsRecordTable>? orderBy,
    _i1.OrderByListBuilder<HospitalSettingsRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalSettingsRecord>(
      columnValues: columnValues(HospitalSettingsRecord.t.updateTable),
      where: where(HospitalSettingsRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalSettingsRecord.t),
      orderByList: orderByList?.call(HospitalSettingsRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalSettingsRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalSettingsRecord>> delete(
    _i1.DatabaseSession session,
    List<HospitalSettingsRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalSettingsRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalSettingsRecord].
  Future<HospitalSettingsRecord> deleteRow(
    _i1.DatabaseSession session,
    HospitalSettingsRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalSettingsRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalSettingsRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalSettingsRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalSettingsRecord>(
      where: where(HospitalSettingsRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalSettingsRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalSettingsRecord>(
      where: where?.call(HospitalSettingsRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalSettingsRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalSettingsRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalSettingsRecord>(
      where: where(HospitalSettingsRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
