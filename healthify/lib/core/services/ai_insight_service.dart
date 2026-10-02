import '../data/repositories/ai_insight_repository.dart';
import '../enums/domain_enums.dart';
import '../models/ai_insight_model.dart';
import '../queries/domain_queries.dart';

class AIService {
  final AIInsightRepository aiRepository;

  AIService({required this.aiRepository});

  Future<List<AIInsight>> getInsights({AIQuery query = const AIQuery()}) async {
    return await aiRepository.getInsights(query: query);
  }

  Future<AIInsight?> getInsightById(String id) async {
    return await aiRepository.getInsightById(id);
  }

  Future<List<DoctorWorkloadForecast>> getDoctorAvailabilityForecast({String? departmentId}) async {
    return await aiRepository.getDoctorAvailabilityForecast(departmentId: departmentId);
  }

  Future<DoctorWorkloadForecast?> getDoctorWorkloadForecast(String doctorId) async {
    return await aiRepository.getDoctorWorkloadForecast(doctorId);
  }

  Future<List<BloodDemandForecast>> getBloodDemandForecast({String? bloodGroup}) async {
    return await aiRepository.getBloodDemandForecast(bloodGroup: bloodGroup);
  }

  Future<BedOccupancyForecast> getBedOccupancyForecast({String? wardId}) async {
    return await aiRepository.getBedOccupancyForecast(wardId: wardId);
  }

  Future<ICUCapacityForecast> getICUCapacityForecast({String? icuUnitId}) async {
    return await aiRepository.getICUCapacityForecast(icuUnitId: icuUnitId);
  }

  Future<HospitalCapacityForecast> getHospitalCapacityForecast() async {
    return await aiRepository.getHospitalCapacityForecast();
  }

  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations({String? hospitalId}) async {
    return await aiRepository.getEmergencyRecommendations(hospitalId: hospitalId);
  }

  Future<List<QueueForecast>> getQueueForecast({String? departmentId}) async {
    return await aiRepository.getQueueForecast(departmentId: departmentId);
  }

  Future<List<AIPrediction>> getPredictionHistory({AIQuery query = const AIQuery()}) async {
    return await aiRepository.getPredictionHistory(query: query);
  }

  Future<List<AIModelMetadata>> getModelMetadata() async {
    return await aiRepository.getModelMetadata();
  }

  Future<WhatIfSimulationResult> simulateWhatIf(String scenarioName, Map<String, dynamic> params) async {
    return await aiRepository.getWhatIfSimulation(scenarioName, params);
  }

  Future<AIInsight> reviewInsight(String insightId, RecommendationStatus status) async {
    return await aiRepository.reviewInsight(insightId, status);
  }

  Future<AIInsight> acceptInsight(String insightId) async {
    return await aiRepository.acceptInsight(insightId);
  }

  Future<AIInsight> rejectInsight(String insightId) async {
    return await aiRepository.rejectInsight(insightId);
  }
}
