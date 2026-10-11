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

abstract class HospitalProfileRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  HospitalProfileRecord._({
    this.id,
    required this.hospitalKey,
    required this.name,
    required this.legalName,
    required this.displayName,
    required this.hospitalType,
    required this.establishmentDate,
    required this.registrationLicenseId,
    required this.taxId,
    required this.accreditationInfo,
    required this.email,
    required this.emergencyHelpline,
    required this.receptionPhone,
    required this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.totalBeds,
    required this.icuBeds,
    required this.operatingTheatres,
    required this.emergencyCapacity,
    required this.has247Emergency,
    required this.traumaLevel,
    required this.hasAmbulance,
    required this.opdTimings,
    required this.operatingStatus,
    required this.verificationStatus,
    this.submittedDate,
    this.verifiedDate,
    required this.verificationNotes,
  });

  factory HospitalProfileRecord({
    int? id,
    required String hospitalKey,
    required String name,
    required String legalName,
    required String displayName,
    required String hospitalType,
    required String establishmentDate,
    required String registrationLicenseId,
    required String taxId,
    required String accreditationInfo,
    required String email,
    required String emergencyHelpline,
    required String receptionPhone,
    required String website,
    required String address,
    required String city,
    required String state,
    required String country,
    required double latitude,
    required double longitude,
    required int totalBeds,
    required int icuBeds,
    required int operatingTheatres,
    required int emergencyCapacity,
    required bool has247Emergency,
    required String traumaLevel,
    required bool hasAmbulance,
    required String opdTimings,
    required String operatingStatus,
    required String verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    required String verificationNotes,
  }) = _HospitalProfileRecordImpl;

  factory HospitalProfileRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalProfileRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      name: jsonSerialization['name'] as String,
      legalName: jsonSerialization['legalName'] as String,
      displayName: jsonSerialization['displayName'] as String,
      hospitalType: jsonSerialization['hospitalType'] as String,
      establishmentDate: jsonSerialization['establishmentDate'] as String,
      registrationLicenseId:
          jsonSerialization['registrationLicenseId'] as String,
      taxId: jsonSerialization['taxId'] as String,
      accreditationInfo: jsonSerialization['accreditationInfo'] as String,
      email: jsonSerialization['email'] as String,
      emergencyHelpline: jsonSerialization['emergencyHelpline'] as String,
      receptionPhone: jsonSerialization['receptionPhone'] as String,
      website: jsonSerialization['website'] as String,
      address: jsonSerialization['address'] as String,
      city: jsonSerialization['city'] as String,
      state: jsonSerialization['state'] as String,
      country: jsonSerialization['country'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      totalBeds: jsonSerialization['totalBeds'] as int,
      icuBeds: jsonSerialization['icuBeds'] as int,
      operatingTheatres: jsonSerialization['operatingTheatres'] as int,
      emergencyCapacity: jsonSerialization['emergencyCapacity'] as int,
      has247Emergency: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['has247Emergency'],
      ),
      traumaLevel: jsonSerialization['traumaLevel'] as String,
      hasAmbulance: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasAmbulance'],
      ),
      opdTimings: jsonSerialization['opdTimings'] as String,
      operatingStatus: jsonSerialization['operatingStatus'] as String,
      verificationStatus: jsonSerialization['verificationStatus'] as String,
      submittedDate: jsonSerialization['submittedDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedDate'],
            ),
      verifiedDate: jsonSerialization['verifiedDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['verifiedDate'],
            ),
      verificationNotes: jsonSerialization['verificationNotes'] as String,
    );
  }

  static final t = HospitalProfileRecordTable();

  static const db = HospitalProfileRecordRepository._();

  @override
  int? id;

  String hospitalKey;

  String name;

  String legalName;

  String displayName;

  String hospitalType;

  String establishmentDate;

  String registrationLicenseId;

  String taxId;

  String accreditationInfo;

  String email;

  String emergencyHelpline;

  String receptionPhone;

  String website;

  String address;

  String city;

  String state;

  String country;

  double latitude;

  double longitude;

  int totalBeds;

  int icuBeds;

  int operatingTheatres;

  int emergencyCapacity;

  bool has247Emergency;

  String traumaLevel;

  bool hasAmbulance;

  String opdTimings;

  String operatingStatus;

  String verificationStatus;

  DateTime? submittedDate;

  DateTime? verifiedDate;

  String verificationNotes;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [HospitalProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalProfileRecord copyWith({
    int? id,
    String? hospitalKey,
    String? name,
    String? legalName,
    String? displayName,
    String? hospitalType,
    String? establishmentDate,
    String? registrationLicenseId,
    String? taxId,
    String? accreditationInfo,
    String? email,
    String? emergencyHelpline,
    String? receptionPhone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    int? totalBeds,
    int? icuBeds,
    int? operatingTheatres,
    int? emergencyCapacity,
    bool? has247Emergency,
    String? traumaLevel,
    bool? hasAmbulance,
    String? opdTimings,
    String? operatingStatus,
    String? verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    String? verificationNotes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalProfileRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'name': name,
      'legalName': legalName,
      'displayName': displayName,
      'hospitalType': hospitalType,
      'establishmentDate': establishmentDate,
      'registrationLicenseId': registrationLicenseId,
      'taxId': taxId,
      'accreditationInfo': accreditationInfo,
      'email': email,
      'emergencyHelpline': emergencyHelpline,
      'receptionPhone': receptionPhone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'totalBeds': totalBeds,
      'icuBeds': icuBeds,
      'operatingTheatres': operatingTheatres,
      'emergencyCapacity': emergencyCapacity,
      'has247Emergency': has247Emergency,
      'traumaLevel': traumaLevel,
      'hasAmbulance': hasAmbulance,
      'opdTimings': opdTimings,
      'operatingStatus': operatingStatus,
      'verificationStatus': verificationStatus,
      if (submittedDate != null) 'submittedDate': submittedDate?.toJson(),
      if (verifiedDate != null) 'verifiedDate': verifiedDate?.toJson(),
      'verificationNotes': verificationNotes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HospitalProfileRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'name': name,
      'legalName': legalName,
      'displayName': displayName,
      'hospitalType': hospitalType,
      'establishmentDate': establishmentDate,
      'registrationLicenseId': registrationLicenseId,
      'taxId': taxId,
      'accreditationInfo': accreditationInfo,
      'email': email,
      'emergencyHelpline': emergencyHelpline,
      'receptionPhone': receptionPhone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'totalBeds': totalBeds,
      'icuBeds': icuBeds,
      'operatingTheatres': operatingTheatres,
      'emergencyCapacity': emergencyCapacity,
      'has247Emergency': has247Emergency,
      'traumaLevel': traumaLevel,
      'hasAmbulance': hasAmbulance,
      'opdTimings': opdTimings,
      'operatingStatus': operatingStatus,
      'verificationStatus': verificationStatus,
      if (submittedDate != null) 'submittedDate': submittedDate?.toJson(),
      if (verifiedDate != null) 'verifiedDate': verifiedDate?.toJson(),
      'verificationNotes': verificationNotes,
    };
  }

  static HospitalProfileRecordInclude include() {
    return HospitalProfileRecordInclude._();
  }

  static HospitalProfileRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<HospitalProfileRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalProfileRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalProfileRecordTable>? orderByList,
    HospitalProfileRecordInclude? include,
  }) {
    return HospitalProfileRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalProfileRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(HospitalProfileRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalProfileRecordImpl extends HospitalProfileRecord {
  _HospitalProfileRecordImpl({
    int? id,
    required String hospitalKey,
    required String name,
    required String legalName,
    required String displayName,
    required String hospitalType,
    required String establishmentDate,
    required String registrationLicenseId,
    required String taxId,
    required String accreditationInfo,
    required String email,
    required String emergencyHelpline,
    required String receptionPhone,
    required String website,
    required String address,
    required String city,
    required String state,
    required String country,
    required double latitude,
    required double longitude,
    required int totalBeds,
    required int icuBeds,
    required int operatingTheatres,
    required int emergencyCapacity,
    required bool has247Emergency,
    required String traumaLevel,
    required bool hasAmbulance,
    required String opdTimings,
    required String operatingStatus,
    required String verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    required String verificationNotes,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         name: name,
         legalName: legalName,
         displayName: displayName,
         hospitalType: hospitalType,
         establishmentDate: establishmentDate,
         registrationLicenseId: registrationLicenseId,
         taxId: taxId,
         accreditationInfo: accreditationInfo,
         email: email,
         emergencyHelpline: emergencyHelpline,
         receptionPhone: receptionPhone,
         website: website,
         address: address,
         city: city,
         state: state,
         country: country,
         latitude: latitude,
         longitude: longitude,
         totalBeds: totalBeds,
         icuBeds: icuBeds,
         operatingTheatres: operatingTheatres,
         emergencyCapacity: emergencyCapacity,
         has247Emergency: has247Emergency,
         traumaLevel: traumaLevel,
         hasAmbulance: hasAmbulance,
         opdTimings: opdTimings,
         operatingStatus: operatingStatus,
         verificationStatus: verificationStatus,
         submittedDate: submittedDate,
         verifiedDate: verifiedDate,
         verificationNotes: verificationNotes,
       );

  /// Returns a shallow copy of this [HospitalProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalProfileRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? name,
    String? legalName,
    String? displayName,
    String? hospitalType,
    String? establishmentDate,
    String? registrationLicenseId,
    String? taxId,
    String? accreditationInfo,
    String? email,
    String? emergencyHelpline,
    String? receptionPhone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    int? totalBeds,
    int? icuBeds,
    int? operatingTheatres,
    int? emergencyCapacity,
    bool? has247Emergency,
    String? traumaLevel,
    bool? hasAmbulance,
    String? opdTimings,
    String? operatingStatus,
    String? verificationStatus,
    Object? submittedDate = _Undefined,
    Object? verifiedDate = _Undefined,
    String? verificationNotes,
  }) {
    return HospitalProfileRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      hospitalType: hospitalType ?? this.hospitalType,
      establishmentDate: establishmentDate ?? this.establishmentDate,
      registrationLicenseId:
          registrationLicenseId ?? this.registrationLicenseId,
      taxId: taxId ?? this.taxId,
      accreditationInfo: accreditationInfo ?? this.accreditationInfo,
      email: email ?? this.email,
      emergencyHelpline: emergencyHelpline ?? this.emergencyHelpline,
      receptionPhone: receptionPhone ?? this.receptionPhone,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalBeds: totalBeds ?? this.totalBeds,
      icuBeds: icuBeds ?? this.icuBeds,
      operatingTheatres: operatingTheatres ?? this.operatingTheatres,
      emergencyCapacity: emergencyCapacity ?? this.emergencyCapacity,
      has247Emergency: has247Emergency ?? this.has247Emergency,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      hasAmbulance: hasAmbulance ?? this.hasAmbulance,
      opdTimings: opdTimings ?? this.opdTimings,
      operatingStatus: operatingStatus ?? this.operatingStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      submittedDate: submittedDate is DateTime?
          ? submittedDate
          : this.submittedDate,
      verifiedDate: verifiedDate is DateTime?
          ? verifiedDate
          : this.verifiedDate,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }
}

class HospitalProfileRecordUpdateTable
    extends _i1.UpdateTable<HospitalProfileRecordTable> {
  HospitalProfileRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> hospitalKey(String value) => _i1.ColumnValue(
    table.hospitalKey,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> legalName(String value) => _i1.ColumnValue(
    table.legalName,
    value,
  );

  _i1.ColumnValue<String, String> displayName(String value) => _i1.ColumnValue(
    table.displayName,
    value,
  );

  _i1.ColumnValue<String, String> hospitalType(String value) => _i1.ColumnValue(
    table.hospitalType,
    value,
  );

  _i1.ColumnValue<String, String> establishmentDate(String value) =>
      _i1.ColumnValue(
        table.establishmentDate,
        value,
      );

  _i1.ColumnValue<String, String> registrationLicenseId(String value) =>
      _i1.ColumnValue(
        table.registrationLicenseId,
        value,
      );

  _i1.ColumnValue<String, String> taxId(String value) => _i1.ColumnValue(
    table.taxId,
    value,
  );

  _i1.ColumnValue<String, String> accreditationInfo(String value) =>
      _i1.ColumnValue(
        table.accreditationInfo,
        value,
      );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> emergencyHelpline(String value) =>
      _i1.ColumnValue(
        table.emergencyHelpline,
        value,
      );

  _i1.ColumnValue<String, String> receptionPhone(String value) =>
      _i1.ColumnValue(
        table.receptionPhone,
        value,
      );

  _i1.ColumnValue<String, String> website(String value) => _i1.ColumnValue(
    table.website,
    value,
  );

  _i1.ColumnValue<String, String> address(String value) => _i1.ColumnValue(
    table.address,
    value,
  );

  _i1.ColumnValue<String, String> city(String value) => _i1.ColumnValue(
    table.city,
    value,
  );

  _i1.ColumnValue<String, String> state(String value) => _i1.ColumnValue(
    table.state,
    value,
  );

  _i1.ColumnValue<String, String> country(String value) => _i1.ColumnValue(
    table.country,
    value,
  );

  _i1.ColumnValue<double, double> latitude(double value) => _i1.ColumnValue(
    table.latitude,
    value,
  );

  _i1.ColumnValue<double, double> longitude(double value) => _i1.ColumnValue(
    table.longitude,
    value,
  );

  _i1.ColumnValue<int, int> totalBeds(int value) => _i1.ColumnValue(
    table.totalBeds,
    value,
  );

  _i1.ColumnValue<int, int> icuBeds(int value) => _i1.ColumnValue(
    table.icuBeds,
    value,
  );

  _i1.ColumnValue<int, int> operatingTheatres(int value) => _i1.ColumnValue(
    table.operatingTheatres,
    value,
  );

  _i1.ColumnValue<int, int> emergencyCapacity(int value) => _i1.ColumnValue(
    table.emergencyCapacity,
    value,
  );

  _i1.ColumnValue<bool, bool> has247Emergency(bool value) => _i1.ColumnValue(
    table.has247Emergency,
    value,
  );

  _i1.ColumnValue<String, String> traumaLevel(String value) => _i1.ColumnValue(
    table.traumaLevel,
    value,
  );

  _i1.ColumnValue<bool, bool> hasAmbulance(bool value) => _i1.ColumnValue(
    table.hasAmbulance,
    value,
  );

  _i1.ColumnValue<String, String> opdTimings(String value) => _i1.ColumnValue(
    table.opdTimings,
    value,
  );

  _i1.ColumnValue<String, String> operatingStatus(String value) =>
      _i1.ColumnValue(
        table.operatingStatus,
        value,
      );

  _i1.ColumnValue<String, String> verificationStatus(String value) =>
      _i1.ColumnValue(
        table.verificationStatus,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> submittedDate(DateTime? value) =>
      _i1.ColumnValue(
        table.submittedDate,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> verifiedDate(DateTime? value) =>
      _i1.ColumnValue(
        table.verifiedDate,
        value,
      );

  _i1.ColumnValue<String, String> verificationNotes(String value) =>
      _i1.ColumnValue(
        table.verificationNotes,
        value,
      );
}

class HospitalProfileRecordTable extends _i1.Table<int?> {
  HospitalProfileRecordTable({super.tableRelation})
    : super(tableName: 'hospital_profile') {
    updateTable = HospitalProfileRecordUpdateTable(this);
    hospitalKey = _i1.ColumnString(
      'hospitalKey',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    legalName = _i1.ColumnString(
      'legalName',
      this,
    );
    displayName = _i1.ColumnString(
      'displayName',
      this,
    );
    hospitalType = _i1.ColumnString(
      'hospitalType',
      this,
    );
    establishmentDate = _i1.ColumnString(
      'establishmentDate',
      this,
    );
    registrationLicenseId = _i1.ColumnString(
      'registrationLicenseId',
      this,
    );
    taxId = _i1.ColumnString(
      'taxId',
      this,
    );
    accreditationInfo = _i1.ColumnString(
      'accreditationInfo',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    emergencyHelpline = _i1.ColumnString(
      'emergencyHelpline',
      this,
    );
    receptionPhone = _i1.ColumnString(
      'receptionPhone',
      this,
    );
    website = _i1.ColumnString(
      'website',
      this,
    );
    address = _i1.ColumnString(
      'address',
      this,
    );
    city = _i1.ColumnString(
      'city',
      this,
    );
    state = _i1.ColumnString(
      'state',
      this,
    );
    country = _i1.ColumnString(
      'country',
      this,
    );
    latitude = _i1.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _i1.ColumnDouble(
      'longitude',
      this,
    );
    totalBeds = _i1.ColumnInt(
      'totalBeds',
      this,
    );
    icuBeds = _i1.ColumnInt(
      'icuBeds',
      this,
    );
    operatingTheatres = _i1.ColumnInt(
      'operatingTheatres',
      this,
    );
    emergencyCapacity = _i1.ColumnInt(
      'emergencyCapacity',
      this,
    );
    has247Emergency = _i1.ColumnBool(
      'has247Emergency',
      this,
    );
    traumaLevel = _i1.ColumnString(
      'traumaLevel',
      this,
    );
    hasAmbulance = _i1.ColumnBool(
      'hasAmbulance',
      this,
    );
    opdTimings = _i1.ColumnString(
      'opdTimings',
      this,
    );
    operatingStatus = _i1.ColumnString(
      'operatingStatus',
      this,
    );
    verificationStatus = _i1.ColumnString(
      'verificationStatus',
      this,
    );
    submittedDate = _i1.ColumnDateTime(
      'submittedDate',
      this,
    );
    verifiedDate = _i1.ColumnDateTime(
      'verifiedDate',
      this,
    );
    verificationNotes = _i1.ColumnString(
      'verificationNotes',
      this,
    );
  }

  late final HospitalProfileRecordUpdateTable updateTable;

  late final _i1.ColumnString hospitalKey;

  late final _i1.ColumnString name;

  late final _i1.ColumnString legalName;

  late final _i1.ColumnString displayName;

  late final _i1.ColumnString hospitalType;

  late final _i1.ColumnString establishmentDate;

  late final _i1.ColumnString registrationLicenseId;

  late final _i1.ColumnString taxId;

  late final _i1.ColumnString accreditationInfo;

  late final _i1.ColumnString email;

  late final _i1.ColumnString emergencyHelpline;

  late final _i1.ColumnString receptionPhone;

  late final _i1.ColumnString website;

  late final _i1.ColumnString address;

  late final _i1.ColumnString city;

  late final _i1.ColumnString state;

  late final _i1.ColumnString country;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnInt totalBeds;

  late final _i1.ColumnInt icuBeds;

  late final _i1.ColumnInt operatingTheatres;

  late final _i1.ColumnInt emergencyCapacity;

  late final _i1.ColumnBool has247Emergency;

  late final _i1.ColumnString traumaLevel;

  late final _i1.ColumnBool hasAmbulance;

  late final _i1.ColumnString opdTimings;

  late final _i1.ColumnString operatingStatus;

  late final _i1.ColumnString verificationStatus;

  late final _i1.ColumnDateTime submittedDate;

  late final _i1.ColumnDateTime verifiedDate;

  late final _i1.ColumnString verificationNotes;

  @override
  List<_i1.Column> get columns => [
    id,
    hospitalKey,
    name,
    legalName,
    displayName,
    hospitalType,
    establishmentDate,
    registrationLicenseId,
    taxId,
    accreditationInfo,
    email,
    emergencyHelpline,
    receptionPhone,
    website,
    address,
    city,
    state,
    country,
    latitude,
    longitude,
    totalBeds,
    icuBeds,
    operatingTheatres,
    emergencyCapacity,
    has247Emergency,
    traumaLevel,
    hasAmbulance,
    opdTimings,
    operatingStatus,
    verificationStatus,
    submittedDate,
    verifiedDate,
    verificationNotes,
  ];
}

class HospitalProfileRecordInclude extends _i1.IncludeObject {
  HospitalProfileRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => HospitalProfileRecord.t;
}

class HospitalProfileRecordIncludeList extends _i1.IncludeList {
  HospitalProfileRecordIncludeList._({
    _i1.WhereExpressionBuilder<HospitalProfileRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(HospitalProfileRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => HospitalProfileRecord.t;
}

class HospitalProfileRecordRepository {
  const HospitalProfileRecordRepository._();

  /// Returns a list of [HospitalProfileRecord]s matching the given query parameters.
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
  Future<List<HospitalProfileRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalProfileRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalProfileRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalProfileRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<HospitalProfileRecord>(
      where: where?.call(HospitalProfileRecord.t),
      orderBy: orderBy?.call(HospitalProfileRecord.t),
      orderByList: orderByList?.call(HospitalProfileRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [HospitalProfileRecord] matching the given query parameters.
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
  Future<HospitalProfileRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalProfileRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<HospitalProfileRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HospitalProfileRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<HospitalProfileRecord>(
      where: where?.call(HospitalProfileRecord.t),
      orderBy: orderBy?.call(HospitalProfileRecord.t),
      orderByList: orderByList?.call(HospitalProfileRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [HospitalProfileRecord] by its [id] or null if no such row exists.
  Future<HospitalProfileRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<HospitalProfileRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [HospitalProfileRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [HospitalProfileRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<HospitalProfileRecord>> insert(
    _i1.DatabaseSession session,
    List<HospitalProfileRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<HospitalProfileRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [HospitalProfileRecord] and returns the inserted row.
  ///
  /// The returned [HospitalProfileRecord] will have its `id` field set.
  Future<HospitalProfileRecord> insertRow(
    _i1.DatabaseSession session,
    HospitalProfileRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<HospitalProfileRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [HospitalProfileRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<HospitalProfileRecord>> update(
    _i1.DatabaseSession session,
    List<HospitalProfileRecord> rows, {
    _i1.ColumnSelections<HospitalProfileRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<HospitalProfileRecord>(
      rows,
      columns: columns?.call(HospitalProfileRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalProfileRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<HospitalProfileRecord> updateRow(
    _i1.DatabaseSession session,
    HospitalProfileRecord row, {
    _i1.ColumnSelections<HospitalProfileRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<HospitalProfileRecord>(
      row,
      columns: columns?.call(HospitalProfileRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [HospitalProfileRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<HospitalProfileRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<HospitalProfileRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<HospitalProfileRecord>(
      id,
      columnValues: columnValues(HospitalProfileRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [HospitalProfileRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<HospitalProfileRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<HospitalProfileRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<HospitalProfileRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HospitalProfileRecordTable>? orderBy,
    _i1.OrderByListBuilder<HospitalProfileRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<HospitalProfileRecord>(
      columnValues: columnValues(HospitalProfileRecord.t.updateTable),
      where: where(HospitalProfileRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(HospitalProfileRecord.t),
      orderByList: orderByList?.call(HospitalProfileRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [HospitalProfileRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<HospitalProfileRecord>> delete(
    _i1.DatabaseSession session,
    List<HospitalProfileRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<HospitalProfileRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [HospitalProfileRecord].
  Future<HospitalProfileRecord> deleteRow(
    _i1.DatabaseSession session,
    HospitalProfileRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<HospitalProfileRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<HospitalProfileRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalProfileRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<HospitalProfileRecord>(
      where: where(HospitalProfileRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<HospitalProfileRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<HospitalProfileRecord>(
      where: where?.call(HospitalProfileRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [HospitalProfileRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<HospitalProfileRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<HospitalProfileRecord>(
      where: where(HospitalProfileRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
