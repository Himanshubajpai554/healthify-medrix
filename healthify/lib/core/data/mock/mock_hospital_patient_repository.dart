import '../../models/patient_model.dart';
import '../repositories/hospital_patient_repository.dart';

class MockHospitalPatientRepository implements HospitalPatientRepository {
  final List<HospitalPatientLink> _links = [
    HospitalPatientLink(
      id: 'HPL-101',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1002',
      mrnNumber: 'MRN-10021',
      linkStatus: 'Active',
      registrationDate: DateTime.now().subtract(const Duration(days: 365)),
      lastVisitAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    HospitalPatientLink(
      id: 'HPL-102',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1005',
      mrnNumber: 'MRN-10022',
      linkStatus: 'Active',
      registrationDate: DateTime.now().subtract(const Duration(days: 180)),
      lastVisitAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    ),
    HospitalPatientLink(
      id: 'HPL-103',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1012',
      mrnNumber: 'MRN-10023',
      linkStatus: 'Active',
      registrationDate: DateTime.now().subtract(const Duration(days: 90)),
      lastVisitAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    HospitalPatientLink(
      id: 'HPL-104',
      hospitalId: 'HOSP-101',
      patientId: 'PT-1018',
      mrnNumber: 'MRN-10024',
      linkStatus: 'Active',
      registrationDate: DateTime.now().subtract(const Duration(days: 40)),
      lastVisitAt: DateTime.now().subtract(const Duration(days: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<HospitalPatientLink>> getHospitalPatientLinks(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _links.where((l) => l.hospitalId == hospitalId).toList();
  }

  @override
  Future<HospitalPatientLink?> getLinkByPatientId(String hospitalId, String patientId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _links.firstWhere((l) => l.hospitalId == hospitalId && l.patientId == patientId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HospitalPatientLink?> getLinkByMrn(String hospitalId, String mrnNumber) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _links.firstWhere((l) => l.hospitalId == hospitalId && l.mrnNumber.toLowerCase() == mrnNumber.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HospitalPatientLink> createLink(HospitalPatientLink link) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _links.add(link);
    return link;
  }

  @override
  Future<void> updateLinkStatus(String linkId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _links.indexWhere((l) => l.id == linkId);
    if (index != -1) {
      final old = _links[index];
      _links[index] = HospitalPatientLink(
        id: old.id,
        hospitalId: old.hospitalId,
        patientId: old.patientId,
        mrnNumber: old.mrnNumber,
        linkStatus: newStatus,
        registrationDate: old.registrationDate,
        lastVisitAt: old.lastVisitAt,
        isPrimary: old.isPrimary,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
