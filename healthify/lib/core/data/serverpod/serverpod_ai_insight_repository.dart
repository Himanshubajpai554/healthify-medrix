import '../../data/mock/mock_ai_insight_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/ai_insight_model.dart';
import '../../queries/domain_queries.dart';
import 'hospital_operational_repository.dart';

/// Connects stored insights and derives live capacity snapshots from current
/// hospital records. It does not claim to run an ML model; model metadata is
/// reported unavailable until a prediction provider is configured.
class ServerpodAIInsightRepository extends MockAIInsightRepository {
  ServerpodAIInsightRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  DateTime get _now => DateTime.now();
  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) => values.where((e) => e.name == value).firstOrNull ?? fallback;
  int _count(List<Map<String, dynamic>> rows, bool Function(Map<String, dynamic>) test) => rows.where(test).length;
  Future<List<Map<String, dynamic>>> _rows(String collection) => records.list(collection, limit: 500);

  AIInsight _insight(Map<String, dynamic> r) => AIInsight(id: '${r['id'] ?? r['_key']}', hospitalId: records.hospitalKey,
    modelType: _enum(AIModelType.values, r['modelType'], AIModelType.hospitalCapacity),
    title: '${r['title'] ?? ''}', summary: '${r['summary'] ?? ''}',
    severity: _enum(AIInsightSeverity.values, r['severity'], AIInsightSeverity.informational),
    confidence: r['confidence'] is num ? (r['confidence'] as num).toDouble() : 0,
    recommendation: '${r['recommendation'] ?? ''}', generatedAt: DateTime.tryParse('${r['generatedAt']}') ?? _now,
    expiresAt: DateTime.tryParse('${r['expiresAt']}') ?? _now,
    status: _enum(RecommendationStatus.values, r['status'], RecommendationStatus.newAction));

  @override
  Future<List<AIInsight>> getInsights({AIQuery query = const AIQuery()}) async {
    var rows = await _rows('insights');
    if (query.modelType != null) rows = rows.where((r) => r['modelType'] == query.modelType!.name).toList();
    if (query.status != null) rows = rows.where((r) => r['status'] == query.status!.name).toList();
    if (query.severity != null) rows = rows.where((r) => r['severity'] == query.severity!.name).toList();
    return rows.map(_insight).toList();
  }

  @override
  Future<AIInsight?> getInsightById(String id) async { final r = await records.get('insights', id); return r == null ? null : _insight(r); }
  @override
  Future<AIInsight> reviewInsight(String id, RecommendationStatus status) async {
    final row = await records.get('insights', id) ?? (throw StateError('Insight not found.'));
    row['status'] = status.name; await records.save('insights', id, row); return _insight(row);
  }
  @override
  Future<AIInsight> acceptInsight(String id) => reviewInsight(id, RecommendationStatus.accepted);
  @override
  Future<AIInsight> rejectInsight(String id) => reviewInsight(id, RecommendationStatus.rejected);

  @override
  Future<List<DoctorWorkloadForecast>> getDoctorAvailabilityForecast({String? departmentId}) async {
    final doctors = await _rows('doctors'); final appointments = await _rows('appointments');
    return doctors.where((d) => departmentId == null || d['departmentId'] == departmentId).map((d) {
      final id = '${d['id'] ?? d['_key']}';
      final count = _count(appointments, (a) => a['doctorId'] == id && a['status'] != 'completed' && a['status'] != 'cancelled');
      return DoctorWorkloadForecast(doctorId: id, doctorName: '${d['name'] ?? d['fullName'] ?? id}',
        departmentId: '${d['departmentId'] ?? ''}', forecastDate: _now,
        expectedAppointments: count, expectedEmergencyLoad: 0,
        expectedWorkload: count > 20 ? 'Heavy' : count > 8 ? 'Normal' : 'Light', confidence: 1);
    }).toList();
  }

  @override
  Future<DoctorWorkloadForecast?> getDoctorWorkloadForecast(String id) async =>
      (await getDoctorAvailabilityForecast()).where((f) => f.doctorId == id).firstOrNull;

  @override
  Future<List<BloodDemandForecast>> getBloodDemandForecast({String? bloodGroup}) async {
    final units = await _rows('bloodInventory'); final requests = await _rows('bloodRequests');
    final groups = <String>{for (final u in units) '${u['bloodGroup'] ?? ''}', for (final r in requests) '${r['bloodGroup'] ?? ''}'};
    return groups.where((g) => bloodGroup == null || g == bloodGroup).map((group) {
      final inventory = _count(units, (r) => r['bloodGroup'] == group && r['status'] == 'available');
      final demand = requests.where((r) => r['bloodGroup'] == group && !{'completed', 'cancelled'}.contains(r['status']))
          .fold<int>(0, (sum, r) => sum + ((r['requiredUnits'] ?? r['unitsRequired']) is num ? ((r['requiredUnits'] ?? r['unitsRequired']) as num).toInt() : 0));
      return BloodDemandForecast(hospitalId: records.hospitalKey, bloodGroup: group, component: 'All components',
        forecastStart: _now, forecastEnd: _now, expectedDemand: demand, currentInventory: inventory,
        projectedInventory: inventory - demand, shortageRisk: inventory < demand ? 'High' : 'Low', confidence: 1, generatedAt: _now);
    }).toList();
  }

  @override
  Future<BedOccupancyForecast> getBedOccupancyForecast({String? wardId}) async {
    final beds = await _rows('beds'); final scoped = wardId == null ? beds : beds.where((b) => b['ward'] == wardId).toList();
    final occupied = _count(scoped, (b) => b['status'] == 'occupied');
    return BedOccupancyForecast(hospitalId: records.hospitalKey, wardId: wardId,
      forecastStart: _now, forecastEnd: _now, currentOccupancy: occupied, predictedOccupancy: occupied,
      predictedAvailableBeds: _count(scoped, (b) => b['status'] == 'available'), confidence: 1, generatedAt: _now);
  }

  @override
  Future<ICUCapacityForecast> getICUCapacityForecast({String? icuUnitId}) async {
    final rows = await _rows('icu'); final occupied = _count(rows, (r) => r['status'] == 'occupied');
    return ICUCapacityForecast(hospitalId: records.hospitalKey, icuUnitId: icuUnitId,
      forecastStart: _now, forecastEnd: _now, currentOccupancy: occupied, predictedOccupancy: occupied,
      predictedAvailableBeds: _count(rows, (r) => r['status'] == 'available'), confidence: 1, generatedAt: _now);
  }

  @override
  Future<HospitalCapacityForecast> getHospitalCapacityForecast() async {
    final beds = await _rows('beds'); final icu = await _rows('icu'); final doctors = await _rows('doctors'); final staff = await _rows('staff');
    final occupied = _count(beds, (r) => r['status'] == 'occupied'); final icuOccupied = _count(icu, (r) => r['status'] == 'occupied');
    final pressure = beds.isEmpty || occupied < beds.length * .7 ? CapacityPressureLevel.normal :
      occupied < beds.length * .85 ? CapacityPressureLevel.watch : occupied < beds.length * .95 ? CapacityPressureLevel.high : CapacityPressureLevel.critical;
    return HospitalCapacityForecast(hospitalId: records.hospitalKey, forecastStart: _now, forecastEnd: _now,
      bedCapacity: beds.length, predictedBedOccupancy: occupied, icuCapacity: icu.length, predictedICUOccupancy: icuOccupied,
      doctorCapacity: doctors.length, predictedDoctorLoad: doctors.length, staffCapacity: staff.length,
      predictedStaffLoad: _count(staff, (r) => r['status'] == 'active'), overallCapacityPressure: pressure, confidence: 1, generatedAt: _now);
  }

  @override
  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations({String? hospitalId}) async => const [];

  @override
  Future<List<QueueForecast>> getQueueForecast({String? departmentId}) async {
    final rows = await _rows('appointments'); final depts = await _rows('departments');
    return depts.where((d) => departmentId == null || (d['id'] ?? d['_key']) == departmentId).map((d) {
      final id = '${d['id'] ?? d['_key']}';
      final queue = _count(rows, (r) => (r['departmentId'] ?? r['department']) == id && {'scheduled', 'waiting', 'checkedIn'}.contains(r['status']));
      return QueueForecast(departmentId: id, departmentName: '${d['name'] ?? id}', forecastStart: _now,
        forecastEnd: _now, currentQueue: queue, predictedQueue: queue, predictedWaitMinutes: 0, confidence: 1, generatedAt: _now);
    }).toList();
  }

  @override
  Future<List<AIModelMetadata>> getModelMetadata() async => AIModelType.values.map((type) => AIModelMetadata(
    modelId: type.name, modelType: type, modelName: type.name, version: 'not-configured', status: AIModelStatus.unavailable,
    lastUpdated: _now, trainingDataRange: 'No model configured', predictionHorizon: 'Snapshot only', lastPredictionAt: _now)).toList();

  @override
  Future<WhatIfSimulationResult> getWhatIfSimulation(String name, Map<String, dynamic> params) async {
    final icu = await getICUCapacityForecast(); final added = (params['addedICUBeds'] as num?)?.toInt() ?? 0;
    final total = icu.currentOccupancy + icu.predictedAvailableBeds + added;
    final rate = total == 0 ? 0 : icu.currentOccupancy * 100 / total;
    return WhatIfSimulationResult(scenarioName: name, resourceType: HospitalResourceType.icuBed,
      currentMetric: '${icu.currentOccupancy} occupied, ${icu.predictedAvailableBeds} available',
      simulatedMetric: '${icu.currentOccupancy} occupied, ${icu.predictedAvailableBeds + added} available',
      projectedChange: 'Snapshot occupancy ${rate.toStringAsFixed(1)}% after adding $added beds', confidence: 1);
  }
}
