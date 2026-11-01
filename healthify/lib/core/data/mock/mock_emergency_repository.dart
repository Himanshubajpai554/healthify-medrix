import '../repositories/emergency_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/emergency_model.dart';
import '../../models/ai_insight_model.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockEmergencyRepository implements EmergencyRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<EmergencyCaseItem>> getEmergencyCases({EmergencyQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.emergencyCases.toList();

    if (query != null) {
      if (query.searchQuery != null && query.searchQuery!.trim().isNotEmpty) {
        final q = query.searchQuery!.trim().toLowerCase();
        list = list.where((c) =>
            c.patientName.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q) ||
            c.chiefComplaint.toLowerCase().contains(q) ||
            c.assignedDoctor.toLowerCase().contains(q)).toList();
      }

      if (query.status != null) {
        list = list.where((c) => c.status == query.status).toList();
      }

      if (query.doctorId != null && query.doctorId!.isNotEmpty) {
        list = list.where((c) => c.assignedDoctor.contains(query.doctorId!)).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<EmergencyCaseItem?> getEmergencyCaseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matches = _store.emergencyCases.where((c) => c.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<EmergencyCaseItem> registerEmergencyCase(EmergencyCaseItem emergencyCase) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.emergencyCases.insert(0, emergencyCase);
    return emergencyCase;
  }

  @override
  Future<EmergencyCaseItem> createAnonymousEmergencyCase(EmergencyCaseItem anonymousCase) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final item = EmergencyCaseItem(
      id: anonymousCase.id.startsWith('EMG') ? anonymousCase.id : 'EMG-ANO-${DateTime.now().millisecondsSinceEpoch}',
      patientName: 'Anonymous Emergency',
      age: anonymousCase.age,
      gender: anonymousCase.gender,
      chiefComplaint: anonymousCase.chiefComplaint,
      priority: anonymousCase.priority,
      status: EmergencyStatus.triaged,
      assignedDoctor: anonymousCase.assignedDoctor,
      arrivalTime: 'Just now',
      locationBed: anonymousCase.locationBed,
    );
    _store.emergencyCases.insert(0, item);
    return item;
  }

  @override
  Future<void> linkPatient(String caseId, String patientId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.emergencyCases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _store.emergencyCases[index];
      _store.emergencyCases[index] = EmergencyCaseItem(
        id: old.id,
        patientName: 'Patient $patientId',
        age: old.age,
        gender: old.gender,
        chiefComplaint: old.chiefComplaint,
        priority: old.priority,
        status: old.status,
        assignedDoctor: old.assignedDoctor,
        arrivalTime: old.arrivalTime,
        locationBed: old.locationBed,
      );
    }
  }

  @override
  Future<void> assignTriageLevel(String caseId, TriagePriority priority) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.emergencyCases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      _store.emergencyCases[index] = EmergencyCaseItem(
        id: _store.emergencyCases[index].id,
        patientName: _store.emergencyCases[index].patientName,
        age: _store.emergencyCases[index].age,
        gender: _store.emergencyCases[index].gender,
        chiefComplaint: _store.emergencyCases[index].chiefComplaint,
        priority: priority,
        status: EmergencyStatus.triaged,
        assignedDoctor: _store.emergencyCases[index].assignedDoctor,
        arrivalTime: _store.emergencyCases[index].arrivalTime,
        locationBed: _store.emergencyCases[index].locationBed,
      );
    }
  }

  @override
  Future<void> updateEmergencyStatus(String caseId, EmergencyStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.emergencyCases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      _store.emergencyCases[index].status = status;
    }
  }

  @override
  Future<void> assignDoctorToEmergency(String caseId, String doctorName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.emergencyCases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _store.emergencyCases[index];
      _store.emergencyCases[index] = EmergencyCaseItem(
        id: old.id,
        patientName: old.patientName,
        age: old.age,
        gender: old.gender,
        chiefComplaint: old.chiefComplaint,
        priority: old.priority,
        status: EmergencyStatus.assigned,
        assignedDoctor: doctorName,
        arrivalTime: old.arrivalTime,
        locationBed: old.locationBed,
      );
    }
  }

  @override
  Future<void> assignNurse(String caseId, String nurseName) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> assignBay(String caseId, String bayName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.emergencyCases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _store.emergencyCases[index];
      _store.emergencyCases[index] = EmergencyCaseItem(
        id: old.id,
        patientName: old.patientName,
        age: old.age,
        gender: old.gender,
        chiefComplaint: old.chiefComplaint,
        priority: old.priority,
        status: old.status,
        assignedDoctor: old.assignedDoctor,
        arrivalTime: old.arrivalTime,
        locationBed: bayName,
      );
    }
  }

  @override
  Future<EmergencyCapacitySummary> getEmergencyCapacity() async {
    await Future.delayed(const Duration(milliseconds: 100));
    int critical = 0;
    int waiting = 0;
    int inTreatment = 0;

    for (final c in _store.emergencyCases) {
      if (c.priority == TriagePriority.level1Resuscitation || c.priority == TriagePriority.level2Emergent) {
        critical++;
      }
      if (c.status == EmergencyStatus.waiting || c.status == EmergencyStatus.arrived) {
        waiting++;
      }
      if (c.status == EmergencyStatus.inTreatment || c.status == EmergencyStatus.assigned) {
        inTreatment++;
      }
    }

    return EmergencyCapacitySummary(
      totalBays: 24,
      availableBays: 10,
      occupiedBays: 12,
      cleaningBays: 1,
      maintenanceBays: 1,
      criticalCases: critical,
      waitingCases: waiting,
      inTreatmentCases: inTreatment,
    );
  }

  @override
  Future<List<EmergencyHospitalRecommendation>> getHospitalRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      EmergencyHospitalRecommendation(
        hospitalId: 'HOSP-101',
        hospitalName: 'Healthify Central Hospital',
        distanceKm: 2.4,
        emergencyAvailability: 'High',
        availableERCapacity: 10,
        icuAvailability: 6,
        specialistAvailability: true,
        bloodAvailability: true,
        estimatedWaitMinutes: 12,
        recommendationScore: 0.96,
        confidence: 0.94,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Future<void> dischargeEmergencyCase(String caseId) async {
    await updateEmergencyStatus(caseId, EmergencyStatus.discharged);
  }
}
