import '../enums/domain_enums.dart';

/// Legacy Category helper for existing widgets
enum InsightCategory { capacityPlanning, clinicalAlert, inventoryForecast, triageRecommendation }

/// Legacy AI Insight Item for backward compatibility
class AIInsightItem {
  final String id;
  final String title;
  final String description;
  final InsightCategory category;
  final String recommendation;
  final double confidenceScore;
  final DateTime generatedAt;
  final String actionText;

  const AIInsightItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.recommendation,
    required this.confidenceScore,
    required this.generatedAt,
    required this.actionText,
  });
}

/// Structured AI Prediction Explanation Contract
class AIPredictionExplanation {
  final String summary;
  final List<String> factors;
  final String limitations;

  const AIPredictionExplanation({
    required this.summary,
    required this.factors,
    required this.limitations,
  });
}

/// Generic AI Prediction Entity for Medrix Phase 10
class AIPrediction {
  final String id;
  final String hospitalId;
  final AIModelType modelType;
  final DateTime predictionTime;
  final DateTime forecastStart;
  final DateTime forecastEnd;
  final double predictionValue;
  final String unit;
  final double confidence; // e.g. 0.89 = 89%
  final AIPredictionStatus status;
  final DateTime generatedAt;
  final String modelVersion;
  final AIPredictionExplanation explanation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIPrediction({
    required this.id,
    required this.hospitalId,
    required this.modelType,
    required this.predictionTime,
    required this.forecastStart,
    required this.forecastEnd,
    required this.predictionValue,
    required this.unit,
    required this.confidence,
    this.status = AIPredictionStatus.generated,
    required this.generatedAt,
    required this.modelVersion,
    required this.explanation,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Metadata describing AI ML Model status and readiness
class AIModelMetadata {
  final String modelId;
  final AIModelType modelType;
  final String modelName;
  final String version;
  final AIModelStatus status;
  final DateTime lastUpdated;
  final String trainingDataRange;
  final String predictionHorizon;
  final DateTime lastPredictionAt;

  const AIModelMetadata({
    required this.modelId,
    required this.modelType,
    required this.modelName,
    required this.version,
    required this.status,
    required this.lastUpdated,
    required this.trainingDataRange,
    required this.predictionHorizon,
    required this.lastPredictionAt,
  });
}

/// Operational AI Insight
class AIInsight {
  final String id;
  final String hospitalId;
  final AIModelType modelType;
  final String title;
  final String summary;
  final AIInsightSeverity severity;
  final double confidence;
  final String recommendation;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final RecommendationStatus status;
  final AIPredictionExplanation? explanation;

  const AIInsight({
    required this.id,
    required this.hospitalId,
    required this.modelType,
    required this.title,
    required this.summary,
    required this.severity,
    required this.confidence,
    required this.recommendation,
    required this.generatedAt,
    required this.expiresAt,
    this.status = RecommendationStatus.newAction,
    this.explanation,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AIInsight copyWith({
    String? id,
    String? hospitalId,
    AIModelType? modelType,
    String? title,
    String? summary,
    AIInsightSeverity? severity,
    double? confidence,
    String? recommendation,
    DateTime? generatedAt,
    DateTime? expiresAt,
    RecommendationStatus? status,
    AIPredictionExplanation? explanation,
  }) {
    return AIInsight(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      modelType: modelType ?? this.modelType,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      recommendation: recommendation ?? this.recommendation,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      explanation: explanation ?? this.explanation,
    );
  }
}

/// Doctor Availability & Workload Forecast Model
class DoctorWorkloadForecast {
  final String doctorId;
  final String doctorName;
  final String departmentId;
  final DateTime forecastDate;
  final int expectedAppointments;
  final int expectedEmergencyLoad;
  final String expectedWorkload; // Light, Normal, Heavy, Severe
  final double confidence;

  const DoctorWorkloadForecast({
    required this.doctorId,
    required this.doctorName,
    required this.departmentId,
    required this.forecastDate,
    required this.expectedAppointments,
    required this.expectedEmergencyLoad,
    required this.expectedWorkload,
    required this.confidence,
  });
}

/// Blood Demand Forecast Model
class BloodDemandForecast {
  final String hospitalId;
  final String bloodGroup;
  final String component;
  final DateTime forecastStart;
  final DateTime forecastEnd;
  final int expectedDemand;
  final int currentInventory;
  final int projectedInventory;
  final String shortageRisk; // Low, Moderate, High, Critical
  final double confidence;
  final DateTime generatedAt;

  const BloodDemandForecast({
    required this.hospitalId,
    required this.bloodGroup,
    required this.component,
    required this.forecastStart,
    required this.forecastEnd,
    required this.expectedDemand,
    required this.currentInventory,
    required this.projectedInventory,
    required this.shortageRisk,
    required this.confidence,
    required this.generatedAt,
  });
}

/// Bed Occupancy Forecast Model
class BedOccupancyForecast {
  final String hospitalId;
  final String? wardId;
  final DateTime forecastStart;
  final DateTime forecastEnd;
  final int currentOccupancy;
  final int predictedOccupancy;
  final int predictedAvailableBeds;
  final double confidence;
  final DateTime generatedAt;

  const BedOccupancyForecast({
    required this.hospitalId,
    this.wardId,
    required this.forecastStart,
    required this.forecastEnd,
    required this.currentOccupancy,
    required this.predictedOccupancy,
    required this.predictedAvailableBeds,
    required this.confidence,
    required this.generatedAt,
  });
}

/// ICU Capacity Forecast Model
class ICUCapacityForecast {
  final String hospitalId;
  final String? icuUnitId;
  final DateTime forecastStart;
  final DateTime forecastEnd;
  final int currentOccupancy;
  final int predictedOccupancy;
  final int predictedAvailableBeds;
  final double confidence;
  final DateTime generatedAt;

  const ICUCapacityForecast({
    required this.hospitalId,
    this.icuUnitId,
    required this.forecastStart,
    required this.forecastEnd,
    required this.currentOccupancy,
    required this.predictedOccupancy,
    required this.predictedAvailableBeds,
    required this.confidence,
    required this.generatedAt,
  });
}

/// Hospital-Wide Capacity Forecast Contract
class HospitalCapacityForecast {
  final String hospitalId;
  final DateTime forecastStart;
  final DateTime forecastEnd;
  final int bedCapacity;
  final int predictedBedOccupancy;
  final int icuCapacity;
  final int predictedICUOccupancy;
  final int doctorCapacity;
  final int predictedDoctorLoad;
  final int staffCapacity;
  final int predictedStaffLoad;
  final CapacityPressureLevel overallCapacityPressure;
  final double confidence;
  final DateTime generatedAt;

  const HospitalCapacityForecast({
    required this.hospitalId,
    required this.forecastStart,
    required this.forecastEnd,
    required this.bedCapacity,
    required this.predictedBedOccupancy,
    required this.icuCapacity,
    required this.predictedICUOccupancy,
    required this.doctorCapacity,
    required this.predictedDoctorLoad,
    required this.staffCapacity,
    required this.predictedStaffLoad,
    required this.overallCapacityPressure,
    required this.confidence,
    required this.generatedAt,
  });
}

/// Patient-Facing Emergency Hospital Recommendation Contract
class EmergencyHospitalRecommendation {
  final String hospitalId;
  final String hospitalName;
  final double distanceKm;
  final String emergencyAvailability;
  final int availableERCapacity;
  final int icuAvailability;
  final bool specialistAvailability;
  final bool bloodAvailability;
  final int estimatedWaitMinutes;
  final double recommendationScore;
  final double confidence;
  final DateTime generatedAt;
  final DateTime expiresAt;

  const EmergencyHospitalRecommendation({
    required this.hospitalId,
    required this.hospitalName,
    required this.distanceKm,
    required this.emergencyAvailability,
    required this.availableERCapacity,
    required this.icuAvailability,
    required this.specialistAvailability,
    required this.bloodAvailability,
    required this.estimatedWaitMinutes,
    required this.recommendationScore,
    required this.confidence,
    required this.generatedAt,
    required this.expiresAt,
  });
}

/// OPD / ER Department Queue Forecast Model
class QueueForecast {
  final String departmentId;
  final String departmentName;
  final DateTime forecastStart;
  final DateTime forecastEnd;
  final int currentQueue;
  final int predictedQueue;
  final int predictedWaitMinutes;
  final double confidence;
  final DateTime generatedAt;

  const QueueForecast({
    required this.departmentId,
    required this.departmentName,
    required this.forecastStart,
    required this.forecastEnd,
    required this.currentQueue,
    required this.predictedQueue,
    required this.predictedWaitMinutes,
    required this.confidence,
    required this.generatedAt,
  });
}

/// What-If Operational Simulator Result Contract
class WhatIfSimulationResult {
  final String scenarioName;
  final HospitalResourceType resourceType;
  final String currentMetric;
  final String simulatedMetric;
  final String projectedChange;
  final double confidence;

  const WhatIfSimulationResult({
    required this.scenarioName,
    required this.resourceType,
    required this.currentMetric,
    required this.simulatedMetric,
    required this.projectedChange,
    required this.confidence,
  });
}
