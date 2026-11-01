import 'mock_data_store.dart';

class DataIntegrityReport {
  final bool isValid;
  final List<String> issues;
  final DateTime auditedAt;

  const DataIntegrityReport({
    required this.isValid,
    required this.issues,
    required this.auditedAt,
  });
}

/// Development & Test Data Integrity Validator for Healthify Shared Mock Store
class MockDataIntegrityValidator {
  static DataIntegrityReport validate() {
    final store = MockDataStore();
    final List<String> issues = [];

    final hospitalIds = {store.hospitalInfo.id, 'HOSP-101', 'HOSP-102', 'HOSP-103', 'HOSP-104'};
    final doctorIds = store.doctors.map((d) => d.id).toSet();
    final patientIds = store.patients.map((p) => p.id).toSet();

    if (hospitalIds.isEmpty || doctorIds.isEmpty || patientIds.isEmpty) {
      issues.add('Mock store missing primary entity records.');
    }

    // 1. Audit Appointments
    for (final appt in store.appointments) {
      if (appt.patientName.isEmpty) {
        issues.add('Appointment ${appt.id} is missing patient reference.');
      }
      if (appt.doctorName.isEmpty) {
        issues.add('Appointment ${appt.id} is missing doctor reference.');
      }
    }

    // 2. Audit Doctors
    for (final doc in store.doctors) {
      if (doc.name.isEmpty) {
        issues.add('Doctor ${doc.id} has empty name.');
      }
    }

    // 3. Audit Patients
    for (final pat in store.patients) {
      if (pat.name.isEmpty) {
        issues.add('Patient ${pat.id} has empty name.');
      }
    }

    return DataIntegrityReport(
      isValid: issues.isEmpty,
      issues: issues,
      auditedAt: DateTime.now(),
    );
  }
}
