/// Represents a nearby hospital with distance, ratings, facilities, and real-time bed/blood status.
class NearbyHospital {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double rating;
  final int reviewsCount;
  final bool isEmergencyOpen;
  final int availableBeds;
  final int totalBeds;
  final int icuAvailable;
  final int icuTotal;
  final Map<String, int> bloodStock; // e.g. {'O+': 14, 'O-': 2, 'A+': 18, 'B+': 10}
  final List<String> facilities;
  final String phone;
  final String openHours;

  const NearbyHospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.reviewsCount,
    required this.isEmergencyOpen,
    required this.availableBeds,
    required this.totalBeds,
    required this.icuAvailable,
    required this.icuTotal,
    required this.bloodStock,
    required this.facilities,
    required this.phone,
    this.openHours = '24/7 Emergency Care',
  });
}

/// Represents a doctor search item with specialty, rating, distance & available slots.
class DoctorSearchResult {
  final String id;
  final String name;
  final String specialty;
  final String department;
  final String hospitalName;
  final double distanceKm;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final double consultationFee;
  final List<String> availableSlots;
  final bool isTeleconsultAvailable;

  const DoctorSearchResult({
    required this.id,
    required this.name,
    required this.specialty,
    required this.department,
    required this.hospitalName,
    required this.distanceKm,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.availableSlots,
    this.isTeleconsultAvailable = true,
  });
}

/// Single lab or test parameter with normal reference ranges
class ReportParameter {
  final String name;
  final String value;
  final String unit;
  final String normalRange;
  final bool isNormal;

  const ReportParameter({
    required this.name,
    required this.value,
    this.unit = '',
    this.normalRange = '',
    this.isNormal = true,
  });
}

/// Audit log entry tracking who viewed or accessed a medical record
class ReportAccessLog {
  final String viewerName;
  final String viewerRole;
  final DateTime timestamp;
  final String action;

  const ReportAccessLog({
    required this.viewerName,
    required this.viewerRole,
    required this.timestamp,
    this.action = 'Viewed Document',
  });
}

/// Represents a secure temporary shared link for a medical report
class SharedReportLink {
  final String id;
  final String sharedWith;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isRevoked;

  const SharedReportLink({
    required this.id,
    required this.sharedWith,
    required this.createdAt,
    required this.expiresAt,
    this.isRevoked = false,
  });
}

/// Represents a patient's personal diagnostic, lab or clinical medical report.
class MedicalReport {
  final String id;
  final String title;
  final String category; // 'Lab Reports', 'Prescriptions', 'Imaging', 'Doctor Notes', 'Discharge Summary'
  final String doctorName;
  final String hospitalName;
  final DateTime date;
  final String summary;
  final String fileFormat; // 'PDF', 'DICOM', 'DOC', 'JPG'
  final String fileSize;
  final bool isExternalUploaded;
  final List<ReportParameter> parameters;
  final List<ReportAccessLog> accessLogs;
  final List<SharedReportLink> sharedLinks;

  const MedicalReport({
    required this.id,
    required this.title,
    required this.category,
    required this.doctorName,
    required this.hospitalName,
    required this.date,
    required this.summary,
    this.fileFormat = 'PDF',
    this.fileSize = '2.4 MB',
    this.isExternalUploaded = false,
    this.parameters = const [],
    this.accessLogs = const [],
    this.sharedLinks = const [],
  });

  MedicalReport copyWith({
    String? id,
    String? title,
    String? category,
    String? doctorName,
    String? hospitalName,
    DateTime? date,
    String? summary,
    String? fileFormat,
    String? fileSize,
    bool? isExternalUploaded,
    List<ReportParameter>? parameters,
    List<ReportAccessLog>? accessLogs,
    List<SharedReportLink>? sharedLinks,
  }) {
    return MedicalReport(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      doctorName: doctorName ?? this.doctorName,
      hospitalName: hospitalName ?? this.hospitalName,
      date: date ?? this.date,
      summary: summary ?? this.summary,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSize: fileSize ?? this.fileSize,
      isExternalUploaded: isExternalUploaded ?? this.isExternalUploaded,
      parameters: parameters ?? this.parameters,
      accessLogs: accessLogs ?? this.accessLogs,
      sharedLinks: sharedLinks ?? this.sharedLinks,
    );
  }
}

/// Output structure for AI Health Concern / Symptom Checker.
enum UrgencyLevel { emergency, urgent, routine }

class SymptomAnalysisResult {
  final String userQuery;
  final String recommendedDepartment;
  final UrgencyLevel urgency;
  final String advice;
  final List<String> matchedSymptoms;
  final List<DoctorSearchResult> suggestedDoctors;
  final List<NearbyHospital> recommendedHospitals;

  const SymptomAnalysisResult({
    required this.userQuery,
    required this.recommendedDepartment,
    required this.urgency,
    required this.advice,
    required this.matchedSymptoms,
    required this.suggestedDoctors,
    required this.recommendedHospitals,
  });
}

/// Represents a booked, rescheduled, completed or cancelled patient appointment
class PatientAppointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String hospitalName;
  final String hospitalAddress;
  final DateTime dateTime;
  final String consultationType; // 'In-person consultation', 'Video consultation'
  final String status; // 'Confirmed', 'Rescheduled', 'Completed', 'Cancelled'
  final String tokenNumber;
  final double consultationFee;
  final String reasonForVisit;
  final DateTime? rescheduledFrom;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final List<String> generatedReportTitles;

  const PatientAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.hospitalName,
    this.hospitalAddress = '742 Evergreen Terrace, Sector 4, City Care Hospital',
    required this.dateTime,
    this.consultationType = 'In-person consultation',
    this.status = 'Confirmed',
    this.tokenNumber = '#18',
    this.consultationFee = 500.0,
    this.reasonForVisit = 'Routine OPD Consultation',
    this.rescheduledFrom,
    this.cancellationReason,
    this.cancelledAt,
    this.generatedReportTitles = const [],
  });

  PatientAppointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? hospitalName,
    String? hospitalAddress,
    DateTime? dateTime,
    String? consultationType,
    String? status,
    String? tokenNumber,
    double? consultationFee,
    String? reasonForVisit,
    DateTime? rescheduledFrom,
    String? cancellationReason,
    DateTime? cancelledAt,
    List<String>? generatedReportTitles,
  }) {
    return PatientAppointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      dateTime: dateTime ?? this.dateTime,
      consultationType: consultationType ?? this.consultationType,
      status: status ?? this.status,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      consultationFee: consultationFee ?? this.consultationFee,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      rescheduledFrom: rescheduledFrom ?? this.rescheduledFrom,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      generatedReportTitles: generatedReportTitles ?? this.generatedReportTitles,
    );
  }
}

/// Bed category details for bed discovery feature
class BedCategoryDetail {
  final String name; // 'ICU', 'Emergency', 'General', 'Private', 'Pediatric', 'Maternity'
  final String icon;
  final int available;
  final int total;
  final String status; // 'Available', 'Limited', 'Full', 'Information unavailable'
  final DateTime lastUpdated;
  final List<String> relatedFacilities;

  const BedCategoryDetail({
    required this.name,
    this.icon = '🛏️',
    required this.available,
    required this.total,
    required this.status,
    required this.lastUpdated,
    this.relatedFacilities = const [],
  });

  bool get isStale => DateTime.now().difference(lastUpdated).inMinutes >= 60;
}

/// Timeline entry for bed availability updates
class BedAvailabilityTimelineEntry {
  final DateTime timestamp;
  final String categoryName;
  final int availableCount;

  const BedAvailabilityTimelineEntry({
    required this.timestamp,
    required this.categoryName,
    required this.availableCount,
  });
}

/// Comprehensive bed availability information for a hospital
class HospitalBedData {
  final NearbyHospital hospital;
  final String estimatedTravelTime;
  final DateTime lastUpdated;
  final bool emergencyDoctorAvailable;
  final bool ctScanAvailable;
  final List<BedCategoryDetail> categories;
  final List<BedAvailabilityTimelineEntry> timeline;

  const HospitalBedData({
    required this.hospital,
    this.estimatedTravelTime = '~10 min',
    required this.lastUpdated,
    this.emergencyDoctorAvailable = true,
    this.ctScanAvailable = true,
    required this.categories,
    required this.timeline,
  });

  bool get isStale => DateTime.now().difference(lastUpdated).inMinutes >= 60;
}

/// Blood group stock detail for blood bank discovery feature
class BloodGroupStockDetail {
  final String bloodGroup; // 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  final int unitsAvailable;
  final String status; // 'Available', 'Limited', 'Critical / Low', 'Unavailable'
  final Map<String, int> componentUnits; // e.g. {'Whole Blood': 4, 'PRBC': 6, 'Platelets': 2, 'FFP': 5}
  final DateTime lastUpdated;

  const BloodGroupStockDetail({
    required this.bloodGroup,
    required this.unitsAvailable,
    required this.status,
    this.componentUnits = const {},
    required this.lastUpdated,
  });

  bool get isStale => DateTime.now().difference(lastUpdated).inMinutes >= 60;
}

/// Comprehensive blood bank availability information for a hospital or standalone blood bank
class BloodBankData {
  final String id;
  final String name;
  final String type; // 'Multi-Specialty Hospital', 'Standalone Blood Bank', 'Government Red Cross Bank'
  final double rating;
  final int reviewCount;
  final String distance;
  final double distanceKm;
  final String travelTime;
  final String address;
  final String phone;
  final bool is24x7;
  final bool acceptsDonations;
  final DateTime lastUpdated;
  final List<BloodGroupStockDetail> stocks;

  const BloodBankData({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.distanceKm,
    required this.travelTime,
    required this.address,
    required this.phone,
    this.is24x7 = true,
    this.acceptsDonations = true,
    required this.lastUpdated,
    required this.stocks,
  });

  bool get isStale => DateTime.now().difference(lastUpdated).inMinutes >= 60;

  BloodGroupStockDetail? getStockForGroup(String group) {
    try {
      return stocks.firstWhere((s) => s.bloodGroup == group);
    } catch (_) {
      return null;
    }
  }
}

/// Blood request model for patient emergency/elective request tracking
class BloodRequestModel {
  final String id;
  final String patientName;
  final String patientId;
  final String bloodGroup;
  final int unitsNeeded;
  final String componentType; // 'Whole Blood', 'PRBC', 'Platelets', 'FFP'
  final String hospitalName;
  final String urgencyLevel; // 'Routine', 'Urgent', 'Emergency SOS'
  final String status; // 'Pending', 'Matched', 'Contacted', 'Fulfilled', 'Cancelled'
  final DateTime createdAt;
  final String contactPhone;
  final String? matchedBankName;

  const BloodRequestModel({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.bloodGroup,
    required this.unitsNeeded,
    this.componentType = 'PRBC',
    required this.hospitalName,
    required this.urgencyLevel,
    required this.status,
    required this.createdAt,
    required this.contactPhone,
    this.matchedBankName,
  });
}

/// Nearby blood donation center detail
class DonationCenter {
  final String id;
  final String name;
  final String address;
  final String distance;
  final double distanceKm;
  final String operatingHours;
  final String phone;
  final bool openToday;
  final List<String> perks; // e.g. ['Free Health Checkup', 'Donor Certificate', 'Refreshments']

  const DonationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.distanceKm,
    required this.operatingHours,
    required this.phone,
    this.openToday = true,
    this.perks = const [],
  });
}
