import '../repositories/patient_repository.dart';
import '../../models/patient_model.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockPatientRepository implements PatientRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<PatientItem>> getPatients({PatientQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.patients.toList();

    if (query != null) {
      if (query.searchQuery != null && query.searchQuery!.trim().isNotEmpty) {
        final q = query.searchQuery!.trim().toLowerCase();
        list = list.where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q) ||
            p.ward.toLowerCase().contains(q) ||
            p.doctorName.toLowerCase().contains(q)).toList();
      }

      if (query.statusFilter != null && query.statusFilter != 'All Statuses') {
        final statusName = query.statusFilter!.toLowerCase();
        list = list.where((p) => p.status.name.toLowerCase() == statusName ||
            _getStatusLabel(p.status).toLowerCase() == statusName).toList();
      }

      if (query.bloodGroupFilter != null && query.bloodGroupFilter != 'All Blood Groups') {
        list = list.where((p) => p.bloodGroup.toUpperCase() == query.bloodGroupFilter!.toUpperCase()).toList();
      }

      if (query.admissionDate != null) {
        final d = query.admissionDate!;
        list = list.where((p) =>
            p.admissionDate.year == d.year &&
            p.admissionDate.month == d.month &&
            p.admissionDate.day == d.day).toList();
      }
    }

    return List.unmodifiable(list);
  }

  String _getStatusLabel(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return 'admitted';
      case PatientStatus.icu:
        return 'icu';
      case PatientStatus.observation:
        return 'observation';
      case PatientStatus.discharged:
        return 'discharged';
      default:
        return status.name;
    }
  }

  @override
  Future<PatientItem?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _store.patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Patient>> getGlobalPatients() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _store.patients.map((p) {
      return Patient(
        id: p.id,
        name: p.name,
        age: p.age,
        gender: p.gender,
        bloodGroup: p.bloodGroup,
        phone: '+1 (555) ${100 + p.age}-9901',
        email: '${p.name.toLowerCase().replaceAll(' ', '.')}@example.com',
        address: '123 Medical Center Way, Suite 400',
        emergencyContact: '+1 (555) 911-0000 (Spouse)',
        createdAt: p.admissionDate.subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<Patient?> findPatientByMrnOrPhone(String queryStr) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final q = queryStr.trim().toLowerCase();
    final matches = await getGlobalPatients();
    try {
      return matches.firstWhere((p) =>
          p.id.toLowerCase() == q ||
          p.name.toLowerCase().contains(q) ||
          p.phone.contains(q));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PatientItem> admitPatient(PatientAdmissionRequest request) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newId = request.existingPatientId ?? 'PT-${1000 + _store.patients.length + 10}';
    final newPatient = PatientItem(
      id: newId,
      name: request.name,
      age: request.age,
      gender: request.gender,
      bloodGroup: request.bloodGroup,
      ward: request.ward,
      admissionDate: DateTime.now(),
      status: request.status,
      doctorName: request.doctorName,
      vitals: request.vitals,
    );
    _store.patients.insert(0, newPatient);
    return newPatient;
  }

  @override
  Future<void> updatePatient(PatientItem patient) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _store.patients[index] = patient;
    }
  }

  @override
  Future<void> updatePatientStatus(String patientId, PatientStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final patient = await getPatientById(patientId);
    if (patient != null) {
      patient.status = newStatus;
    }
  }

  @override
  Future<void> updatePatientWard(String patientId, String newWard) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final patient = await getPatientById(patientId);
    if (patient != null) {
      patient.ward = newWard;
    }
  }

  @override
  Future<void> dischargePatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final patient = await getPatientById(patientId);
    if (patient != null) {
      patient.status = PatientStatus.discharged;
    }
  }

  @override
  Future<PatientOverviewMetrics> getPatientMetrics(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final activeCount = _store.patients.where((p) => p.status != PatientStatus.discharged).length;
    final icuCount = _store.patients.where((p) => p.status == PatientStatus.icu).length;
    final obsCount = _store.patients.where((p) => p.status == PatientStatus.observation).length;
    final today = DateTime.now();
    final admittedToday = _store.patients.where((p) =>
        p.admissionDate.year == today.year &&
        p.admissionDate.month == today.month &&
        p.admissionDate.day == today.day).length;

    return PatientOverviewMetrics(
      totalActiveAdmissions: activeCount > 0 ? activeCount : 342,
      icuPatients: icuCount > 0 ? icuCount : 28,
      admissionsToday: admittedToday > 0 ? admittedToday : 15,
      dischargesToday: 8,
      observationPatients: obsCount > 0 ? obsCount : 12,
    );
  }
}
