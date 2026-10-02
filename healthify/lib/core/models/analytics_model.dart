class HospitalOverviewMetrics {
  final int totalAdmittedPatients;
  final int icuOccupancyCount;
  final int emergencyActiveCases;
  final int availableDoctorsCount;
  final double bedOccupancyPercentage;
  final double bloodStockAdequacyPercentage;
  final int dailyOutpatientVolume;
  final int pendingLabReports;

  const HospitalOverviewMetrics({
    required this.totalAdmittedPatients,
    required this.icuOccupancyCount,
    required this.emergencyActiveCases,
    required this.availableDoctorsCount,
    required this.bedOccupancyPercentage,
    required this.bloodStockAdequacyPercentage,
    required this.dailyOutpatientVolume,
    required this.pendingLabReports,
  });
}

class BedOccupancyMetric {
  final DateTime date;
  final int totalCapacity;
  final int occupied;
  final int available;
  final int reserved;
  final int maintenance;
  final double occupancyRate;

  const BedOccupancyMetric({
    required this.date,
    required this.totalCapacity,
    required this.occupied,
    required this.available,
    required this.reserved,
    required this.maintenance,
    required this.occupancyRate,
  });
}

class ICUUtilizationMetric {
  final DateTime date;
  final int capacity;
  final int occupied;
  final int available;
  final double utilizationRate;

  const ICUUtilizationMetric({
    required this.date,
    required this.capacity,
    required this.occupied,
    required this.available,
    required this.utilizationRate,
  });
}

class OPDSlotEfficiencyMetric {
  final DateTime date;
  final int scheduledSlots;
  final int completedSlots;
  final int cancelledSlots;
  final int noShowSlots;
  final double utilizationRate;

  const OPDSlotEfficiencyMetric({
    required this.date,
    required this.scheduledSlots,
    required this.completedSlots,
    required this.cancelledSlots,
    required this.noShowSlots,
    required this.utilizationRate,
  });
}

class AverageLengthOfStayMetric {
  final DateTime date;
  final double averageDays;
  final int admissions;
  final int discharges;

  const AverageLengthOfStayMetric({
    required this.date,
    required this.averageDays,
    required this.admissions,
    required this.discharges,
  });
}

class EmergencyThroughputMetric {
  final DateTime date;
  final int emergencyCases;
  final double averageTriageToDoctorMinutes;
  final double medianTriageToDoctorMinutes;
  final int criticalCases;

  const EmergencyThroughputMetric({
    required this.date,
    required this.emergencyCases,
    required this.averageTriageToDoctorMinutes,
    required this.medianTriageToDoctorMinutes,
    required this.criticalCases,
  });
}

class BloodStockMetric {
  final DateTime date;
  final String bloodGroup;
  final int startingUnits;
  final int unitsIssued;
  final int unitsAdded;
  final int endingUnits;
  final double depletionVelocity;

  const BloodStockMetric({
    required this.date,
    required this.bloodGroup,
    required this.startingUnits,
    required this.unitsIssued,
    required this.unitsAdded,
    required this.endingUnits,
    required this.depletionVelocity,
  });
}

class EquipmentDowntimeMetric {
  final DateTime date;
  final int equipmentCount;
  final double downtimeHours;
  final double availableHours;
  final double downtimeRatio;

  const EquipmentDowntimeMetric({
    required this.date,
    required this.equipmentCount,
    required this.downtimeHours,
    required this.availableHours,
    required this.downtimeRatio,
  });
}

class NoShowMetric {
  final DateTime date;
  final int scheduledAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final double noShowRate;

  const NoShowMetric({
    required this.date,
    required this.scheduledAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.noShowAppointments,
    required this.noShowRate,
  });
}

class HospitalOperationalKpis {
  final double bedOccupancyRate;
  final double icuUtilizationRate;
  final double opdSlotEfficiency;
  final double averageLengthOfStay;
  final double erTriageToDoctorMinutes;
  final double bloodStockDepletionVelocity;
  final double equipmentDowntimeRatio;
  final double noShowRate;
  final String bedOccupancyChange;
  final String icuChange;
  final String opdChange;
  final String lengthOfStayChange;
  final String erTimeChange;
  final String bloodVelocityChange;
  final String downtimeChange;
  final String noShowChange;
  final DateTime generatedAt;

  const HospitalOperationalKpis({
    required this.bedOccupancyRate,
    required this.icuUtilizationRate,
    required this.opdSlotEfficiency,
    required this.averageLengthOfStay,
    required this.erTriageToDoctorMinutes,
    required this.bloodStockDepletionVelocity,
    required this.equipmentDowntimeRatio,
    required this.noShowRate,
    this.bedOccupancyChange = '+3.2%',
    this.icuChange = '-1.5%',
    this.opdChange = '+4.0%',
    this.lengthOfStayChange = '-0.2 days',
    this.erTimeChange = '-2.1 min',
    this.bloodVelocityChange = 'Stable',
    this.downtimeChange = '-0.5%',
    this.noShowChange = '-1.2%',
    required this.generatedAt,
  });
}
