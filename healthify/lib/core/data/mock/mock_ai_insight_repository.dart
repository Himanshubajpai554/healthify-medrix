import '../repositories/ai_insight_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/ai_insight_model.dart';
import '../../queries/domain_queries.dart';

class MockAIInsightRepository implements AIInsightRepository {
  final List<AIInsight> _insights = [
    AIInsight(
      id: 'INS-2026-001',
      hospitalId: 'HOSP-01',
      modelType: AIModelType.bedOccupancy,
      title: 'ICU Bed Surge Warning',
      summary: 'ICU utilization projected to exceed 92% capacity within 18 hours based on acute admissions.',
      severity: AIInsightSeverity.critical,
      confidence: 0.91,
      recommendation: 'Initiate Step-Down Discharge evaluations for 3 stabilized Cardiac ICU patients.',
      generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(hours: 23)),
      status: RecommendationStatus.newAction,
      explanation: const AIPredictionExplanation(
        summary: 'High admission rate from ER coupled with delayed step-down transfers.',
        factors: ['3 Acute ER Traumas', 'Occupancy at 87.5%', 'Historical weekend surge factor 1.25x'],
        limitations: 'Forecast depends on active ER triage intake stability.',
      ),
    ),
    AIInsight(
      id: 'INS-2026-002',
      hospitalId: 'HOSP-01',
      modelType: AIModelType.bloodDemand,
      title: 'O- Negative Blood Stock Depletion Alert',
      summary: 'O- Negative emergency reserve projected to drop below critical threshold (<5 units) by tomorrow.',
      severity: AIInsightSeverity.high,
      confidence: 0.88,
      recommendation: 'Issue priority blood donor drive dispatch for O- negative blood group.',
      generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
      status: RecommendationStatus.newAction,
      explanation: const AIPredictionExplanation(
        summary: 'Emergency trauma consumption depleted 6 units O- blood in past 12 hours.',
        factors: ['2 Severe Surgical Operations', 'Low regional blood bank supply', 'Historical burn rate'],
        limitations: 'Assumes no immediate external transfer from regional blood bank.',
      ),
    ),
    AIInsight(
      id: 'INS-2026-003',
      hospitalId: 'HOSP-01',
      modelType: AIModelType.queueForecast,
      title: 'OPD Evening Surge Queue Forecast',
      summary: 'General Medicine OPD queue wait time estimated to reach 42 minutes between 4 PM - 7 PM.',
      severity: AIInsightSeverity.medium,
      confidence: 0.85,
      recommendation: 'Add 1 Float Physician (Dr. Marcus Vance) to OPD Room 104.',
      generatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
      status: RecommendationStatus.newAction,
      explanation: const AIPredictionExplanation(
        summary: 'Walk-in appointments 30% higher than average seasonal baseline.',
        factors: ['High walk-in volume', '2 Scheduled doctor surgeries'],
        limitations: 'Subject to sudden doctor availability changes.',
      ),
    ),
  ];

  final List<AIModelMetadata> _modelMetadata = [
    AIModelMetadata(
      modelId: 'MOD-DOC-01',
      modelType: AIModelType.doctorAvailability,
      modelName: 'Doctor Availability & Workload Predictor',
      version: 'doctor-availability-v1.4',
      status: AIModelStatus.active,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      trainingDataRange: 'Last 12 Months Hospital Roster & OPD Logs',
      predictionHorizon: '24 Hours to 7 Days',
      lastPredictionAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AIModelMetadata(
      modelId: 'MOD-BLOOD-01',
      modelType: AIModelType.bloodDemand,
      modelName: 'Blood Stock Depletion & Demand Forecaster',
      version: 'blood-demand-v2.1',
      status: AIModelStatus.active,
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      trainingDataRange: 'Last 24 Months Blood Bank Issuance & Surgery Data',
      predictionHorizon: '1 to 14 Days',
      lastPredictionAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    AIModelMetadata(
      modelId: 'MOD-BED-01',
      modelType: AIModelType.bedOccupancy,
      modelName: 'Inpatient Bed & ICU Occupancy Predictor',
      version: 'bed-occupancy-v3.0',
      status: AIModelStatus.active,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      trainingDataRange: 'Last 36 Months Admissions, Discharges & ER Surges',
      predictionHorizon: '12 Hours to 72 Hours',
      lastPredictionAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AIModelMetadata(
      modelId: 'MOD-ER-REC-01',
      modelType: AIModelType.emergencyHospitalRecommendation,
      modelName: 'Emergency Hospital Routing & Capacity Evaluator',
      version: 'emergency-recommendation-v1.0',
      status: AIModelStatus.active,
      lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      trainingDataRange: 'Regional ER Telemetry & Facility Availability',
      predictionHorizon: 'Real-Time Dynamic Routing',
      lastPredictionAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  @override
  Future<List<AIInsight>> getInsights({AIQuery query = const AIQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<AIInsight>.from(_insights);
    if (query.modelType != null) {
      results = results.where((i) => i.modelType == query.modelType).toList();
    }
    if (query.severity != null) {
      results = results.where((i) => i.severity == query.severity).toList();
    }
    if (query.status != null) {
      results = results.where((i) => i.status == query.status).toList();
    }
    return results;
  }

  @override
  Future<AIInsight?> getInsightById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _insights.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DoctorWorkloadForecast>> getDoctorAvailabilityForecast({String? departmentId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      DoctorWorkloadForecast(
        doctorId: 'DOC1',
        doctorName: 'Dr. Sarah Connor',
        departmentId: 'DEP-CARD-01',
        forecastDate: now.add(const Duration(days: 1)),
        expectedAppointments: 14,
        expectedEmergencyLoad: 3,
        expectedWorkload: 'Heavy',
        confidence: 0.88,
      ),
      DoctorWorkloadForecast(
        doctorId: 'DOC2',
        doctorName: 'Dr. Marcus Vance',
        departmentId: 'DEP-NEURO-01',
        forecastDate: now.add(const Duration(days: 1)),
        expectedAppointments: 8,
        expectedEmergencyLoad: 1,
        expectedWorkload: 'Normal',
        confidence: 0.92,
      ),
    ];
  }

  @override
  Future<DoctorWorkloadForecast?> getDoctorWorkloadForecast(String doctorId) async {
    final list = await getDoctorAvailabilityForecast();
    try {
      return list.firstWhere((d) => d.doctorId == doctorId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BloodDemandForecast>> getBloodDemandForecast({String? bloodGroup}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      BloodDemandForecast(
        hospitalId: 'HOSP-01',
        bloodGroup: 'O-',
        component: 'Packed Red Blood Cells',
        forecastStart: now,
        forecastEnd: now.add(const Duration(days: 3)),
        expectedDemand: 18,
        currentInventory: 8,
        projectedInventory: 2,
        shortageRisk: 'High',
        confidence: 0.89,
        generatedAt: now,
      ),
      BloodDemandForecast(
        hospitalId: 'HOSP-01',
        bloodGroup: 'A+',
        component: 'Whole Blood',
        forecastStart: now,
        forecastEnd: now.add(const Duration(days: 3)),
        expectedDemand: 25,
        currentInventory: 45,
        projectedInventory: 32,
        shortageRisk: 'Low',
        confidence: 0.94,
        generatedAt: now,
      ),
    ];
  }

  @override
  Future<BedOccupancyForecast> getBedOccupancyForecast({String? wardId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return BedOccupancyForecast(
      hospitalId: 'HOSP-01',
      wardId: wardId ?? 'WARD-MAIN',
      forecastStart: now,
      forecastEnd: now.add(const Duration(hours: 48)),
      currentOccupancy: 322,
      predictedOccupancy: 348,
      predictedAvailableBeds: 37,
      confidence: 0.87,
      generatedAt: now,
    );
  }

  @override
  Future<ICUCapacityForecast> getICUCapacityForecast({String? icuUnitId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return ICUCapacityForecast(
      hospitalId: 'HOSP-01',
      icuUnitId: icuUnitId ?? 'ICU-CRITICAL',
      forecastStart: now,
      forecastEnd: now.add(const Duration(hours: 24)),
      currentOccupancy: 26,
      predictedOccupancy: 30,
      predictedAvailableBeds: 2,
      confidence: 0.91,
      generatedAt: now,
    );
  }

  @override
  Future<HospitalCapacityForecast> getHospitalCapacityForecast() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return HospitalCapacityForecast(
      hospitalId: 'HOSP-01',
      forecastStart: now,
      forecastEnd: now.add(const Duration(hours: 24)),
      bedCapacity: 400,
      predictedBedOccupancy: 348,
      icuCapacity: 32,
      predictedICUOccupancy: 30,
      doctorCapacity: 45,
      predictedDoctorLoad: 38,
      staffCapacity: 120,
      predictedStaffLoad: 105,
      overallCapacityPressure: CapacityPressureLevel.high,
      confidence: 0.89,
      generatedAt: now,
    );
  }

  @override
  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations({String? hospitalId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      EmergencyHospitalRecommendation(
        hospitalId: 'HOSP-01',
        hospitalName: 'St. Jude Memorial Hospital',
        distanceKm: 3.2,
        emergencyAvailability: 'Active Level 1 Trauma Center',
        availableERCapacity: 6,
        icuAvailability: 4,
        specialistAvailability: true,
        bloodAvailability: true,
        estimatedWaitMinutes: 12,
        recommendationScore: 0.95,
        confidence: 0.93,
        generatedAt: now,
        expiresAt: now.add(const Duration(minutes: 30)),
      ),
      EmergencyHospitalRecommendation(
        hospitalId: 'HOSP-02',
        hospitalName: 'Metro General Healthcare Center',
        distanceKm: 7.8,
        emergencyAvailability: 'Full - Diversion Alert',
        availableERCapacity: 1,
        icuAvailability: 0,
        specialistAvailability: false,
        bloodAvailability: true,
        estimatedWaitMinutes: 55,
        recommendationScore: 0.42,
        confidence: 0.90,
        generatedAt: now,
        expiresAt: now.add(const Duration(minutes: 30)),
      ),
    ];
  }

  @override
  Future<List<QueueForecast>> getQueueForecast({String? departmentId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      QueueForecast(
        departmentId: 'DEP-CARD-01',
        departmentName: 'Cardiology OPD',
        forecastStart: now,
        forecastEnd: now.add(const Duration(hours: 4)),
        currentQueue: 12,
        predictedQueue: 18,
        predictedWaitMinutes: 35,
        confidence: 0.86,
        generatedAt: now,
      ),
      QueueForecast(
        departmentId: 'DEP-EMERG-01',
        departmentName: 'Emergency Triage Queue',
        forecastStart: now,
        forecastEnd: now.add(const Duration(hours: 2)),
        currentQueue: 5,
        predictedQueue: 9,
        predictedWaitMinutes: 14,
        confidence: 0.91,
        generatedAt: now,
      ),
    ];
  }

  @override
  Future<List<AIPrediction>> getPredictionHistory({AIQuery query = const AIQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      AIPrediction(
        id: 'PRED-001',
        hospitalId: 'HOSP-01',
        modelType: AIModelType.bedOccupancy,
        predictionTime: now.subtract(const Duration(days: 1)),
        forecastStart: now.subtract(const Duration(days: 1)),
        forecastEnd: now,
        predictionValue: 84.5,
        unit: 'Percentage',
        confidence: 0.89,
        status: AIPredictionStatus.reviewed,
        generatedAt: now.subtract(const Duration(days: 1)),
        modelVersion: 'bed-occupancy-v3.0',
        explanation: const AIPredictionExplanation(
          summary: 'Occupancy prediction verified against historical actuals.',
          factors: ['Weekend admission rate', 'Discharge velocity'],
          limitations: 'Accuracy within +/- 2.5%.',
        ),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<List<AIModelMetadata>> getModelMetadata() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _modelMetadata;
  }

  @override
  Future<WhatIfSimulationResult> getWhatIfSimulation(String scenarioName, Map<String, dynamic> params) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final addedBeds = params['addedICUBeds'] as int? ?? 4;
    return WhatIfSimulationResult(
      scenarioName: scenarioName,
      resourceType: HospitalResourceType.icuBed,
      currentMetric: 'ICU Occupancy: 87.5% (4 available)',
      simulatedMetric: 'Simulated Occupancy: 77.8% (${4 + addedBeds} available)',
      projectedChange: 'Capacity Pressure reduced from HIGH to WATCH (-9.7%)',
      confidence: 0.91,
    );
  }

  @override
  Future<AIInsight> reviewInsight(String insightId, RecommendationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _insights.indexWhere((i) => i.id == insightId);
    if (index == -1) throw Exception('Insight not found');
    final updated = _insights[index].copyWith(status: status);
    _insights[index] = updated;
    return updated;
  }

  @override
  Future<AIInsight> acceptInsight(String insightId) async {
    return await reviewInsight(insightId, RecommendationStatus.accepted);
  }

  @override
  Future<AIInsight> rejectInsight(String insightId) async {
    return await reviewInsight(insightId, RecommendationStatus.rejected);
  }

  // Legacy compatibility methods
  @override
  Future<List<AIInsightItem>> getInsightsList() async {
    return _insights.map((i) => AIInsightItem(
      id: i.id,
      title: i.title,
      description: i.summary,
      category: InsightCategory.capacityPlanning,
      recommendation: i.recommendation,
      confidenceScore: i.confidence,
      generatedAt: i.generatedAt,
      actionText: 'Review Insight',
    )).toList();
  }

  @override
  Future<AIInsightItem> generateInsightForDepartment(String department) async {
    final domain = AIInsight(
      id: 'INS-${DateTime.now().millisecondsSinceEpoch}',
      hospitalId: 'HOSP-01',
      modelType: AIModelType.queueForecast,
      title: '$department Workload Surge',
      summary: 'Dynamic workload surge predicted in $department.',
      severity: AIInsightSeverity.medium,
      confidence: 0.88,
      recommendation: 'Reassign 1 float physician to $department.',
      generatedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );
    _insights.insert(0, domain);
    return AIInsightItem(
      id: domain.id,
      title: domain.title,
      description: domain.summary,
      category: InsightCategory.triageRecommendation,
      recommendation: domain.recommendation,
      confidenceScore: domain.confidence,
      generatedAt: domain.generatedAt,
      actionText: 'Review Insight',
    );
  }
}
