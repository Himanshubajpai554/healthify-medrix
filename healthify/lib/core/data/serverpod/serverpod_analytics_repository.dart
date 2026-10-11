import '../../data/mock/mock_analytics_repository.dart';
import '../../models/analytics_model.dart';
import '../../queries/domain_queries.dart';
import 'hospital_operational_repository.dart';

/// Read-only hospital analytics derived from the tenant's operational rows.
/// Empty collections produce zero-valued metrics rather than seeded demo data.
class ServerpodAnalyticsRepository extends MockAnalyticsRepository {
  ServerpodAnalyticsRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;

  Future<List<Map<String, dynamic>>> _rows(String collection) => records.list(collection, limit: 500);
  int _count(List<Map<String, dynamic>> rows, bool Function(Map<String, dynamic>) test) => rows.where(test).length;
  double _rate(int numerator, int denominator) => denominator == 0 ? 0 : numerator * 100 / denominator;
  DateTime get _now => DateTime.now();

  @override
  Future<HospitalOverviewMetrics> getOverviewMetrics() async {
    final admissions = await _rows('admissions');
    final beds = await _rows('beds');
    final icu = await _rows('icu');
    final emergencies = await _rows('emergencies');
    final staff = await _rows('staff');
    final blood = await _rows('bloodInventory');
    final appointments = await _rows('appointments');
    final reports = await _rows('diagnosticReports');
    final occupied = _count(beds, (r) => r['status'] == 'occupied');
    return HospitalOverviewMetrics(
      totalAdmittedPatients: _count(admissions, (r) => r['admissionStatus'] == 'admitted'),
      icuOccupancyCount: _count(icu, (r) => r['status'] == 'occupied'),
      emergencyActiveCases: _count(emergencies, (r) => !{'resolved', 'closed', 'discharged'}.contains(r['status'])),
      availableDoctorsCount: _count(staff, (r) => r['role']?.toString().toLowerCase().contains('doctor') == true && r['status'] == 'active'),
      bedOccupancyPercentage: _rate(occupied, beds.length),
      bloodStockAdequacyPercentage: _rate(_count(blood, (r) => r['status'] == 'available'), blood.length),
      dailyOutpatientVolume: _count(appointments, (r) => _sameDay(r['dateTime'] ?? r['appointmentDateTime'], _now)),
      pendingLabReports: _count(reports, (r) => {'pending', 'inProgress'}.contains(r['status'])),
    );
  }

  @override
  Future<List<BedOccupancyMetric>> getBedOccupancy({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final beds = await _rows('beds');
    final occupied = _count(beds, (r) => r['status'] == 'occupied');
    final reserved = _count(beds, (r) => r['status'] == 'reserved');
    final maintenance = _count(beds, (r) => {'maintenance', 'cleaning'}.contains(r['status']));
    return [BedOccupancyMetric(date: _now, totalCapacity: beds.length, occupied: occupied,
      available: _count(beds, (r) => r['status'] == 'available'), reserved: reserved,
      maintenance: maintenance, occupancyRate: _rate(occupied, beds.length))];
  }

  @override
  Future<List<ICUUtilizationMetric>> getICUUtilization({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('icu');
    final occupied = _count(rows, (r) => r['status'] == 'occupied');
    return [ICUUtilizationMetric(date: _now, capacity: rows.length, occupied: occupied,
      available: _count(rows, (r) => r['status'] == 'available'), utilizationRate: _rate(occupied, rows.length))];
  }

  @override
  Future<List<OPDSlotEfficiencyMetric>> getOPDSlotEfficiency({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('appointments');
    final today = rows.where((r) => _sameDay(r['dateTime'] ?? r['appointmentDateTime'], _now)).toList();
    final complete = _count(today, (r) => r['status'] == 'completed');
    final cancelled = _count(today, (r) => r['status'] == 'cancelled');
    final noShow = _count(today, (r) => r['status'] == 'noShow');
    return [OPDSlotEfficiencyMetric(date: _now, scheduledSlots: today.length,
      completedSlots: complete, cancelledSlots: cancelled, noShowSlots: noShow,
      utilizationRate: _rate(complete, today.length))];
  }

  @override
  Future<List<AverageLengthOfStayMetric>> getAverageLengthOfStay({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('admissions');
    final completed = rows.where((r) => r['dischargeDate'] != null).toList();
    final stays = completed.map((r) {
      final start = DateTime.tryParse('${r['admissionDate']}');
      final end = DateTime.tryParse('${r['dischargeDate']}');
      return start == null || end == null ? 0.0 : end.difference(start).inHours / 24;
    }).where((d) => d >= 0).toList();
    final average = stays.isEmpty ? 0.0 : stays.reduce((a, b) => a + b) / stays.length;
    return [AverageLengthOfStayMetric(date: _now, averageDays: average,
      admissions: rows.length, discharges: completed.length)];
  }

  @override
  Future<List<EmergencyThroughputMetric>> getEmergencyThroughput({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('emergencies');
    return [EmergencyThroughputMetric(date: _now, emergencyCases: rows.length,
      averageTriageToDoctorMinutes: _averageMinutes(rows, 'triageAt', 'doctorSeenAt'),
      medianTriageToDoctorMinutes: _averageMinutes(rows, 'triageAt', 'doctorSeenAt'),
      criticalCases: _count(rows, (r) => {'critical', 'level1Resuscitation'}.contains(r['priority'] ?? r['triagePriority'])) )];
  }

  @override
  Future<List<BloodStockMetric>> getBloodStockMetrics({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('bloodInventory');
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) { groups.putIfAbsent('${row['bloodGroup'] ?? 'Unknown'}', () => []).add(row); }
    return groups.entries.map((e) {
      final issued = _count(e.value, (r) => r['status'] == 'issued');
      final available = _count(e.value, (r) => r['status'] == 'available');
      return BloodStockMetric(date: _now, bloodGroup: e.key, startingUnits: e.value.length,
        unitsIssued: issued, unitsAdded: 0, endingUnits: available, depletionVelocity: issued.toDouble());
    }).toList();
  }

  @override
  Future<List<EquipmentDowntimeMetric>> getEquipmentDowntime({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('equipment');
    final down = _count(rows, (r) => {'maintenance', 'outOfService', 'offline'}.contains(r['status']));
    return [EquipmentDowntimeMetric(date: _now, equipmentCount: rows.length,
      downtimeHours: 0, availableHours: rows.length * 24.0,
      downtimeRatio: _rate(down, rows.length))];
  }

  @override
  Future<List<NoShowMetric>> getNoShowRate({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final rows = await _rows('appointments');
    final today = rows.where((r) => _sameDay(r['dateTime'] ?? r['appointmentDateTime'], _now)).toList();
    final noShow = _count(today, (r) => r['status'] == 'noShow');
    return [NoShowMetric(date: _now, scheduledAppointments: today.length,
      completedAppointments: _count(today, (r) => r['status'] == 'completed'),
      cancelledAppointments: _count(today, (r) => r['status'] == 'cancelled'),
      noShowAppointments: noShow, noShowRate: _rate(noShow, today.length))];
  }

  @override
  Future<HospitalOperationalKpis> getHospitalKpis({AnalyticsQuery query = const AnalyticsQuery()}) async {
    final bed = (await getBedOccupancy()).first;
    final icu = (await getICUUtilization()).first;
    final opd = (await getOPDSlotEfficiency()).first;
    final stay = (await getAverageLengthOfStay()).first;
    final emergency = (await getEmergencyThroughput()).first;
    final blood = await getBloodStockMetrics();
    final equipment = (await getEquipmentDowntime()).first;
    final noShow = (await getNoShowRate()).first;
    final issued = blood.fold<int>(0, (sum, item) => sum + item.unitsIssued);
    return HospitalOperationalKpis(bedOccupancyRate: bed.occupancyRate,
      icuUtilizationRate: icu.utilizationRate, opdSlotEfficiency: opd.utilizationRate,
      averageLengthOfStay: stay.averageDays, erTriageToDoctorMinutes: emergency.averageTriageToDoctorMinutes,
      bloodStockDepletionVelocity: issued.toDouble(), equipmentDowntimeRatio: equipment.downtimeRatio,
      noShowRate: noShow.noShowRate, generatedAt: _now);
  }

  bool _sameDay(Object? value, DateTime day) {
    final date = value is String ? DateTime.tryParse(value) : null;
    return date != null && date.year == day.year && date.month == day.month && date.day == day.day;
  }

  double _averageMinutes(List<Map<String, dynamic>> rows, String startKey, String endKey) {
    final values = <int>[];
    for (final row in rows) {
      final start = DateTime.tryParse('${row[startKey]}');
      final end = DateTime.tryParse('${row[endKey]}');
      if (start != null && end != null && !end.isBefore(start)) values.add(end.difference(start).inMinutes);
    }
    return values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
  }
}
