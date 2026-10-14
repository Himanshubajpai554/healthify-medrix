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

import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:healthify_server_client/src/protocol/greetings/greeting.dart'
    as _i5;
import 'package:healthify_server_client/src/protocol/hospital/hospital_operational_record.dart'
    as _i6;
import 'package:healthify_server_client/src/protocol/hospital/hospital_audit_event.dart'
    as _i7;
import 'dart:typed_data' as _i8;
import 'package:healthify_server_client/src/protocol/hospital/hospital_membership.dart'
    as _i9;
import 'package:healthify_server_client/src/protocol/hospital/hospital_info.dart'
    as _i10;
import 'package:healthify_server_client/src/protocol/hospital/hospital_profile.dart'
    as _i11;
import 'package:healthify_server_client/src/protocol/hospital/verification_document.dart'
    as _i12;
import 'package:healthify_server_client/src/protocol/hospital/hospital_settings.dart'
    as _i13;
import 'package:healthify_server_client/src/protocol/hospital/hospital_user_access.dart'
    as _i14;
import 'protocol.dart' as _i15;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Hospital APIs are always authenticated and every tenant read/write is
/// checked against the signed-in account's active hospital membership.
/// {@category Endpoint}
class EndpointHospital extends _i2.EndpointRef {
  EndpointHospital(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'hospital';

  /// Returns only verified hospitals that have enabled patient discovery.
  /// Doctor records are drawn from those hospitals' own operational rows.
  _i3.Future<String> getPatientDirectory(String collection) =>
      caller.callServerEndpoint<String>(
        'hospital',
        'getPatientDirectory',
        {'collection': collection},
      );

  /// Patient portal data is partitioned by the authenticated Serverpod user.
  /// The caller never supplies the partition key, so one patient cannot read
  /// or overwrite another patient's records.
  _i3.Future<List<_i6.HospitalOperationalRecord>> listMyPatientRecords(
    String collection, {
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i6.HospitalOperationalRecord>>(
    'hospital',
    'listMyPatientRecords',
    {
      'collection': collection,
      'limit': limit,
      'offset': offset,
    },
  );

  _i3.Future<_i6.HospitalOperationalRecord?> getMyPatientRecord(
    String collection,
    String recordKey,
  ) => caller.callServerEndpoint<_i6.HospitalOperationalRecord?>(
    'hospital',
    'getMyPatientRecord',
    {
      'collection': collection,
      'recordKey': recordKey,
    },
  );

  _i3.Future<_i6.HospitalOperationalRecord> saveMyPatientRecord(
    String collection,
    String recordKey,
    String payload,
  ) => caller.callServerEndpoint<_i6.HospitalOperationalRecord>(
    'hospital',
    'saveMyPatientRecord',
    {
      'collection': collection,
      'recordKey': recordKey,
      'payload': payload,
    },
  );

  _i3.Future<bool> deleteMyPatientRecord(
    String collection,
    String recordKey,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'deleteMyPatientRecord',
    {
      'collection': collection,
      'recordKey': recordKey,
    },
  );

  /// Starts a claim for a hospital patient record. A hospital administrator
  /// must verify the patient's identity and approve the request before any
  /// clinical data is connected to this account.
  _i3.Future<String> requestHospitalPatientAccountLink(
    String hospitalKey,
    String patientId,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'requestHospitalPatientAccountLink',
    {
      'hospitalKey': hospitalKey,
      'patientId': patientId,
    },
  );

  /// Lists pending claims for staff authorized to manage hospital accounts.
  _i3.Future<String> listHospitalPatientAccountLinkRequests(
    String hospitalKey,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'listHospitalPatientAccountLinkRequests',
    {'hospitalKey': hospitalKey},
  );

  /// Approves or rejects a claim. Approval is blocked unless the hospital
  /// patient record exists and is not already linked to another account.
  _i3.Future<bool> reviewHospitalPatientAccountLinkRequest(
    String hospitalKey,
    String requestId,
    bool approve,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'reviewHospitalPatientAccountLinkRequest',
    {
      'hospitalKey': hospitalKey,
      'requestId': requestId,
      'approve': approve,
    },
  );

  /// Returns only the current user's approved hospital links.
  _i3.Future<String> listMyHospitalPatientAccountLinks() =>
      caller.callServerEndpoint<String>(
        'hospital',
        'listMyHospitalPatientAccountLinks',
        {},
      );

  _i3.Future<String> listMyHospitalPatientAccountLinkRequests() =>
      caller.callServerEndpoint<String>(
        'hospital',
        'listMyHospitalPatientAccountLinkRequests',
        {},
      );

  /// A patient can revoke only links owned by their authenticated account.
  _i3.Future<bool> revokeMyHospitalPatientAccountLink(
    String hospitalKey,
    String patientId,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'revokeMyHospitalPatientAccountLink',
    {
      'hospitalKey': hospitalKey,
      'patientId': patientId,
    },
  );

  _i3.Future<bool> checkMyPatientReviewEligibility(
    String targetType,
    String targetId,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'checkMyPatientReviewEligibility',
    {
      'targetType': targetType,
      'targetId': targetId,
    },
  );

  _i3.Future<String> listPatientReviews(
    String targetType,
    String targetId,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'listPatientReviews',
    {
      'targetType': targetType,
      'targetId': targetId,
    },
  );

  _i3.Future<String> createPatientReview(
    String targetType,
    String targetId,
    double rating,
    String feedback,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'createPatientReview',
    {
      'targetType': targetType,
      'targetId': targetId,
      'rating': rating,
      'feedback': feedback,
    },
  );

  _i3.Future<List<_i6.HospitalOperationalRecord>> listOperationalRecords(
    String hospitalKey,
    String collection, {
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i6.HospitalOperationalRecord>>(
    'hospital',
    'listOperationalRecords',
    {
      'hospitalKey': hospitalKey,
      'collection': collection,
      'limit': limit,
      'offset': offset,
    },
  );

  _i3.Future<_i6.HospitalOperationalRecord?> getOperationalRecord(
    String hospitalKey,
    String collection,
    String recordKey,
  ) => caller.callServerEndpoint<_i6.HospitalOperationalRecord?>(
    'hospital',
    'getOperationalRecord',
    {
      'hospitalKey': hospitalKey,
      'collection': collection,
      'recordKey': recordKey,
    },
  );

  /// Tenant-scoped JSON records back hospital operational modules. The
  /// database uniqueness constraint makes concurrent upserts deterministic.
  _i3.Future<_i6.HospitalOperationalRecord> saveOperationalRecord(
    String hospitalKey,
    String collection,
    String recordKey,
    String payload,
  ) => caller.callServerEndpoint<_i6.HospitalOperationalRecord>(
    'hospital',
    'saveOperationalRecord',
    {
      'hospitalKey': hospitalKey,
      'collection': collection,
      'recordKey': recordKey,
      'payload': payload,
    },
  );

  /// Saves a related set of operational rows and their audit events as one
  /// database transaction. Used for bed transfers and blood allocation so a
  /// failed write cannot leave only half of a workflow persisted.
  _i3.Future<List<_i6.HospitalOperationalRecord>> saveOperationalRecords(
    String hospitalKey,
    List<String> collections,
    List<String> recordKeys,
    List<String> payloads,
  ) => caller.callServerEndpoint<List<_i6.HospitalOperationalRecord>>(
    'hospital',
    'saveOperationalRecords',
    {
      'hospitalKey': hospitalKey,
      'collections': collections,
      'recordKeys': recordKeys,
      'payloads': payloads,
    },
  );

  /// Creates an active admission while serializing competing admissions for
  /// the same patient. A private lock row is upserted first inside the same
  /// transaction; PostgreSQL's unique-key conflict lock makes a concurrent
  /// request wait, then re-check the committed active admission.
  _i3.Future<_i6.HospitalOperationalRecord> createAdmission(
    String hospitalKey,
    String patientId,
    String recordKey,
    String payload,
  ) => caller.callServerEndpoint<_i6.HospitalOperationalRecord>(
    'hospital',
    'createAdmission',
    {
      'hospitalKey': hospitalKey,
      'patientId': patientId,
      'recordKey': recordKey,
      'payload': payload,
    },
  );

  _i3.Future<bool> deleteOperationalRecord(
    String hospitalKey,
    String collection,
    String recordKey,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'deleteOperationalRecord',
    {
      'hospitalKey': hospitalKey,
      'collection': collection,
      'recordKey': recordKey,
    },
  );

  _i3.Future<List<_i7.HospitalAuditEvent>> getOperationalAuditEvents(
    String hospitalKey, {
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i7.HospitalAuditEvent>>(
    'hospital',
    'getOperationalAuditEvents',
    {
      'hospitalKey': hospitalKey,
      'limit': limit,
      'offset': offset,
    },
  );

  _i3.Future<void> logAuditAction(
    String hospitalKey,
    String action,
    String targetEntityType,
    String targetEntityId,
    String details,
  ) => caller.callServerEndpoint<void>(
    'hospital',
    'logAuditAction',
    {
      'hospitalKey': hospitalKey,
      'action': action,
      'targetEntityType': targetEntityType,
      'targetEntityId': targetEntityId,
      'details': details,
    },
  );

  /// Uploads a file for a patient-owned external medical report and stores it
  /// in private storage. The storage path is derived from the authenticated
  /// user's identifier — the caller never supplies it. After a successful
  /// store the corresponding patientReports record payload is updated with a
  /// [fileReference] block so that the app can show download status.
  ///
  /// Constraints:
  ///  - File must be PDF, PNG, or JPEG and pass a magic-byte check.
  ///  - Max size: 20 MB.
  ///  - The [recordKey] must already exist in the caller's patientReports
  ///    partition (the metadata record is saved first via [saveMyPatientRecord],
  ///    then this endpoint attaches the bytes).
  _i3.Future<String> uploadPatientReportFile(
    String recordKey,
    String fileName,
    String mimeType,
    _i8.ByteData fileBytes,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'uploadPatientReportFile',
    {
      'recordKey': recordKey,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileBytes': fileBytes,
    },
  );

  /// Returns the raw bytes for a patient's own uploaded report file.
  /// Only the account that owns the patientReports partition can download.
  _i3.Future<_i8.ByteData> getPatientReportFileBytes(String recordKey) =>
      caller.callServerEndpoint<_i8.ByteData>(
        'hospital',
        'getPatientReportFileBytes',
        {'recordKey': recordKey},
      );

  _i3.Future<_i9.HospitalMembershipRecord?> getMyHospital() =>
      caller.callServerEndpoint<_i9.HospitalMembershipRecord?>(
        'hospital',
        'getMyHospital',
        {},
      );

  /// Resolves the signed-in doctor to the doctor profile assigned by their
  /// hospital. A doctor cannot choose another profile by sending an ID.
  _i3.Future<String> getMyDoctorProfile(String hospitalKey) =>
      caller.callServerEndpoint<String>(
        'hospital',
        'getMyDoctorProfile',
        {'hospitalKey': hospitalKey},
      );

  /// Creates the first hospital profile for the signed-in account and makes
  /// the account its initial owner. The operation is atomic.
  _i3.Future<_i9.HospitalMembershipRecord> registerHospital(
    _i10.HospitalInfoRecord info,
    _i11.HospitalProfileRecord profile,
  ) => caller.callServerEndpoint<_i9.HospitalMembershipRecord>(
    'hospital',
    'registerHospital',
    {
      'info': info,
      'profile': profile,
    },
  );

  _i3.Future<_i10.HospitalInfoRecord?> getInfo(String hospitalKey) =>
      caller.callServerEndpoint<_i10.HospitalInfoRecord?>(
        'hospital',
        'getInfo',
        {'hospitalKey': hospitalKey},
      );

  _i3.Future<_i10.HospitalInfoRecord> saveInfo(_i10.HospitalInfoRecord info) =>
      caller.callServerEndpoint<_i10.HospitalInfoRecord>(
        'hospital',
        'saveInfo',
        {'info': info},
      );

  _i3.Future<_i11.HospitalProfileRecord?> getProfile(String hospitalKey) =>
      caller.callServerEndpoint<_i11.HospitalProfileRecord?>(
        'hospital',
        'getProfile',
        {'hospitalKey': hospitalKey},
      );

  _i3.Future<_i11.HospitalProfileRecord> saveProfile(
    _i11.HospitalProfileRecord profile,
  ) => caller.callServerEndpoint<_i11.HospitalProfileRecord>(
    'hospital',
    'saveProfile',
    {'profile': profile},
  );

  _i3.Future<String> getVerificationStatus(String hospitalKey) =>
      caller.callServerEndpoint<String>(
        'hospital',
        'getVerificationStatus',
        {'hospitalKey': hospitalKey},
      );

  _i3.Future<_i12.VerificationDocumentRecord> uploadVerificationDocument(
    String hospitalKey,
    String title,
    String documentType,
    String fileName,
    String mimeType,
    _i8.ByteData fileBytes,
  ) => caller.callServerEndpoint<_i12.VerificationDocumentRecord>(
    'hospital',
    'uploadVerificationDocument',
    {
      'hospitalKey': hospitalKey,
      'title': title,
      'documentType': documentType,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileBytes': fileBytes,
    },
  );

  _i3.Future<_i8.ByteData> getVerificationDocumentBytes(
    String hospitalKey,
    int documentId,
  ) => caller.callServerEndpoint<_i8.ByteData>(
    'hospital',
    'getVerificationDocumentBytes',
    {
      'hospitalKey': hospitalKey,
      'documentId': documentId,
    },
  );

  _i3.Future<String> uploadDoctorReportFile(
    String hospitalKey,
    String reportId,
    String fileName,
    String mimeType,
    _i8.ByteData fileBytes,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'uploadDoctorReportFile',
    {
      'hospitalKey': hospitalKey,
      'reportId': reportId,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileBytes': fileBytes,
    },
  );

  _i3.Future<_i8.ByteData> getDoctorReportFileBytes(
    String hospitalKey,
    String reportId,
  ) => caller.callServerEndpoint<_i8.ByteData>(
    'hospital',
    'getDoctorReportFileBytes',
    {
      'hospitalKey': hospitalKey,
      'reportId': reportId,
    },
  );

  /// Releases a reviewed report into an explicitly linked patient account.
  /// The account owner comes from the hospital-approved link, never from the
  /// doctor request, and both portal/source rows change atomically.
  _i3.Future<String> setDoctorReportPatientSharing(
    String hospitalKey,
    String reportId,
    bool isShared,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'setDoctorReportPatientSharing',
    {
      'hospitalKey': hospitalKey,
      'reportId': reportId,
      'isShared': isShared,
    },
  );

  /// Returns a shared report file only while its owner-scoped portal record
  /// and the source doctor's release flag both remain active.
  _i3.Future<_i8.ByteData> getMySharedReportFileBytes(String reportId) =>
      caller.callServerEndpoint<_i8.ByteData>(
        'hospital',
        'getMySharedReportFileBytes',
        {'reportId': reportId},
      );

  /// Approves or rejects an emergency clinical break-glass request.
  /// Approval grants a temporary time-bounded access window (60 minutes).
  _i3.Future<bool> reviewBreakGlassRequest(
    String hospitalKey,
    String requestId,
    bool approve,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'reviewBreakGlassRequest',
    {
      'hospitalKey': hospitalKey,
      'requestId': requestId,
      'approve': approve,
    },
  );

  _i3.Future<_i11.HospitalProfileRecord> submitVerification(
    String hospitalKey,
  ) => caller.callServerEndpoint<_i11.HospitalProfileRecord>(
    'hospital',
    'submitVerification',
    {'hospitalKey': hospitalKey},
  );

  _i3.Future<List<_i12.VerificationDocumentRecord>> getVerificationDocuments(
    String hospitalKey,
  ) => caller.callServerEndpoint<List<_i12.VerificationDocumentRecord>>(
    'hospital',
    'getVerificationDocuments',
    {'hospitalKey': hospitalKey},
  );

  _i3.Future<_i13.HospitalSettingsRecord?> getSettings(String hospitalKey) =>
      caller.callServerEndpoint<_i13.HospitalSettingsRecord?>(
        'hospital',
        'getSettings',
        {'hospitalKey': hospitalKey},
      );

  /// Lists all hospitals pending platform verification review (P1-11).
  _i3.Future<List<_i11.HospitalProfileRecord>>
  listPendingHospitalVerifications() =>
      caller.callServerEndpoint<List<_i11.HospitalProfileRecord>>(
        'hospital',
        'listPendingHospitalVerifications',
        {},
      );

  /// Platform reviewer decision: approves or rejects hospital platform credentials (P1-11).
  _i3.Future<bool> reviewHospitalVerification(
    String hospitalKey,
    bool approve,
    String reviewerNotes,
  ) => caller.callServerEndpoint<bool>(
    'hospital',
    'reviewHospitalVerification',
    {
      'hospitalKey': hospitalKey,
      'approve': approve,
      'reviewerNotes': reviewerNotes,
    },
  );

  /// Dispatches an onboarding invitation to a new doctor or hospital staff member (P1-10).
  /// Creates a provisional access record and dispatches an activation token via email.
  _i3.Future<String> inviteHospitalStaff(
    String hospitalKey,
    String email,
    String fullName,
    String role,
    String department,
  ) => caller.callServerEndpoint<String>(
    'hospital',
    'inviteHospitalStaff',
    {
      'hospitalKey': hospitalKey,
      'email': email,
      'fullName': fullName,
      'role': role,
      'department': department,
    },
  );

  _i3.Future<_i13.HospitalSettingsRecord> saveSettings(
    _i13.HospitalSettingsRecord settings,
  ) => caller.callServerEndpoint<_i13.HospitalSettingsRecord>(
    'hospital',
    'saveSettings',
    {'settings': settings},
  );

  _i3.Future<List<_i14.HospitalUserAccessRecord>> getUserAccessList(
    String hospitalKey,
  ) => caller.callServerEndpoint<List<_i14.HospitalUserAccessRecord>>(
    'hospital',
    'getUserAccessList',
    {'hospitalKey': hospitalKey},
  );

  _i3.Future<_i14.HospitalUserAccessRecord> saveUserAccess(
    _i14.HospitalUserAccessRecord user,
  ) => caller.callServerEndpoint<_i14.HospitalUserAccessRecord>(
    'hospital',
    'saveUserAccess',
    {'user': user},
  );

  _i3.Future<void> updateUserRole(
    String hospitalKey,
    String userKey,
    String role,
  ) => caller.callServerEndpoint<void>(
    'hospital',
    'updateUserRole',
    {
      'hospitalKey': hospitalKey,
      'userKey': userKey,
      'role': role,
    },
  );

  _i3.Future<void> setUserAccess(
    String hospitalKey,
    String userKey,
    bool isActive,
  ) => caller.callServerEndpoint<void>(
    'hospital',
    'setUserAccess',
    {
      'hospitalKey': hospitalKey,
      'userKey': userKey,
      'isActive': isActive,
    },
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i15.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    greeting = EndpointGreeting(this);
    hospital = EndpointHospital(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointGreeting greeting;

  late final EndpointHospital hospital;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'greeting': greeting,
    'hospital': hospital,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
