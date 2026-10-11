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

import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class VerificationDocumentRecord implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String title;

  String documentType;

  String fileUrl;

  DateTime uploadDate;

  String status;

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
