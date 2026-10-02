import '../data/repositories/analytics_repository.dart';
import '../models/analytics_model.dart';
import '../queries/domain_queries.dart';

class AnalyticsService {
  final AnalyticsRepository analyticsRepository;

  AnalyticsService({required this.analyticsRepository});

  Future<HospitalOverviewMetrics> getOverviewMetrics() async {
    return await analyticsRepository.getOverviewMetrics();
  }

  Future<HospitalOperationalKpis> getHospitalKpis({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getHospitalKpis(query: query);
  }

  Future<List<BedOccupancyMetric>> getBedOccupancy({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getBedOccupancy(query: query);
  }

  Future<List<ICUUtilizationMetric>> getICUUtilization({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getICUUtilization(query: query);
  }

  Future<List<OPDSlotEfficiencyMetric>> getOPDSlotEfficiency({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getOPDSlotEfficiency(query: query);
  }

  Future<List<AverageLengthOfStayMetric>> getAverageLengthOfStay({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getAverageLengthOfStay(query: query);
  }

  Future<List<EmergencyThroughputMetric>> getEmergencyThroughput({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getEmergencyThroughput(query: query);
  }

  Future<List<BloodStockMetric>> getBloodStockMetrics({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getBloodStockMetrics(query: query);
  }

  Future<List<EquipmentDowntimeMetric>> getEquipmentDowntime({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getEquipmentDowntime(query: query);
  }

  Future<List<NoShowMetric>> getNoShowRate({AnalyticsQuery query = const AnalyticsQuery()}) async {
    return await analyticsRepository.getNoShowRate(query: query);
  }
}
