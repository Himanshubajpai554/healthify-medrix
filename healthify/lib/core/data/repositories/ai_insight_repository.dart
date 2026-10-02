import '../../enums/domain_enums.dart';
import '../../models/ai_insight_model.dart';
import '../../queries/domain_queries.dart';

abstract class AIInsightRepository {
  Future<List<AIInsight>> getInsights({AIQuery query = const AIQuery()});
  Future<AIInsight?> getInsightById(String id);

  Future<List<DoctorWorkloadForecast>> getDoctorAvailabilityForecast({String? departmentId});
  Future<DoctorWorkloadForecast?> getDoctorWorkloadForecast(String doctorId);

  Future<List<BloodDemandForecast>> getBloodDemandForecast({String? bloodGroup});

  Future<BedOccupancyForecast> getBedOccupancyForecast({String? wardId});
  Future<ICUCapacityForecast> getICUCapacityForecast({String? icuUnitId});
  Future<HospitalCapacityForecast> getHospitalCapacityForecast();

  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations({String? hospitalId});

  Future<List<QueueForecast>> getQueueForecast({String? departmentId});

  Future<List<AIPrediction>> getPredictionHistory({AIQuery query = const AIQuery()});

  Future<List<AIModelMetadata>> getModelMetadata();

  Future<WhatIfSimulationResult> getWhatIfSimulation(String scenarioName, Map<String, dynamic> params);

  Future<AIInsight> reviewInsight(String insightId, RecommendationStatus status);
  Future<AIInsight> acceptInsight(String insightId);
  Future<AIInsight> rejectInsight(String insightId);

  // Legacy compatibility methods
  Future<List<AIInsightItem>> getInsightsList();
  Future<AIInsightItem> generateInsightForDepartment(String department);
}
