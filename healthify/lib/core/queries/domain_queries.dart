import '../enums/domain_enums.dart';
import 'pagination.dart';

class PatientQuery {
  final String? searchQuery;
  final PatientStatus? status;
  final String? statusFilter;
  final String? bloodGroupFilter;
  final DateTime? admissionDate;
  final String? departmentId;
  final String? doctorId;
  final PaginationParams pagination;

  const PatientQuery({
    this.searchQuery,
    this.status,
    this.statusFilter,
    this.bloodGroupFilter,
    this.admissionDate,
    this.departmentId,
    this.doctorId,
    this.pagination = const PaginationParams(),
  });
}

class DoctorQuery {
  final String? searchQuery;
  final String? specialty;
  final DoctorAvailabilityStatus? availability;
  final DoctorAffiliationStatus? affiliation;
  final String? departmentId;
  final PaginationParams pagination;

  const DoctorQuery({
    this.searchQuery,
    this.specialty,
    this.availability,
    this.affiliation,
    this.departmentId,
    this.pagination = const PaginationParams(),
  });
}

class StaffQuery {
  final String? searchQuery;
  final String? departmentId;
  final StaffStatus? status;
  final String? role;
  final PaginationParams pagination;

  const StaffQuery({
    this.searchQuery,
    this.departmentId,
    this.status,
    this.role,
    this.pagination = const PaginationParams(),
  });
}

class AppointmentQuery {
  final String? searchQuery;
  final String? patientId;
  final String? doctorId;
  final String? departmentId;
  final AppointmentStatus? status;
  final String? type;
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;
  final PaginationParams pagination;

  const AppointmentQuery({
    this.searchQuery,
    this.patientId,
    this.doctorId,
    this.departmentId,
    this.status,
    this.type,
    this.date,
    this.startDate,
    this.endDate,
    this.pagination = const PaginationParams(),
  });
}

class BedQuery {
  final String? searchQuery;
  final String? ward;
  final String? buildingId;
  final String? floorId;
  final String? roomId;
  final String? departmentId;
  final BedStatus? status;
  final String? bedType;
  final bool? isICU;
  final bool? isolation;
  final String? patientId;
  final PaginationParams pagination;

  const BedQuery({
    this.searchQuery,
    this.ward,
    this.buildingId,
    this.floorId,
    this.roomId,
    this.departmentId,
    this.status,
    this.bedType,
    this.isICU,
    this.isolation,
    this.patientId,
    this.pagination = const PaginationParams(),
  });
}

class BloodInventoryQuery {
  final String? bloodGroup;
  final BloodUnitStatus? status;
  final PaginationParams pagination;

  const BloodInventoryQuery({
    this.bloodGroup,
    this.status,
    this.pagination = const PaginationParams(),
  });
}

class EmergencyQuery {
  final String? searchQuery;
  final String? doctorId;
  final String? nurseId;
  final String? bayId;
  final dynamic arrivalMode;
  final TriageLevel? triageLevel;
  final TriageLevel? minTriageLevel;
  final EmergencyStatus? status;
  final bool? criticalOnly;
  final bool? anonymousOnly;
  final PaginationParams pagination;

  const EmergencyQuery({
    this.searchQuery,
    this.doctorId,
    this.nurseId,
    this.bayId,
    this.arrivalMode,
    this.triageLevel,
    this.minTriageLevel,
    this.status,
    this.criticalOnly,
    this.anonymousOnly,
    this.pagination = const PaginationParams(),
  });
}

class ReportQuery {
  final String? searchQuery;
  final String? patientId;
  final String? doctorId;
  final String? departmentId;
  final ReportType? reportType;
  final ReportVerificationStatus? verificationStatus;
  final bool? isCritical;
  final bool? releasedToPatient;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sort;
  final PaginationParams pagination;

  const ReportQuery({
    this.searchQuery,
    this.patientId,
    this.doctorId,
    this.departmentId,
    this.reportType,
    this.verificationStatus,
    this.isCritical,
    this.releasedToPatient,
    this.startDate,
    this.endDate,
    this.sort,
    this.pagination = const PaginationParams(),
  });
}

class PrescriptionQuery {
  final String? searchQuery;
  final String? patientId;
  final String? doctorId;
  final PrescriptionStatus? status;
  final PharmacyFulfillmentStatus? fulfillmentStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sort;
  final PaginationParams pagination;

  const PrescriptionQuery({
    this.searchQuery,
    this.patientId,
    this.doctorId,
    this.status,
    this.fulfillmentStatus,
    this.startDate,
    this.endDate,
    this.sort,
    this.pagination = const PaginationParams(),
  });
}

class NotificationQuery {
  final String? search;
  final String? searchQuery;
  final NotificationType? type;
  final NotificationPriority? priority;
  final NotificationStatus? status;
  final String? recipientId;
  final UserRole? recipientRole;
  final String? sourceEntityType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? unreadOnly;
  final bool? criticalOnly;
  final bool? isRead;
  final String? sort;
  final PaginationParams pagination;

  const NotificationQuery({
    this.search,
    this.searchQuery,
    this.type,
    this.priority,
    this.status,
    this.recipientId,
    this.recipientRole,
    this.sourceEntityType,
    this.startDate,
    this.endDate,
    this.unreadOnly,
    this.criticalOnly,
    this.isRead,
    this.sort,
    this.pagination = const PaginationParams(),
  });

  String? get effectiveSearch => search ?? searchQuery;
}

class AuditLogQuery {
  final String? search;
  final String? searchQuery;
  final String? actorId;
  final String? userId;
  final UserRole? actorRole;
  final AuditActionType? actionType;
  final String? action;
  final String? targetEntityType;
  final String? targetEntityId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? permissionDeniedOnly;
  final bool? sensitiveAccessOnly;
  final String? sort;
  final PaginationParams pagination;

  const AuditLogQuery({
    this.search,
    this.searchQuery,
    this.actorId,
    this.userId,
    this.actorRole,
    this.actionType,
    this.action,
    this.targetEntityType,
    this.targetEntityId,
    this.startDate,
    this.endDate,
    this.permissionDeniedOnly,
    this.sensitiveAccessOnly,
    this.sort,
    this.pagination = const PaginationParams(),
  });

  String? get effectiveSearch => search ?? searchQuery;
  String? get effectiveActorId => actorId ?? userId;
}

class SecurityQuery {
  final String? search;
  final UserRole? role;
  final SecurityEventSeverity? severity;
  final String? status;
  final PaginationParams pagination;

  const SecurityQuery({
    this.search,
    this.role,
    this.severity,
    this.status,
    this.pagination = const PaginationParams(),
  });
}

class ResourceQuery {
  final String? searchQuery;
  final String? departmentId;
  final HospitalResourceType? resourceType;
  final ResourceAvailabilityStatus? status;
  final PaginationParams pagination;

  const ResourceQuery({
    this.searchQuery,
    this.departmentId,
    this.resourceType,
    this.status,
    this.pagination = const PaginationParams(),
  });
}

class AnalyticsQuery {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? departmentId;
  final HospitalResourceType? resourceType;
  final AnalyticsGranularity granularity;
  final PaginationParams pagination;

  const AnalyticsQuery({
    this.startDate,
    this.endDate,
    this.departmentId,
    this.resourceType,
    this.granularity = AnalyticsGranularity.day,
    this.pagination = const PaginationParams(),
  });
}

class AllocationRequestQuery {
  final String? searchQuery;
  final String? departmentId;
  final HospitalResourceType? resourceType;
  final AllocationRequestStatus? status;
  final AllocationPriority? priority;
  final PaginationParams pagination;

  const AllocationRequestQuery({
    this.searchQuery,
    this.departmentId,
    this.resourceType,
    this.status,
    this.priority,
    this.pagination = const PaginationParams(),
  });
}

class RecommendationQuery {
  final String? searchQuery;
  final HospitalResourceType? resourceType;
  final RecommendationStatus? status;
  final PaginationParams pagination;

  const RecommendationQuery({
    this.searchQuery,
    this.resourceType,
    this.status,
    this.pagination = const PaginationParams(),
  });
}

class AIQuery {
  final AIModelType? modelType;
  final String? hospitalId;
  final String? departmentId;
  final DateTime? startDate;
  final DateTime? endDate;
  final RecommendationStatus? status;
  final AIInsightSeverity? severity;
  final String? sort;
  final PaginationParams pagination;

  const AIQuery({
    this.modelType,
    this.hospitalId,
    this.departmentId,
    this.startDate,
    this.endDate,
    this.status,
    this.severity,
    this.sort,
    this.pagination = const PaginationParams(),
  });
}

class HospitalSearchQuery {
  final String searchText;
  final String? departmentId;
  final bool emergencyOnly;
  final double minimumRating;
  final double maximumDistance;
  final bool bedsAvailable;
  final bool icuAvailable;
  final bool bloodAvailable;
  final List<String> facilityIds;
  final bool openNow;
  final String sortBy; // 'distance', 'rating', 'availability', 'name'
  final int page;
  final int pageSize;

  const HospitalSearchQuery({
    this.searchText = '',
    this.departmentId,
    this.emergencyOnly = false,
    this.minimumRating = 0.0,
    this.maximumDistance = 50.0,
    this.bedsAvailable = false,
    this.icuAvailable = false,
    this.bloodAvailable = false,
    this.facilityIds = const [],
    this.openNow = false,
    this.sortBy = 'distance',
    this.page = 1,
    this.pageSize = 20,
  });
}

class DoctorSearchQuery {
  final String searchText;
  final String? specialty;
  final String? departmentId;
  final String? hospitalId;
  final double minimumRating;
  final bool availableToday;
  final String sortBy; // 'rating', 'experience', 'distance', 'name'
  final int page;
  final int pageSize;

  const DoctorSearchQuery({
    this.searchText = '',
    this.specialty,
    this.departmentId,
    this.hospitalId,
    this.minimumRating = 0.0,
    this.availableToday = false,
    this.sortBy = 'rating',
    this.page = 1,
    this.pageSize = 20,
  });
}

class HealthConcernQuery {
  final String healthConcernText;
  final String? patientId;
  final double? userLatitude;
  final double? userLongitude;

  const HealthConcernQuery({
    required this.healthConcernText,
    this.patientId,
    this.userLatitude,
    this.userLongitude,
  });
}

class EmergencyRecommendationQuery {
  final String? emergencyCategory; // e.g. 'Trauma', 'Cardiac', 'ICU', 'Pediatric', 'General'
  final List<String> requiredResources;
  final double? latitude;
  final double? longitude;
  final double maxRadiusKm;

  const EmergencyRecommendationQuery({
    this.emergencyCategory,
    this.requiredResources = const [],
    this.latitude,
    this.longitude,
    this.maxRadiusKm = 25.0,
  });
}

class ReviewEligibilityQuery {
  final String patientId;
  final String targetType; // 'hospital' or 'doctor'
  final String targetId;

  const ReviewEligibilityQuery({
    required this.patientId,
    required this.targetType,
    required this.targetId,
  });
}

class CreateReviewRequest {
  final String patientId;
  final String patientName;
  final String targetType; // 'hospital' or 'doctor'
  final String targetId;
  final double rating;
  final String reviewText;

  const CreateReviewRequest({
    required this.patientId,
    required this.patientName,
    required this.targetType,
    required this.targetId,
    required this.rating,
    required this.reviewText,
  });
}

class ReviewQuery {
  final String targetType; // 'hospital' or 'doctor'
  final String targetId;
  final PaginationParams pagination;

  const ReviewQuery({
    required this.targetType,
    required this.targetId,
    this.pagination = const PaginationParams(),
  });
}

