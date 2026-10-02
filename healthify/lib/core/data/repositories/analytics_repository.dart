import '../../models/analytics_model.dart';
import '../../queries/domain_queries.dart';

abstract class AnalyticsRepository {
  Future<HospitalOverviewMetrics> getOverviewMetrics();

  // Phase 9 Operational Analytics Contracts
  Future<HospitalOperationalKpis> getHospitalKpis({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<BedOccupancyMetric>> getBedOccupancy({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<ICUUtilizationMetric>> getICUUtilization({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<OPDSlotEfficiencyMetric>> getOPDSlotEfficiency({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<AverageLengthOfStayMetric>> getAverageLengthOfStay({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<EmergencyThroughputMetric>> getEmergencyThroughput({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<BloodStockMetric>> getBloodStockMetrics({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<EquipmentDowntimeMetric>> getEquipmentDowntime({AnalyticsQuery query = const AnalyticsQuery()});
  Future<List<NoShowMetric>> getNoShowRate({AnalyticsQuery query = const AnalyticsQuery()});
}
