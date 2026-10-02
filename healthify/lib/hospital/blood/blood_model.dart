enum BloodGroupType { aPos, aNeg, bPos, bNeg, abPos, abNeg, oPos, oNeg }
enum BloodComponentType { wholeBlood, rbc, plasma, platelets, cryoprecipitate }
enum InventoryUnitStatus { available, reserved, quarantine, expiringSoon, expired, discarded }
enum RequestPriority { critical, urgent, normal }
enum RequestStatus { pending, partiallyAllocated, allocated, completed }

class BloodGroupSummaryItem {
  final String bloodGroup; // e.g. "A+", "O-"
  final int available;
  final int reserved;
  final int minRequired;
  final String status; // Healthy, Limited, Critical

  const BloodGroupSummaryItem({
    required this.bloodGroup,
    required this.available,
    required this.reserved,
    required this.minRequired,
    required this.status,
  });

  double get ratio => minRequired > 0 ? available / minRequired : 1.0;
}

class BloodInventoryUnit {
  final String unitId; // e.g. "BG-10231"
  final String bloodGroup; // e.g. "O+"
  final String component; // e.g. "Whole Blood", "RBC"
  final int quantityUnits;
  final DateTime collectionDate;
  final DateTime expiryDate;
  InventoryUnitStatus status;
  final String storageLocation; // e.g. "Refrigerator A"
  final String lastUpdated;

  BloodInventoryUnit({
    required this.unitId,
    required this.bloodGroup,
    required this.component,
    required this.quantityUnits,
    required this.collectionDate,
    required this.expiryDate,
    required this.status,
    required this.storageLocation,
    required this.lastUpdated,
  });
}

class DonationRecordItem {
  final String donorId; // e.g. "DNR-1024"
  final String bloodGroup;
  final String donationType;
  final int units;
  final String donationDate;
  final String screeningStatus; // Screened, Pending
  final String storageStatus; // Stored, In Testing

  const DonationRecordItem({
    required this.donorId,
    required this.bloodGroup,
    required this.donationType,
    required this.units,
    required this.donationDate,
    required this.screeningStatus,
    required this.storageStatus,
  });
}

class BloodRequestItem {
  final String requestId; // e.g. "BR-1042"
  final String bloodGroup;
  final int requiredUnits;
  int allocatedUnits;
  final String department; // Emergency, ICU, Surgery, Maternity, Trauma, Other
  final RequestPriority priority;
  RequestStatus status;

  BloodRequestItem({
    required this.requestId,
    required this.bloodGroup,
    required this.requiredUnits,
    required this.allocatedUnits,
    required this.department,
    required this.priority,
    required this.status,
  });
}