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
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../greetings/greeting_endpoint.dart' as _i4;
import '../hospital/hospital_endpoint.dart' as _i5;
import 'dart:typed_data' as _i6;
import 'package:healthify_server_server/src/generated/hospital/hospital_info.dart'
    as _i7;
import 'package:healthify_server_server/src/generated/hospital/hospital_profile.dart'
    as _i8;
import 'package:healthify_server_server/src/generated/hospital/hospital_settings.dart'
    as _i9;
import 'package:healthify_server_server/src/generated/hospital/hospital_user_access.dart'
    as _i10;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i11;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i12;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'greeting': _i4.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'hospital': _i5.HospitalEndpoint()
        ..initialize(
          server,
          'hospital',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i4.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['hospital'] = _i1.EndpointConnector(
      name: 'hospital',
      endpoint: endpoints['hospital']!,
      methodConnectors: {
        'getPatientDirectory': _i1.MethodConnector(
          name: 'getPatientDirectory',
          params: {
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getPatientDirectory(
                    session,
                    params['collection'],
                  ),
        ),
        'listMyPatientRecords': _i1.MethodConnector(
          name: 'listMyPatientRecords',
          params: {
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listMyPatientRecords(
                    session,
                    params['collection'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getMyPatientRecord': _i1.MethodConnector(
          name: 'getMyPatientRecord',
          params: {
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getMyPatientRecord(
                    session,
                    params['collection'],
                    params['recordKey'],
                  ),
        ),
        'saveMyPatientRecord': _i1.MethodConnector(
          name: 'saveMyPatientRecord',
          params: {
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .saveMyPatientRecord(
                    session,
                    params['collection'],
                    params['recordKey'],
                    params['payload'],
                  ),
        ),
        'deleteMyPatientRecord': _i1.MethodConnector(
          name: 'deleteMyPatientRecord',
          params: {
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .deleteMyPatientRecord(
                    session,
                    params['collection'],
                    params['recordKey'],
                  ),
        ),
        'requestHospitalPatientAccountLink': _i1.MethodConnector(
          name: 'requestHospitalPatientAccountLink',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'patientId': _i1.ParameterDescription(
              name: 'patientId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .requestHospitalPatientAccountLink(
                    session,
                    params['hospitalKey'],
                    params['patientId'],
                  ),
        ),
        'listHospitalPatientAccountLinkRequests': _i1.MethodConnector(
          name: 'listHospitalPatientAccountLinkRequests',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listHospitalPatientAccountLinkRequests(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'reviewHospitalPatientAccountLinkRequest': _i1.MethodConnector(
          name: 'reviewHospitalPatientAccountLinkRequest',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'requestId': _i1.ParameterDescription(
              name: 'requestId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'approve': _i1.ParameterDescription(
              name: 'approve',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .reviewHospitalPatientAccountLinkRequest(
                    session,
                    params['hospitalKey'],
                    params['requestId'],
                    params['approve'],
                  ),
        ),
        'listMyHospitalPatientAccountLinks': _i1.MethodConnector(
          name: 'listMyHospitalPatientAccountLinks',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listMyHospitalPatientAccountLinks(session),
        ),
        'listMyHospitalPatientAccountLinkRequests': _i1.MethodConnector(
          name: 'listMyHospitalPatientAccountLinkRequests',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listMyHospitalPatientAccountLinkRequests(session),
        ),
        'revokeMyHospitalPatientAccountLink': _i1.MethodConnector(
          name: 'revokeMyHospitalPatientAccountLink',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'patientId': _i1.ParameterDescription(
              name: 'patientId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .revokeMyHospitalPatientAccountLink(
                    session,
                    params['hospitalKey'],
                    params['patientId'],
                  ),
        ),
        'checkMyPatientReviewEligibility': _i1.MethodConnector(
          name: 'checkMyPatientReviewEligibility',
          params: {
            'targetType': _i1.ParameterDescription(
              name: 'targetType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetId': _i1.ParameterDescription(
              name: 'targetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .checkMyPatientReviewEligibility(
                    session,
                    params['targetType'],
                    params['targetId'],
                  ),
        ),
        'listPatientReviews': _i1.MethodConnector(
          name: 'listPatientReviews',
          params: {
            'targetType': _i1.ParameterDescription(
              name: 'targetType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetId': _i1.ParameterDescription(
              name: 'targetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listPatientReviews(
                    session,
                    params['targetType'],
                    params['targetId'],
                  ),
        ),
        'createPatientReview': _i1.MethodConnector(
          name: 'createPatientReview',
          params: {
            'targetType': _i1.ParameterDescription(
              name: 'targetType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetId': _i1.ParameterDescription(
              name: 'targetId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'rating': _i1.ParameterDescription(
              name: 'rating',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'feedback': _i1.ParameterDescription(
              name: 'feedback',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .createPatientReview(
                    session,
                    params['targetType'],
                    params['targetId'],
                    params['rating'],
                    params['feedback'],
                  ),
        ),
        'listOperationalRecords': _i1.MethodConnector(
          name: 'listOperationalRecords',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listOperationalRecords(
                    session,
                    params['hospitalKey'],
                    params['collection'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getOperationalRecord': _i1.MethodConnector(
          name: 'getOperationalRecord',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getOperationalRecord(
                    session,
                    params['hospitalKey'],
                    params['collection'],
                    params['recordKey'],
                  ),
        ),
        'saveOperationalRecord': _i1.MethodConnector(
          name: 'saveOperationalRecord',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .saveOperationalRecord(
                    session,
                    params['hospitalKey'],
                    params['collection'],
                    params['recordKey'],
                    params['payload'],
                  ),
        ),
        'saveOperationalRecords': _i1.MethodConnector(
          name: 'saveOperationalRecords',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'collections': _i1.ParameterDescription(
              name: 'collections',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'recordKeys': _i1.ParameterDescription(
              name: 'recordKeys',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'payloads': _i1.ParameterDescription(
              name: 'payloads',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .saveOperationalRecords(
                    session,
                    params['hospitalKey'],
                    params['collections'],
                    params['recordKeys'],
                    params['payloads'],
                  ),
        ),
        'createAdmission': _i1.MethodConnector(
          name: 'createAdmission',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'patientId': _i1.ParameterDescription(
              name: 'patientId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .createAdmission(
                    session,
                    params['hospitalKey'],
                    params['patientId'],
                    params['recordKey'],
                    params['payload'],
                  ),
        ),
        'deleteOperationalRecord': _i1.MethodConnector(
          name: 'deleteOperationalRecord',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'collection': _i1.ParameterDescription(
              name: 'collection',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .deleteOperationalRecord(
                    session,
                    params['hospitalKey'],
                    params['collection'],
                    params['recordKey'],
                  ),
        ),
        'getOperationalAuditEvents': _i1.MethodConnector(
          name: 'getOperationalAuditEvents',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getOperationalAuditEvents(
                    session,
                    params['hospitalKey'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'logAuditAction': _i1.MethodConnector(
          name: 'logAuditAction',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'action': _i1.ParameterDescription(
              name: 'action',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetEntityType': _i1.ParameterDescription(
              name: 'targetEntityType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetEntityId': _i1.ParameterDescription(
              name: 'targetEntityId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'details': _i1.ParameterDescription(
              name: 'details',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .logAuditAction(
                    session,
                    params['hospitalKey'],
                    params['action'],
                    params['targetEntityType'],
                    params['targetEntityId'],
                    params['details'],
                  ),
        ),
        'uploadPatientReportFile': _i1.MethodConnector(
          name: 'uploadPatientReportFile',
          params: {
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mimeType': _i1.ParameterDescription(
              name: 'mimeType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileBytes': _i1.ParameterDescription(
              name: 'fileBytes',
              type: _i1.getType<_i6.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .uploadPatientReportFile(
                    session,
                    params['recordKey'],
                    params['fileName'],
                    params['mimeType'],
                    params['fileBytes'],
                  ),
        ),
        'getPatientReportFileBytes': _i1.MethodConnector(
          name: 'getPatientReportFileBytes',
          params: {
            'recordKey': _i1.ParameterDescription(
              name: 'recordKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getPatientReportFileBytes(
                    session,
                    params['recordKey'],
                  ),
        ),
        'getMyHospital': _i1.MethodConnector(
          name: 'getMyHospital',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getMyHospital(session),
        ),
        'getMyDoctorProfile': _i1.MethodConnector(
          name: 'getMyDoctorProfile',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getMyDoctorProfile(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'registerHospital': _i1.MethodConnector(
          name: 'registerHospital',
          params: {
            'info': _i1.ParameterDescription(
              name: 'info',
              type: _i1.getType<_i7.HospitalInfoRecord>(),
              nullable: false,
            ),
            'profile': _i1.ParameterDescription(
              name: 'profile',
              type: _i1.getType<_i8.HospitalProfileRecord>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .registerHospital(
                    session,
                    params['info'],
                    params['profile'],
                  ),
        ),
        'getInfo': _i1.MethodConnector(
          name: 'getInfo',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).getInfo(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'saveInfo': _i1.MethodConnector(
          name: 'saveInfo',
          params: {
            'info': _i1.ParameterDescription(
              name: 'info',
              type: _i1.getType<_i7.HospitalInfoRecord>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).saveInfo(
                    session,
                    params['info'],
                  ),
        ),
        'getProfile': _i1.MethodConnector(
          name: 'getProfile',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).getProfile(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'saveProfile': _i1.MethodConnector(
          name: 'saveProfile',
          params: {
            'profile': _i1.ParameterDescription(
              name: 'profile',
              type: _i1.getType<_i8.HospitalProfileRecord>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).saveProfile(
                    session,
                    params['profile'],
                  ),
        ),
        'getVerificationStatus': _i1.MethodConnector(
          name: 'getVerificationStatus',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getVerificationStatus(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'uploadVerificationDocument': _i1.MethodConnector(
          name: 'uploadVerificationDocument',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentType': _i1.ParameterDescription(
              name: 'documentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mimeType': _i1.ParameterDescription(
              name: 'mimeType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileBytes': _i1.ParameterDescription(
              name: 'fileBytes',
              type: _i1.getType<_i6.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .uploadVerificationDocument(
                    session,
                    params['hospitalKey'],
                    params['title'],
                    params['documentType'],
                    params['fileName'],
                    params['mimeType'],
                    params['fileBytes'],
                  ),
        ),
        'getVerificationDocumentBytes': _i1.MethodConnector(
          name: 'getVerificationDocumentBytes',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'documentId': _i1.ParameterDescription(
              name: 'documentId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getVerificationDocumentBytes(
                    session,
                    params['hospitalKey'],
                    params['documentId'],
                  ),
        ),
        'uploadDoctorReportFile': _i1.MethodConnector(
          name: 'uploadDoctorReportFile',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reportId': _i1.ParameterDescription(
              name: 'reportId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mimeType': _i1.ParameterDescription(
              name: 'mimeType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileBytes': _i1.ParameterDescription(
              name: 'fileBytes',
              type: _i1.getType<_i6.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .uploadDoctorReportFile(
                    session,
                    params['hospitalKey'],
                    params['reportId'],
                    params['fileName'],
                    params['mimeType'],
                    params['fileBytes'],
                  ),
        ),
        'getDoctorReportFileBytes': _i1.MethodConnector(
          name: 'getDoctorReportFileBytes',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reportId': _i1.ParameterDescription(
              name: 'reportId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getDoctorReportFileBytes(
                    session,
                    params['hospitalKey'],
                    params['reportId'],
                  ),
        ),
        'setDoctorReportPatientSharing': _i1.MethodConnector(
          name: 'setDoctorReportPatientSharing',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reportId': _i1.ParameterDescription(
              name: 'reportId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isShared': _i1.ParameterDescription(
              name: 'isShared',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .setDoctorReportPatientSharing(
                    session,
                    params['hospitalKey'],
                    params['reportId'],
                    params['isShared'],
                  ),
        ),
        'getMySharedReportFileBytes': _i1.MethodConnector(
          name: 'getMySharedReportFileBytes',
          params: {
            'reportId': _i1.ParameterDescription(
              name: 'reportId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getMySharedReportFileBytes(
                    session,
                    params['reportId'],
                  ),
        ),
        'reviewBreakGlassRequest': _i1.MethodConnector(
          name: 'reviewBreakGlassRequest',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'requestId': _i1.ParameterDescription(
              name: 'requestId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'approve': _i1.ParameterDescription(
              name: 'approve',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .reviewBreakGlassRequest(
                    session,
                    params['hospitalKey'],
                    params['requestId'],
                    params['approve'],
                  ),
        ),
        'submitVerification': _i1.MethodConnector(
          name: 'submitVerification',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .submitVerification(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'getVerificationDocuments': _i1.MethodConnector(
          name: 'getVerificationDocuments',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getVerificationDocuments(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'getSettings': _i1.MethodConnector(
          name: 'getSettings',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).getSettings(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'listPendingHospitalVerifications': _i1.MethodConnector(
          name: 'listPendingHospitalVerifications',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .listPendingHospitalVerifications(session),
        ),
        'reviewHospitalVerification': _i1.MethodConnector(
          name: 'reviewHospitalVerification',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'approve': _i1.ParameterDescription(
              name: 'approve',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'reviewerNotes': _i1.ParameterDescription(
              name: 'reviewerNotes',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .reviewHospitalVerification(
                    session,
                    params['hospitalKey'],
                    params['approve'],
                    params['reviewerNotes'],
                  ),
        ),
        'inviteHospitalStaff': _i1.MethodConnector(
          name: 'inviteHospitalStaff',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fullName': _i1.ParameterDescription(
              name: 'fullName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'department': _i1.ParameterDescription(
              name: 'department',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .inviteHospitalStaff(
                    session,
                    params['hospitalKey'],
                    params['email'],
                    params['fullName'],
                    params['role'],
                    params['department'],
                  ),
        ),
        'saveSettings': _i1.MethodConnector(
          name: 'saveSettings',
          params: {
            'settings': _i1.ParameterDescription(
              name: 'settings',
              type: _i1.getType<_i9.HospitalSettingsRecord>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).saveSettings(
                    session,
                    params['settings'],
                  ),
        ),
        'getUserAccessList': _i1.MethodConnector(
          name: 'getUserAccessList',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .getUserAccessList(
                    session,
                    params['hospitalKey'],
                  ),
        ),
        'saveUserAccess': _i1.MethodConnector(
          name: 'saveUserAccess',
          params: {
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i10.HospitalUserAccessRecord>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .saveUserAccess(
                    session,
                    params['user'],
                  ),
        ),
        'updateUserRole': _i1.MethodConnector(
          name: 'updateUserRole',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'userKey': _i1.ParameterDescription(
              name: 'userKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['hospital'] as _i5.HospitalEndpoint)
                  .updateUserRole(
                    session,
                    params['hospitalKey'],
                    params['userKey'],
                    params['role'],
                  ),
        ),
        'setUserAccess': _i1.MethodConnector(
          name: 'setUserAccess',
          params: {
            'hospitalKey': _i1.ParameterDescription(
              name: 'hospitalKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'userKey': _i1.ParameterDescription(
              name: 'userKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isActive': _i1.ParameterDescription(
              name: 'isActive',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['hospital'] as _i5.HospitalEndpoint).setUserAccess(
                    session,
                    params['hospitalKey'],
                    params['userKey'],
                    params['isActive'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i11.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i12.Endpoints()
      ..initializeEndpoints(server);
  }
}
