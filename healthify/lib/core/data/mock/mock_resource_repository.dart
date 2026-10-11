import '../repositories/resource_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/resource_model.dart';
import '../../queries/domain_queries.dart';

class MockResourceRepository implements ResourceRepository {
  static MockResourceRepository Function()? serverpodFactory;
  factory MockResourceRepository() => serverpodFactory?.call() ?? MockResourceRepository.fallback();
  MockResourceRepository.fallback();

  final List<ResourceMatrixItem> _matrixItems = const [
    ResourceMatrixItem(
      resourceType: HospitalResourceType.bed,
      resourceName: 'General Ward Beds',
      total: 400,
      available: 63,
      occupied: 322,
      reserved: 10,
      maintenance: 5,
      utilizationPercentage: 84.5,
      status: ResourceAvailabilityStatus.partiallyAvailable,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.icuBed,
      resourceName: 'ICU Critical Beds',
      total: 32,
      available: 4,
      occupied: 26,
      reserved: 2,
      maintenance: 0,
      utilizationPercentage: 87.5,
      status: ResourceAvailabilityStatus.critical,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.doctor,
      resourceName: 'Attending Physicians',
      total: 45,
      available: 18,
      occupied: 22,
      reserved: 2,
      maintenance: 3,
      utilizationPercentage: 53.3,
      status: ResourceAvailabilityStatus.available,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.nurse,
      resourceName: 'Shift Nursing Staff',
      total: 120,
      available: 35,
      occupied: 80,
      reserved: 0,
      maintenance: 5,
      utilizationPercentage: 66.7,
      status: ResourceAvailabilityStatus.available,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.blood,
      resourceName: 'Blood Units (Total Bank)',
      total: 320,
      available: 285,
      occupied: 35,
      reserved: 20,
      maintenance: 0,
      utilizationPercentage: 10.9,
      status: ResourceAvailabilityStatus.available,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.operatingTheatre,
      resourceName: 'Operating Theatres (OT)',
      total: 8,
      available: 2,
      occupied: 5,
      reserved: 1,
      maintenance: 0,
      utilizationPercentage: 75.0,
      status: ResourceAvailabilityStatus.partiallyAvailable,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.ventilator,
      resourceName: 'Mechanical Ventilators',
      total: 25,
      available: 3,
      occupied: 20,
      reserved: 1,
      maintenance: 1,
      utilizationPercentage: 84.0,
      status: ResourceAvailabilityStatus.critical,
    ),
    ResourceMatrixItem(
      resourceType: HospitalResourceType.equipment,
      resourceName: 'Diagnostic & Imaging Equipment',
      total: 150,
      available: 135,
      occupied: 10,
      reserved: 2,
      maintenance: 3,
      utilizationPercentage: 8.0,
      status: ResourceAvailabilityStatus.available,
    ),
  ];

  final List<ResourceAllocationRequest> _requests = [
    ResourceAllocationRequest(
      id: 'REQ-2026-101',
      hospitalId: 'HOSP-01',
      resourceType: HospitalResourceType.ventilator,
      requestedBy: 'Dr. Sarah Connor (Emergency)',
      departmentId: 'DEP-EMERG-01',
      quantity: 2,
      priority: AllocationPriority.urgent,
      reason: 'Acute respiratory distress influx from trauma arrival.',
      status: AllocationRequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ResourceAllocationRequest(
      id: 'REQ-2026-102',
      hospitalId: 'HOSP-01',
      resourceType: HospitalResourceType.icuBed,
      requestedBy: 'Dr. Marcus Vance (Cardiology)',
      departmentId: 'DEP-CARD-01',
      quantity: 1,
      priority: AllocationPriority.high,
      reason: 'Post-coronary angioplasty recovery monitoring.',
      status: AllocationRequestStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      resolvedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  final List<ResourceAllocationRecommendation> _recommendations = [
    ResourceAllocationRecommendation(
      id: 'REC-2026-001',
      hospitalId: 'HOSP-01',
      resourceType: HospitalResourceType.icuBed,
      currentStatus: 'ICU occupancy at 87.5% (4 beds remaining)',
      recommendedAction: 'Re-assign 2 Step-Down Cardiac Recovery Beds to Overflow ICU Status.',
      reason: 'Sustained high trauma demand over past 12 hours.',
      impact: 'Reduces ICU bottleneck probability by 34%.',
      confidence: 0.89,
      generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: RecommendationStatus.newAction,
    ),
    ResourceAllocationRecommendation(
      id: 'REC-2026-002',
      hospitalId: 'HOSP-01',
      resourceType: HospitalResourceType.nurse,
      currentStatus: 'ER Night Shift Nurse-to-Patient ratio at 1:6',
      recommendedAction: 'Request On-Call Shift Float Nurse for ER Triage Support.',
      reason: 'Weekend evening surge projection exceeds average by 22%.',
      impact: 'Decreases ER triage wait time by an estimated 8 minutes.',
      confidence: 0.92,
      generatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: RecommendationStatus.newAction,
    ),
  ];

  @override
  Future<List<ResourceMatrixItem>> getResourceMatrix({ResourceQuery query = const ResourceQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<ResourceMatrixItem>.from(_matrixItems);
    if (query.resourceType != null) {
      results = results.where((r) => r.resourceType == query.resourceType).toList();
    }
    if (query.status != null) {
      results = results.where((r) => r.status == query.status).toList();
    }
    return results;
  }

  @override
  Future<List<ResourceSnapshot>> getResourceSnapshots({ResourceQuery query = const ResourceQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return _matrixItems.map((m) => ResourceSnapshot(
      id: 'SNAP-${m.resourceType.name}',
      hospitalId: 'HOSP-01',
      resourceType: m.resourceType,
      resourceId: 'RES-${m.resourceType.name.toUpperCase()}',
      departmentId: 'DEP-GEN-01',
      totalCapacity: m.total,
      availableCapacity: m.available,
      reservedCapacity: m.reserved,
      occupiedCapacity: m.occupied,
      maintenanceCapacity: m.maintenance,
      status: m.status,
      capturedAt: now,
    )).toList();
  }

  @override
  Future<List<DepartmentCapacitySummary>> getDepartmentCapacitySummaries() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      DepartmentCapacitySummary(
        departmentId: 'DEP-CARD-01',
        departmentName: 'Cardiology & Cardiac Surgery',
        totalBeds: 60,
        availableBeds: 8,
        occupiedBeds: 50,
        doctorCount: 8,
        availableDoctors: 3,
        staffCount: 20,
        availableStaff: 6,
        activeAppointments: 24,
        waitingAppointments: 5,
        emergencyCases: 3,
        utilization: 83.3,
        capturedAt: now,
      ),
      DepartmentCapacitySummary(
        departmentId: 'DEP-NEURO-01',
        departmentName: 'Neurology & Neurosurgery',
        totalBeds: 45,
        availableBeds: 6,
        occupiedBeds: 37,
        doctorCount: 6,
        availableDoctors: 2,
        staffCount: 16,
        availableStaff: 4,
        activeAppointments: 18,
        waitingAppointments: 3,
        emergencyCases: 2,
        utilization: 82.2,
        capturedAt: now,
      ),
      DepartmentCapacitySummary(
        departmentId: 'DEP-ORTHO-01',
        departmentName: 'Orthopedics & Trauma Surgery',
        totalBeds: 50,
        availableBeds: 12,
        occupiedBeds: 35,
        doctorCount: 7,
        availableDoctors: 4,
        staffCount: 18,
        availableStaff: 7,
        activeAppointments: 30,
        waitingAppointments: 8,
        emergencyCases: 5,
        utilization: 70.0,
        capturedAt: now,
      ),
      DepartmentCapacitySummary(
        departmentId: 'DEP-PED-01',
        departmentName: 'Pediatrics & Neonatology',
        totalBeds: 40,
        availableBeds: 15,
        occupiedBeds: 23,
        doctorCount: 5,
        availableDoctors: 3,
        staffCount: 14,
        availableStaff: 5,
        activeAppointments: 22,
        waitingAppointments: 2,
        emergencyCases: 1,
        utilization: 57.5,
        capturedAt: now,
      ),
    ];
  }

  @override
  Future<List<ResourceAllocationRequest>> getAllocationRequests({AllocationRequestQuery query = const AllocationRequestQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<ResourceAllocationRequest>.from(_requests);
    if (query.status != null) {
      results = results.where((r) => r.status == query.status).toList();
    }
    if (query.priority != null) {
      results = results.where((r) => r.priority == query.priority).toList();
    }
    return results;
  }

  @override
  Future<ResourceAllocationRequest> createAllocationRequest(ResourceAllocationRequest request) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _requests.insert(0, request);
    return request;
  }

  @override
  Future<ResourceAllocationRequest> updateAllocationRequestStatus(String requestId, AllocationRequestStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final old = _requests[index];
    final updated = old.copyWith(
      status: status,
      resolvedAt: DateTime.now(),
    );
    _requests[index] = updated;
    return updated;
  }

  @override
  Future<List<ResourceAllocationRecommendation>> getRecommendations({RecommendationQuery query = const RecommendationQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<ResourceAllocationRecommendation>.from(_recommendations);
    if (query.status != null) {
      results = results.where((r) => r.status == query.status).toList();
    }
    return results;
  }

  @override
  Future<ResourceAllocationRecommendation> reviewRecommendation(String recommendationId, RecommendationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _recommendations.indexWhere((r) => r.id == recommendationId);
    if (index == -1) throw Exception('Recommendation not found');
    final old = _recommendations[index];
    final updated = old.copyWith(status: status);
    _recommendations[index] = updated;
    return updated;
  }
}
