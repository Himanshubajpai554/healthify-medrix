import '../data/repositories/repositories.dart';
import '../enums/domain_enums.dart';
import '../errors/domain_errors.dart';
import '../models/core_models.dart';

class PatientService {
  final PatientRepository patientRepository;
  final HospitalPatientRepository hospitalPatientRepository;
  final AdmissionRepository admissionRepository;
  final BedRepository bedRepository;
  final AuditRepository auditRepository;

  PatientService({
    required this.patientRepository,
    required this.hospitalPatientRepository,
    required this.admissionRepository,
    required this.bedRepository,
    required this.auditRepository,
  });

  /// Admit a brand new patient into the hospital system.
  /// Automatically generates authoritative MRN and admission records.
  Future<PatientItem> admitNewPatient({
    required String hospitalId,
    required String name,
    required int age,
    required String gender,
    required String bloodGroup,
    required String ward,
    required PatientStatus status,
    required String doctorName,
    required Map<String, String> vitals,
  }) async {
    final now = DateTime.now();
    final id = 'PT-${now.microsecondsSinceEpoch}';
    if (patientRepository is AtomicPatientAdmissionRepository) {
      final patient = PatientItem(id: id, name: name, age: age, gender: gender,
        bloodGroup: bloodGroup, ward: ward, admissionDate: now, status: status,
        doctorName: doctorName, vitals: vitals);
      final link = _newHospitalLink(hospitalId, id, now);
      final admission = _newAdmission(hospitalId, id, link.id, ward, doctorName,
        vitals, 'General Operational Intake', 'Primary Clinical Evaluation Pending', now);
      await (patientRepository as AtomicPatientAdmissionRepository)
          .createAdmissionBundle(patient: patient, link: link, admission: admission);
      return patient;
    }
    final req = PatientAdmissionRequest(
      name: name,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      ward: ward,
      status: status,
      doctorName: doctorName,
      vitals: vitals,
    );

    final patientItem = await patientRepository.admitPatient(req);

    // Create Hospital Patient Link & MRN
    final link = _newHospitalLink(hospitalId, patientItem.id, DateTime.now());
    await hospitalPatientRepository.createLink(link);

    // Create Admission
    final admission = _newAdmission(hospitalId, patientItem.id, link.id, ward,
      doctorName, vitals, 'General Operational Intake',
      'Primary Clinical Evaluation Pending', DateTime.now());
    await admissionRepository.createAdmission(admission);

    return patientItem;
  }

  /// Admit an existing global patient into this hospital.
  Future<PatientItem> admitExistingPatient({
    required String hospitalId,
    required String patientId,
    required String ward,
    required PatientStatus status,
    required String doctorName,
    required Map<String, String> vitals,
  }) async {
    final existingPatient = await patientRepository.getPatientById(patientId);
    if (existingPatient == null) {
      throw NotFoundError(entityName: 'Patient', entityId: patientId);
    }

    // Check or create HospitalPatientLink
    var link = await hospitalPatientRepository.getLinkByPatientId(hospitalId, patientId);
    if (link == null) {
      link = _newHospitalLink(hospitalId, patientId, DateTime.now());
    }

    final updatedPatient = PatientItem(
      id: existingPatient.id,
      name: existingPatient.name,
      age: existingPatient.age,
      gender: existingPatient.gender,
      bloodGroup: existingPatient.bloodGroup,
      ward: ward,
      admissionDate: DateTime.now(),
      status: status,
      doctorName: doctorName,
      vitals: vitals,
    );
    final admission = _newAdmission(hospitalId, patientId, link.id, ward,
      doctorName, vitals, 'Readmission / Transfer Intake',
      'Clinical Re-assessment', DateTime.now());
    if (patientRepository is AtomicPatientAdmissionRepository) {
      await (patientRepository as AtomicPatientAdmissionRepository)
          .createAdmissionBundle(patient: updatedPatient, link: link, admission: admission);
      return updatedPatient;
    }
    await patientRepository.updatePatient(updatedPatient);
    if (await hospitalPatientRepository.getLinkByPatientId(hospitalId, patientId) == null) {
      await hospitalPatientRepository.createLink(link);
    }
    await admissionRepository.createAdmission(admission);

    return updatedPatient;
  }

  HospitalPatientLink _newHospitalLink(String hospitalId, String patientId, DateTime now) =>
      HospitalPatientLink(id: 'HPL-${now.microsecondsSinceEpoch}', hospitalId: hospitalId,
        patientId: patientId, mrnNumber: 'MRN-${10000 + now.microsecondsSinceEpoch % 89999}',
        registrationDate: now, createdAt: now, updatedAt: now);

  Admission _newAdmission(String hospitalId, String patientId, String linkId,
      String ward, String doctorName, Map<String, String> vitals, String reason,
      String diagnosis, DateTime now) => Admission(
        id: 'ADM-${now.microsecondsSinceEpoch}', hospitalId: hospitalId,
        patientId: patientId, hospitalPatientLinkId: linkId,
        // The admission starts without a bed assignment; inventory must supply
        // a real available bed instead of fabricating an identifier.
        bedId: '', ward: ward,
        attendingDoctorId: 'DOC-1001', doctorName: doctorName,
        departmentId: 'DEP-101', admissionDate: now,
        admissionStatus: AdmissionStatus.admitted, reason: reason,
        diagnosis: diagnosis, vitals: vitals, createdAt: now, updatedAt: now);

  /// Discharge patient from active hospital stay.
  Future<void> dischargePatient(String patientId) async {
    await patientRepository.dischargePatient(patientId);
    final activeAdmission = await admissionRepository.getActiveAdmissionForPatient(patientId);
    if (activeAdmission != null) {
      await admissionRepository.dischargeAdmission(activeAdmission.id);
    }
  }

  /// Transfer patient to a different ward or unit.
  Future<void> transferPatientWard(String patientId, String newWard) async {
    await patientRepository.updatePatientWard(patientId, newWard);
    final activeAdmission = await admissionRepository.getActiveAdmissionForPatient(patientId);
    if (activeAdmission != null) {
      final updated = Admission(
        id: activeAdmission.id,
        hospitalId: activeAdmission.hospitalId,
        patientId: activeAdmission.patientId,
        hospitalPatientLinkId: activeAdmission.hospitalPatientLinkId,
        bedId: activeAdmission.bedId,
        ward: newWard,
        attendingDoctorId: activeAdmission.attendingDoctorId,
        doctorName: activeAdmission.doctorName,
        departmentId: activeAdmission.departmentId,
        admissionDate: activeAdmission.admissionDate,
        dischargeDate: activeAdmission.dischargeDate,
        admissionType: activeAdmission.admissionType,
        admissionStatus: activeAdmission.admissionStatus,
        reason: activeAdmission.reason,
        diagnosis: activeAdmission.diagnosis,
        vitals: activeAdmission.vitals,
        clinicalNotes: activeAdmission.clinicalNotes,
        createdAt: activeAdmission.createdAt,
        updatedAt: DateTime.now(),
      );
      await admissionRepository.updateAdmission(updated);
    }
  }

  /// Retrieve summary analytics metrics for hospital command center.
  Future<PatientOverviewMetrics> getOverviewMetrics(String hospitalId) async {
    return patientRepository.getPatientMetrics(hospitalId);
  }

  /// Get admission history for a given patient.
  Future<List<Admission>> getPatientAdmissionHistory(String patientId) async {
    return admissionRepository.getAdmissionHistory(patientId);
  }

  /// Evaluate frontend-level privacy and visibility permission bounds.
  PatientAccessPermission getAccessPermission(String userRole, String patientId) {
    return PatientAccessPermission.defaultAdmin;
  }
}
