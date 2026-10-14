import 'dart:convert';
import 'dart:typed_data';

import 'package:healthify_server_server/src/generated/protocol.dart';
import 'package:healthify_server_server/src/hospital/hospital_endpoint.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Patient Hospital Clinical Flows E2E', (sessionBuilder, endpoints) {
    test('Patient partition isolation, account linking lifecycle, and report upload', () async {
      const hospitalKey = 'hosp-clinical-flow-e2e';
      const adminUser = 'admin-clinical-flow-e2e';
      const patientA = 'patient-a-e2e';
      const patientB = 'patient-b-e2e';
      const hospitalPatientId = 'pat-mrn-1001-e2e';
      final now = DateTime.now().toUtc();

      final adminSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(adminUser, const {}),
      );
      final patientASession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(patientA, const {}),
      );
      final patientBSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(patientB, const {}),
      );

      final setupSession = adminSession.build();

      // Setup hospital membership for admin
      await HospitalMembershipRecord.db.insertRow(
        setupSession,
        HospitalMembershipRecord(
          hospitalKey: hospitalKey,
          userIdentifier: adminUser,
          role: 'hospitalAdmin',
          isActive: true,
        ),
      );

      // Setup physical hospital patient record in hospital
      await HospitalOperationalRecord.db.insertRow(
        setupSession,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'patients',
          recordKey: hospitalPatientId,
          payload: jsonEncode({
            'id': hospitalPatientId,
            'name': 'Clinical Test Patient',
            'mrn': 'MRN-1001',
            'phone': '+91 98765 43210',
          }),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // ── 1. PATIENT PORTAL OWNERSHIP & ISOLATION ────────────────────────────
      final pAEndpoint = endpoints.hospital;

      // Patient A saves their profile
      await pAEndpoint.saveMyPatientRecord(
        patientASession,
        'patientProfiles',
        'profile',
        jsonEncode({'id': 'profile', 'name': 'Patient Alice', 'bloodGroup': 'O+'}),
      );

      final fetchedProfile = await pAEndpoint.getMyPatientRecord(
        patientASession,
        'patientProfiles',
        'profile',
      );
      expect(fetchedProfile, isNotNull);
      final profileData = jsonDecode(fetchedProfile!.payload) as Map<String, dynamic>;
      expect(profileData['name'], 'Patient Alice');
      expect(profileData['_owner'], patientA);

      // Patient B cannot see Patient A's profile
      final patientBView = await pAEndpoint.getMyPatientRecord(
        patientBSession,
        'patientProfiles',
        'profile',
      );
      expect(patientBView, isNull);

      // ── 2. ACCOUNT LINKING: CLAIM, REVIEW, LOCK, REVOKE ────────────────────
      // Patient A requests to link their account to hospitalPatientId
      final claimStatus = await pAEndpoint.requestHospitalPatientAccountLink(
        patientASession,
        hospitalKey,
        hospitalPatientId,
      );
      expect(claimStatus, 'pending');

      // Admin lists pending link requests
      final pendingClaimsJson = await pAEndpoint.listHospitalPatientAccountLinkRequests(
        adminSession,
        hospitalKey,
      );
      final pendingClaims = jsonDecode(pendingClaimsJson) as List;
      expect(pendingClaims.isNotEmpty, isTrue);

      final claim = pendingClaims.firstWhere(
        (c) => c['patientId'] == hospitalPatientId && c['requesterUserIdentifier'] == patientA,
      );
      final requestId = '${claim['requestId']}';

      // Admin approves the request
      final approvalResult = await pAEndpoint.reviewHospitalPatientAccountLinkRequest(
        adminSession,
        hospitalKey,
        requestId,
        true,
      );
      expect(approvalResult, isTrue);

      // Patient B tries to claim the same patient record -> must be blocked
      await pAEndpoint.requestHospitalPatientAccountLink(
        patientBSession,
        hospitalKey,
        hospitalPatientId,
      );
      final pendingClaimsForBJson = await pAEndpoint.listHospitalPatientAccountLinkRequests(
        adminSession,
        hospitalKey,
      );
      final pendingForB = (jsonDecode(pendingClaimsForBJson) as List).firstWhere(
        (c) => c['patientId'] == hospitalPatientId && c['requesterUserIdentifier'] == patientB,
      );
      expect(
        () => pAEndpoint.reviewHospitalPatientAccountLinkRequest(
          adminSession,
          hospitalKey,
          '${pendingForB['requestId']}',
          true,
        ),
        throwsA(isA<Exception>()),
      );

      // Patient A can revoke their link
      final revoked = await pAEndpoint.revokeMyHospitalPatientAccountLink(
        patientASession,
        hospitalKey,
        hospitalPatientId,
      );
      expect(revoked, isTrue);

      // ── 3. PATIENT REPORT UPLOAD AND RETRIEVAL ──────────────────────────────
      const reportKey = 'rep-upload-test-01';
      final pdfBytes = Uint8List.fromList([
        0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
        ...List.filled(20, 0x20),
      ]);
      final byteData = ByteData.view(pdfBytes.buffer, pdfBytes.offsetInBytes, pdfBytes.length);

      // Patient saves report metadata first (isExternalUploaded = true required)
      await pAEndpoint.saveMyPatientRecord(
        patientASession,
        'patientReports',
        reportKey,
        jsonEncode({
          'id': reportKey,
          'title': 'Test Blood Panel',
          'category': 'Lab Reports',
          'isExternalUploaded': true,
          'hasAttachedFile': false,
        }),
      );

      // Patient uploads file via HospitalEndpoint
      final directEndpoint = HospitalEndpoint();
      final pASessionBuilt = patientASession.build();
      final uploadRef = await directEndpoint.uploadPatientReportFile(
        pASessionBuilt,
        reportKey,
        'blood_panel.pdf',
        'application/pdf',
        byteData,
      );
      expect(uploadRef.contains('patient-reports/$patientA'), isTrue);

      // Patient downloads their report file
      final downloadedBytes = await directEndpoint.getPatientReportFileBytes(
        pASessionBuilt,
        reportKey,
      );
      expect(downloadedBytes.lengthInBytes, byteData.lengthInBytes);

      // Patient B cannot download Patient A's report file
      final pBSessionBuilt = patientBSession.build();
      expect(
        () => directEndpoint.getPatientReportFileBytes(pBSessionBuilt, reportKey),
        throwsA(isA<Exception>()),
      );
    });
  });
}
