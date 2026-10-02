import '../enums/domain_enums.dart';
export '../../hospital/blood/blood_model.dart';

class BloodUnit {
  final String id;
  final String hospitalId;
  final String bloodGroup;
  final String component;
  final int unitsAvailable;
  final BloodUnitStatus status;
  final DateTime collectionDate;
  final DateTime expiryDate;
  final String? donorId;
  final String storageLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodUnit({
    required this.id,
    required this.hospitalId,
    required this.bloodGroup,
    this.component = 'Whole Blood',
    required this.unitsAvailable,
    required this.status,
    required this.collectionDate,
    required this.expiryDate,
    this.donorId,
    this.storageLocation = 'Main Blood Bank Bay A',
    required this.createdAt,
    required this.updatedAt,
  });

  int get units => unitsAvailable;
}

class BloodRequest {
  final String id;
  final String hospitalId;
  final String patientId;
  final String requesterId;
  final String bloodGroup;
  final String component;
  final int unitsRequired;
  final BloodRequestStatus status;
  final String urgencyLevel;
  final DateTime requestDate;
  final DateTime? fulfilledDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodRequest({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    required this.requesterId,
    required this.bloodGroup,
    this.component = 'Whole Blood',
    required this.unitsRequired,
    required this.status,
    required this.urgencyLevel,
    required this.requestDate,
    this.fulfilledDate,
    required this.createdAt,
    required this.updatedAt,
  });

  String get patientName => 'Patient $patientId';
  int get units => unitsRequired;
  String get urgency => urgencyLevel;
}

class BloodDonation {
  final String id;
  final String hospitalId;
  final String donorReference;
  final String bloodGroup;
  final String component;
  final int volumeMl;
  final DateTime collectionDate;
  final String screeningStatus;
  final String storageStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodDonation({
    required this.id,
    required this.hospitalId,
    required this.donorReference,
    required this.bloodGroup,
    this.component = 'Whole Blood',
    required this.volumeMl,
    required this.collectionDate,
    this.screeningStatus = 'Passed',
    this.storageStatus = 'Stored',
    required this.createdAt,
    required this.updatedAt,
  });
}

class BloodCompatibilityResult {
  final String requestId;
  final bool compatible;
  final String matchedBloodGroup;
  final String matchedComponent;
  final int availableUnits;
  final int compatibleUnits;
  final String reason;
  final DateTime generatedAt;

  const BloodCompatibilityResult({
    required this.requestId,
    required this.compatible,
    required this.matchedBloodGroup,
    required this.matchedComponent,
    required this.availableUnits,
    required this.compatibleUnits,
    required this.reason,
    required this.generatedAt,
  });
}

class BloodInventorySummary {
  final int totalUnits;
  final int availableUnits;
  final int reservedUnits;
  final int expiringUnits;
  final int criticalUnits;
  final DateTime lastUpdated;

  const BloodInventorySummary({
    required this.totalUnits,
    required this.availableUnits,
    required this.reservedUnits,
    required this.expiringUnits,
    required this.criticalUnits,
    required this.lastUpdated,
  });
}

class BloodGroupInventorySummary {
  final String bloodGroup;
  final int totalUnits;
  final int availableUnits;
  final int reservedUnits;
  final int expiringUnits;
  final bool critical;
  final int availableVolumeMl;

  const BloodGroupInventorySummary({
    required this.bloodGroup,
    required this.totalUnits,
    required this.availableUnits,
    required this.reservedUnits,
    required this.expiringUnits,
    required this.critical,
    required this.availableVolumeMl,
  });
}

class BloodShortageRisk {
  final String bloodGroup;
  final String component;
  final String riskLevel; // Normal, Warning, Critical
  final int currentStock;
  final int predictedDemand;
  final int expectedShortage;
  final String forecastWindow;
  final double confidence;

  const BloodShortageRisk({
    required this.bloodGroup,
    required this.component,
    required this.riskLevel,
    required this.currentStock,
    required this.predictedDemand,
    required this.expectedShortage,
    required this.forecastWindow,
    required this.confidence,
  });
}

class DonationNeed {
  final String bloodGroup;
  final String component;
  final int currentStock;
  final int targetStock;
  final int shortfall;
  final String urgency;
  final String recommendedCollectionWindow;

  const DonationNeed({
    required this.bloodGroup,
    required this.component,
    required this.currentStock,
    required this.targetStock,
    required this.shortfall,
    required this.urgency,
    required this.recommendedCollectionWindow,
  });
}

class BloodActivity {
  final String id;
  final String hospitalId;
  final String bloodUnitId;
  final String? requestId;
  final String action;
  final String actorId;
  final DateTime timestamp;
  final String? reason;

  const BloodActivity({
    required this.id,
    required this.hospitalId,
    required this.bloodUnitId,
    this.requestId,
    required this.action,
    required this.actorId,
    required this.timestamp,
    this.reason,
  });
}
