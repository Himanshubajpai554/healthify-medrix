import '../repositories/analytics_repository.dart';
import '../../models/analytics_model.dart';
import '../../queries/domain_queries.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<HospitalOverviewMetrics> getOverviewMetrics() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const HospitalOverviewMetrics(
      totalAdmittedPatients: 342,
      icuOccupancyCount: 28,
      emergencyActiveCases: 15,
      availableDoctorsCount: 18,
      bedOccupancyPercentage: 84.5,
      bloodStockAdequacyPercentage: 92.0,
      dailyOutpatientVolume: 185,
      pendingLabReports: 14,
    );
  }

  @override
  Future<HospitalOperationalKpis> getHospitalKpis({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return HospitalOperationalKpis(
      bedOccupancyRate: 84.5,
      icuUtilizationRate: 87.5,
      opdSlotEfficiency: 91.2,
      averageLengthOfStay: 4.2,
      erTriageToDoctorMinutes: 14.5,
      bloodStockDepletionVelocity: 12.4, // units/day
      equipmentDowntimeRatio: 2.1,
      noShowRate: 6.8,
      bedOccupancyChange: '+3.2%',
      icuChange: '-1.5%',
      opdChange: '+4.0%',
      lengthOfStayChange: '-0.2 days',
      erTimeChange: '-2.1 min',
      bloodVelocityChange: 'Stable',
      downtimeChange: '-0.5%',
      noShowChange: '-1.2%',
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<BedOccupancyMetric>> getBedOccupancy({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final occupied = 320 + (i * 4) % 25;
      return BedOccupancyMetric(
        date: d,
        totalCapacity: 400,
        occupied: occupied,
        available: 400 - occupied - 15,
        reserved: 10,
        maintenance: 5,
        occupancyRate: (occupied / 400) * 100,
      );
    });
  }

  @override
  Future<List<ICUUtilizationMetric>> getICUUtilization({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final occupied = 26 + (i % 5);
      return ICUUtilizationMetric(
        date: d,
        capacity: 32,
        occupied: occupied,
        available: 32 - occupied,
        utilizationRate: (occupied / 32) * 100,
      );
    });
  }

  @override
  Future<List<OPDSlotEfficiencyMetric>> getOPDSlotEfficiency({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const scheduled = 200;
      final completed = 175 + (i * 2) % 15;
      const cancelled = 10;
      final noShow = scheduled - completed - cancelled;
      return OPDSlotEfficiencyMetric(
        date: d,
        scheduledSlots: scheduled,
        completedSlots: completed,
        cancelledSlots: cancelled,
        noShowSlots: noShow,
        utilizationRate: (completed / scheduled) * 100,
      );
    });
  }

  @override
  Future<List<AverageLengthOfStayMetric>> getAverageLengthOfStay({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return AverageLengthOfStayMetric(
        date: d,
        averageDays: 4.1 + (i % 3) * 0.1,
        admissions: 35 + i % 6,
        discharges: 32 + i % 7,
      );
    });
  }

  @override
  Future<List<EmergencyThroughputMetric>> getEmergencyThroughput({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return EmergencyThroughputMetric(
        date: d,
        emergencyCases: 45 + i % 10,
        averageTriageToDoctorMinutes: 15.0 - (i * 0.4),
        medianTriageToDoctorMinutes: 12.0 - (i * 0.3),
        criticalCases: 8 + i % 3,
      );
    });
  }

  @override
  Future<List<BloodStockMetric>> getBloodStockMetrics({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    final groups = ['O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-'];
    return groups.map((g) => BloodStockMetric(
      date: now,
      bloodGroup: g,
      startingUnits: 40,
      unitsIssued: 12,
      unitsAdded: 15,
      endingUnits: 43,
      depletionVelocity: 2.8,
    )).toList();
  }

  @override
  Future<List<EquipmentDowntimeMetric>> getEquipmentDowntime({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return EquipmentDowntimeMetric(
        date: d,
        equipmentCount: 150,
        downtimeHours: 7.5 - (i * 0.5),
        availableHours: 3592.5,
        downtimeRatio: (7.5 / 3600) * 100,
      );
    });
  }

  @override
  Future<List<NoShowMetric>> getNoShowRate({AnalyticsQuery query = const AnalyticsQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const scheduled = 180;
      final noShow = 12 - (i % 4);
      return NoShowMetric(
        date: d,
        scheduledAppointments: scheduled,
        completedAppointments: scheduled - noShow - 15,
        cancelledAppointments: 15,
        noShowAppointments: noShow,
        noShowRate: (noShow / scheduled) * 100,
      );
    });
  }
}
