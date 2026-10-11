import '../../data/mock/mock_resource_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/resource_model.dart';
import '../../queries/domain_queries.dart';
import 'hospital_operational_repository.dart';

class ServerpodResourceRepository extends MockResourceRepository {
  ServerpodResourceRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  DateTime get _now => DateTime.now();
  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) =>
      values.where((v) => v.name == value).firstOrNull ?? fallback;
  int _count(List<Map<String, dynamic>> rows, bool Function(Map<String, dynamic>) test) => rows.where(test).length;
  String _id(Map<String, dynamic> row) => '${row['id'] ?? row['_key'] ?? ''}';

  @override
  Future<List<ResourceMatrixItem>> getResourceMatrix({ResourceQuery query = const ResourceQuery()}) async {
    final beds = await records.list('beds', limit: 500);
    final icu = await records.list('icu', limit: 500);
    final equipment = await records.list('equipment', limit: 500);
    final rows = <ResourceMatrixItem>[];
    void add(HospitalResourceType type, String name, List<Map<String, dynamic>> data) {
      final available = _count(data, (r) => r['status'] == 'available');
      final occupied = _count(data, (r) => r['status'] == 'occupied');
      final reserved = _count(data, (r) => r['status'] == 'reserved');
      final maintenance = _count(data, (r) => {'maintenance', 'cleaning', 'outOfService'}.contains(r['status']));
      final status = available == 0 ? ResourceAvailabilityStatus.unavailable :
          available == data.length ? ResourceAvailabilityStatus.available : ResourceAvailabilityStatus.partiallyAvailable;
      rows.add(ResourceMatrixItem(resourceType: type, resourceName: name, total: data.length,
        available: available, occupied: occupied, reserved: reserved, maintenance: maintenance,
        utilizationPercentage: data.isEmpty ? 0 : occupied * 100 / data.length, status: status));
    }
    add(HospitalResourceType.bed, 'Hospital Beds', beds);
    add(HospitalResourceType.icuBed, 'ICU Beds', icu);
    add(HospitalResourceType.equipment, 'Equipment', equipment);
    return query.resourceType == null ? rows : rows.where((r) => r.resourceType == query.resourceType).toList();
  }

  @override
  Future<List<DepartmentCapacitySummary>> getDepartmentCapacitySummaries() async {
    final depts = await records.list('departments', limit: 500);
    final beds = await records.list('beds', limit: 500);
    final staff = await records.list('staff', limit: 500);
    final appointments = await records.list('appointments', limit: 500);
    final emergencies = await records.list('emergencies', limit: 500);
    return depts.map((d) {
      final id = _id(d);
      final deptBeds = beds.where((r) => r['departmentId'] == id || r['department'] == id).toList();
      final deptStaff = staff.where((r) => r['departmentId'] == id || r['department'] == id).toList();
      final deptAppointments = appointments.where((r) => r['departmentId'] == id || r['department'] == id).toList();
      final occupied = _count(deptBeds, (r) => r['status'] == 'occupied');
      return DepartmentCapacitySummary(departmentId: id, departmentName: '${d['name'] ?? d['departmentName'] ?? id}',
        totalBeds: deptBeds.length, availableBeds: _count(deptBeds, (r) => r['status'] == 'available'),
        occupiedBeds: occupied, doctorCount: _count(deptStaff, (r) => '${r['role']}'.toLowerCase().contains('doctor')),
        availableDoctors: _count(deptStaff, (r) => '${r['role']}'.toLowerCase().contains('doctor') && r['status'] == 'active'),
        staffCount: deptStaff.length, availableStaff: _count(deptStaff, (r) => r['status'] == 'active'),
        activeAppointments: _count(deptAppointments, (r) => r['status'] != 'completed' && r['status'] != 'cancelled'),
        waitingAppointments: _count(deptAppointments, (r) => r['status'] == 'scheduled' || r['status'] == 'waiting'),
        emergencyCases: _count(emergencies, (r) => r['departmentId'] == id && r['status'] != 'resolved'),
        utilization: deptBeds.isEmpty ? 0 : occupied * 100 / deptBeds.length, capturedAt: _now);
    }).toList();
  }

  @override
  Future<List<ResourceAllocationRequest>> getAllocationRequests({AllocationRequestQuery query = const AllocationRequestQuery()}) async {
    final rows = await records.list('resourceRequests', limit: 500);
    return rows.map((r) => ResourceAllocationRequest(id: _id(r), hospitalId: records.hospitalKey,
      resourceType: _enum(HospitalResourceType.values, r['resourceType'], HospitalResourceType.other),
      resourceId: r['resourceId'] as String?, requestedBy: '${r['requestedBy'] ?? ''}',
      departmentId: '${r['departmentId'] ?? ''}', quantity: r['quantity'] is num ? (r['quantity'] as num).toInt() : 0,
      priority: _enum(AllocationPriority.values, r['priority'], AllocationPriority.medium),
      reason: '${r['reason'] ?? ''}', status: _enum(AllocationRequestStatus.values, r['status'], AllocationRequestStatus.pending),
      createdAt: DateTime.tryParse('${r['createdAt']}') ?? _now,
      resolvedAt: DateTime.tryParse('${r['resolvedAt']}'))).toList();
  }

  Map<String, dynamic> _requestJson(ResourceAllocationRequest r) => {'id': r.id,
    'resourceType': r.resourceType.name, 'resourceId': r.resourceId, 'requestedBy': r.requestedBy,
    'departmentId': r.departmentId, 'quantity': r.quantity, 'priority': r.priority.name,
    'reason': r.reason, 'status': r.status.name, 'createdAt': r.createdAt.toIso8601String(),
    'resolvedAt': r.resolvedAt?.toIso8601String()};

  @override
  Future<ResourceAllocationRequest> createAllocationRequest(ResourceAllocationRequest request) async {
    await records.save('resourceRequests', request.id, _requestJson(request));
    return request;
  }

  @override
  Future<ResourceAllocationRequest> updateAllocationRequestStatus(String requestId, AllocationRequestStatus status) async {
    final row = await records.get('resourceRequests', requestId) ?? (throw StateError('Allocation request not found.'));
    row['status'] = status.name;
    row['resolvedAt'] = status == AllocationRequestStatus.pending || status == AllocationRequestStatus.underReview ? null : _now.toUtc().toIso8601String();
    await records.save('resourceRequests', requestId, row);
    return (await getAllocationRequests()).firstWhere((r) => r.id == requestId);
  }

  @override
  Future<List<ResourceAllocationRecommendation>> getRecommendations({RecommendationQuery query = const RecommendationQuery()}) async {
    final rows = await records.list('resourceRecommendations', limit: 500);
    return rows.map((r) => ResourceAllocationRecommendation(id: _id(r), hospitalId: records.hospitalKey,
      resourceType: _enum(HospitalResourceType.values, r['resourceType'], HospitalResourceType.other),
      resourceId: r['resourceId'] as String?, currentStatus: '${r['currentStatus'] ?? ''}',
      recommendedAction: '${r['recommendedAction'] ?? ''}', reason: '${r['reason'] ?? ''}',
      impact: '${r['impact'] ?? ''}', confidence: r['confidence'] is num ? (r['confidence'] as num).toDouble() : 0,
      generatedAt: DateTime.tryParse('${r['generatedAt']}') ?? _now,
      status: _enum(RecommendationStatus.values, r['status'], RecommendationStatus.newAction))).toList();
  }

  @override
  Future<ResourceAllocationRecommendation> reviewRecommendation(String recommendationId, RecommendationStatus status) async {
    final row = await records.get('resourceRecommendations', recommendationId) ?? (throw StateError('Recommendation not found.'));
    row['status'] = status.name;
    await records.save('resourceRecommendations', recommendationId, row);
    return (await getRecommendations()).firstWhere((r) => r.id == recommendationId);
  }
}
