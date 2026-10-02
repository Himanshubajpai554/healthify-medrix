import '../../enums/domain_enums.dart';
import '../../models/patient_model.dart';
import '../repositories/admission_repository.dart';

class MockAdmissionRepository implements AdmissionRepository {
  final List<Admission> _admissions = [
    Admission(
      id: 'ADM-2001',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1002',
      hospitalPatientLinkId: 'HPL-101',
      bedId: 'BED-101',
      ward: 'ICU Main',
      attendingDoctorId: 'DOC-1001',
      doctorName: 'Dr. Sarah Jenkins',
      departmentId: 'DEP-101',
      admissionDate: DateTime.now().subtract(const Duration(days: 2)),
      admissionType: 'Emergency',
      admissionStatus: AdmissionStatus.admitted,
      reason: 'Severe Dyspnea & Acute Coronary Syndrome',
      diagnosis: 'Acute Myocardial Infarction',
      vitals: {'BP': '140/90', 'Heart Rate': '98 bpm', 'SpO2': '93%'},
      clinicalNotes: 'Patient placed under ICU cardiac monitoring. Responding well to intravenous antiarrhythmic protocol.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    Admission(
      id: 'ADM-2002',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1005',
      hospitalPatientLinkId: 'HPL-102',
      bedId: 'BED-201',
      ward: 'General Ward A',
      attendingDoctorId: 'DOC-1004',
      doctorName: 'Dr. Michael Chen',
      departmentId: 'DEP-102',
      admissionDate: DateTime.now().subtract(const Duration(days: 1)),
      admissionType: 'Scheduled',
      admissionStatus: AdmissionStatus.admitted,
      reason: 'Post-operative Observation',
      diagnosis: 'Laparoscopic Cholecystectomy',
      vitals: {'BP': '120/80', 'Heart Rate': '72 bpm', 'SpO2': '98%'},
      clinicalNotes: 'Post-op Day 1. Surgical site clean and dry. Ambulating with assistance.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    Admission(
      id: 'ADM-1980',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1002',
      hospitalPatientLinkId: 'HPL-101',
      bedId: 'BED-105',
      ward: 'General Ward B',
      attendingDoctorId: 'DOC-1001',
      doctorName: 'Dr. Sarah Jenkins',
      departmentId: 'DEP-101',
      admissionDate: DateTime.now().subtract(const Duration(days: 180)),
      dischargeDate: DateTime.now().subtract(const Duration(days: 175)),
      admissionType: 'Scheduled',
      admissionStatus: AdmissionStatus.discharged,
      reason: 'Elective Coronary Angiography',
      diagnosis: 'Stable Angina Pectoris',
      vitals: {'BP': '125/82', 'Heart Rate': '70 bpm', 'SpO2': '99%'},
      clinicalNotes: 'Procedure completed without complications. Discharged with antiplatelet therapy.',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 175)),
    ),
  ];

  @override
  Future<List<Admission>> getAdmissions({String? patientId, String? bedId, String? hospitalId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _admissions.where((a) {
      if (patientId != null && a.patientId != patientId) return false;
      if (bedId != null && a.bedId != bedId) return false;
      if (hospitalId != null && a.hospitalId != hospitalId) return false;
      return true;
    }).toList();
  }

  @override
  Future<Admission?> getAdmissionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _admissions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Admission?> getActiveAdmissionForPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _admissions.firstWhere((a) => a.patientId == patientId && a.admissionStatus != AdmissionStatus.discharged);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Admission>> getAdmissionHistory(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _admissions.where((a) => a.patientId == patientId).toList();
  }

  @override
  Future<Admission> createAdmission(Admission admission) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _admissions.insert(0, admission);
    return admission;
  }

  @override
  Future<void> updateAdmission(Admission admission) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _admissions.indexWhere((a) => a.id == admission.id);
    if (index != -1) {
      _admissions[index] = admission;
    }
  }

  @override
  Future<void> dischargeAdmission(String admissionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _admissions.indexWhere((a) => a.id == admissionId);
    if (index != -1) {
      final old = _admissions[index];
      _admissions[index] = Admission(
        id: old.id,
        hospitalId: old.hospitalId,
        patientId: old.patientId,
        hospitalPatientLinkId: old.hospitalPatientLinkId,
        bedId: old.bedId,
        ward: old.ward,
        attendingDoctorId: old.attendingDoctorId,
        doctorName: old.doctorName,
        departmentId: old.departmentId,
        admissionDate: old.admissionDate,
        dischargeDate: DateTime.now(),
        admissionType: old.admissionType,
        admissionStatus: AdmissionStatus.discharged,
        reason: old.reason,
        diagnosis: old.diagnosis,
        vitals: old.vitals,
        clinicalNotes: old.clinicalNotes,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
