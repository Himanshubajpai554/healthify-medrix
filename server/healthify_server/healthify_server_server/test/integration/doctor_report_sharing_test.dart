import 'dart:convert';
import 'dart:typed_data';

import 'package:healthify_server_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Doctor report sharing flow', (sessionBuilder, endpoints) {
    test('upload, release, patient download, and revoke access', () async {
      const hospitalKey = 'hospital-report-sharing-e2e';
      const doctorUser = 'doctor-report-sharing-e2e';
      const doctorId = 'doctor-report-sharing-profile-e2e';
      const patientUser = 'patient-report-sharing-e2e';
      const requestId = 'patient-request-report-sharing-e2e';
      const reportId = 'report-sharing-e2e';
      final now = DateTime.now().toUtc();
      final doctorSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(doctorUser, const {}),
      );
      final patientSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(patientUser, const {}),
      );

      final setupSession = doctorSession.build();
      await HospitalMembershipRecord.db.insertRow(
        setupSession,
        HospitalMembershipRecord(
          hospitalKey: hospitalKey,
          userIdentifier: doctorUser,
          role: 'doctor',
          isActive: true,
        ),
      );
      await HospitalUserAccessRecord.db.insertRow(
        setupSession,
        HospitalUserAccessRecord(
          hospitalKey: hospitalKey,
          userKey: doctorUser,
          userName: 'E2E Doctor',
          email: 'e2e-doctor@example.test',
          role: 'doctor',
          department: 'Radiology',
          isActive: true,
          lastActive: now,
        ),
      );
      await HospitalOperationalRecord.db.insertRow(
        setupSession,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'doctors',
          recordKey: doctorId,
          payload: jsonEncode({
            'id': doctorId,
            'name': 'E2E Doctor',
            'email': 'e2e-doctor@example.test',
          }),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await HospitalOperationalRecord.db.insertRow(
        setupSession,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'appointments',
          recordKey: 'appointment-report-sharing-e2e',
          payload: jsonEncode({
            'id': 'appointment-report-sharing-e2e',
            'doctorId': doctorId,
            'patientId': patientUser,
            'patientOwner': patientUser,
            'patientRequestId': requestId,
          }),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await HospitalOperationalRecord.db.insertRow(
        setupSession,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'patientAccountLinks',
          recordKey: patientUser,
          payload: jsonEncode({
            'patientId': patientUser,
            'patientOwner': patientUser,
            'status': 'active',
            'linkedAt': now.toIso8601String(),
          }),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await HospitalOperationalRecord.db.insertRow(
        setupSession,
        HospitalOperationalRecord(
          hospitalKey: 'PATIENT:$patientUser',
          collection: 'patientAppointments',
          recordKey: requestId,
          payload: jsonEncode({
            'id': requestId,
            '_owner': patientUser,
            'hospitalId': hospitalKey,
          }),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await HospitalOperationalRecord.db.insertRow(
        setupSession,
        HospitalOperationalRecord(
          hospitalKey: hospitalKey,
          collection: 'diagnosticReports',
          recordKey: reportId,
          payload: jsonEncode({
            'id': reportId,
            'patientId': patientUser,
            'patientName': 'E2E Patient',
            'doctorId': doctorId,
            'orderingDoctorId': doctorId,
            'title': 'E2E report sharing check',
            'reportType': 'radiology',
            'verificationStatus': 'verified',
            'status': 'verified',
            'uploadedAt': now.toIso8601String(),
            'impressionText': 'E2E clinical impression',
            'releasedToPatient': false,
          }),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final pdfBytes = Uint8List.fromList('%PDF-1.4\nE2E report\n'.codeUnits);
      final uploadedReference = await endpoints.hospital.uploadDoctorReportFile(
        doctorSession,
        hospitalKey,
        reportId,
        'e2e-report.pdf',
        'application/pdf',
        ByteData.sublistView(pdfBytes),
      );
      final reference = jsonDecode(uploadedReference) as Map<String, dynamic>;
      expect(reference['fileName'], 'e2e-report.pdf');
      expect(reference['storagePath'], isNot(contains('PATIENT:')));

      await endpoints.hospital.setDoctorReportPatientSharing(
        doctorSession, hospitalKey, reportId, true,
      );
      final portalRows = await endpoints.hospital.listMyPatientRecords(
        patientSession, 'patientReports', limit: 100, offset: 0,
      );
      expect(portalRows, hasLength(1));
      final patientReport = jsonDecode(portalRows.single.payload) as Map<String, dynamic>;
      expect(patientReport['id'], reportId);
      expect(patientReport['hasAttachedFile'], isTrue);
      expect(patientReport.containsKey('fileReference'), isFalse);

      final downloaded = await endpoints.hospital.getMySharedReportFileBytes(
        patientSession, reportId,
      );
      expect(
        downloaded.buffer.asUint8List(downloaded.offsetInBytes, downloaded.lengthInBytes),
        orderedEquals(pdfBytes),
      );

      await endpoints.hospital.setDoctorReportPatientSharing(
        doctorSession, hospitalKey, reportId, false,
      );
      expect(
        await endpoints.hospital.listMyPatientRecords(
          patientSession, 'patientReports', limit: 100, offset: 0,
        ),
        isEmpty,
      );
      await expectLater(
        endpoints.hospital.getMySharedReportFileBytes(patientSession, reportId),
        throwsException,
      );
    });
  });
}
