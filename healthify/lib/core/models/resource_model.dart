import '../enums/domain_enums.dart';

/// Operational Resource Snapshot (not a replacement for underlying domain repositories).
class ResourceSnapshot {
  final String id;
  final String hospitalId;
  final HospitalResourceType resourceType;
  final String resourceId;
  final String departmentId;
  final int totalCapacity;
  final int availableCapacity;
  final int reservedCapacity;
  final int occupiedCapacity;
  final int maintenanceCapacity;
  final ResourceAvailabilityStatus status;
  final DateTime capturedAt;

  const ResourceSnapshot({
    required this.id,
    required this.hospitalId,
    required this.resourceType,
    required this.resourceId,
    required this.departmentId,
    required this.totalCapacity,
    required this.availableCapacity,
    required this.reservedCapacity,
    required this.occupiedCapacity,
    required this.maintenanceCapacity,
    required this.status,
    required this.capturedAt,
  });
}

/// Structured Resource Matrix Row for Dashboard & Tables
class ResourceMatrixItem {
  final HospitalResourceType resourceType;
  final String resourceName;
  final int total;
  final int available;
  final int occupied;
  final int reserved;
  final int maintenance;
  final double utilizationPercentage;
  final ResourceAvailabilityStatus status;

  const ResourceMatrixItem({
    required this.resourceType,
    required this.resourceName,
    required this.total,
    required this.available,
    required this.occupied,
    required this.reserved,
    required this.maintenance,
    required this.utilizationPercentage,
    required this.status,
  });
}

/// Operational Resource Allocation Request
class ResourceAllocationRequest {
  final String id;
  final String hospitalId;
  final HospitalResourceType resourceType;
  final String? resourceId;
  final String requestedBy;
  final String departmentId;
  final int quantity;
  final AllocationPriority priority;
  final String reason;
  final AllocationRequestStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ResourceAllocationRequest({
    required this.id,
    required this.hospitalId,
    required this.resourceType,
    this.resourceId,
    required this.requestedBy,
    required this.departmentId,
    required this.quantity,
    this.priority = AllocationPriority.medium,
    required this.reason,
    this.status = AllocationRequestStatus.pending,
    required this.createdAt,
    this.resolvedAt,
  });

  ResourceAllocationRequest copyWith({
    String? id,
    String? hospitalId,
    HospitalResourceType? resourceType,
    String? resourceId,
    String? requestedBy,
    String? departmentId,
    int? quantity,
    AllocationPriority? priority,
    String? reason,
    AllocationRequestStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ResourceAllocationRequest(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      requestedBy: requestedBy ?? this.requestedBy,
      departmentId: departmentId ?? this.departmentId,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// Operational Resource Allocation Recommendation (Insight for Human Review)
class ResourceAllocationRecommendation {
  final String id;
  final String hospitalId;
  final HospitalResourceType resourceType;
  final String? resourceId;
  final String currentStatus;
  final String recommendedAction;
  final String reason;
  final String impact;
  final double confidence;
  final DateTime generatedAt;
  final RecommendationStatus status;

  const ResourceAllocationRecommendation({
    required this.id,
    required this.hospitalId,
    required this.resourceType,
    this.resourceId,
    required this.currentStatus,
    required this.recommendedAction,
    required this.reason,
    required this.impact,
    this.confidence = 0.85,
    required this.generatedAt,
    this.status = RecommendationStatus.newAction,
  });

  ResourceAllocationRecommendation copyWith({
    String? id,
    String? hospitalId,
    HospitalResourceType? resourceType,
    String? resourceId,
    String? currentStatus,
    String? recommendedAction,
    String? reason,
    String? impact,
    double? confidence,
    DateTime? generatedAt,
    RecommendationStatus? status,
  }) {
    return ResourceAllocationRecommendation(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      currentStatus: currentStatus ?? this.currentStatus,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      reason: reason ?? this.reason,
      impact: impact ?? this.impact,
      confidence: confidence ?? this.confidence,
      generatedAt: generatedAt ?? this.generatedAt,
      status: status ?? this.status,
    );
  }
}

/// Department-Level Capacity Summary
class DepartmentCapacitySummary {
  final String departmentId;
  final String departmentName;
  final int totalBeds;
  final int availableBeds;
  final int occupiedBeds;
  final int doctorCount;
  final int availableDoctors;
  final int staffCount;
  final int availableStaff;
  final int activeAppointments;
  final int waitingAppointments;
  final int emergencyCases;
  final double utilization;
  final DateTime capturedAt;

  const DepartmentCapacitySummary({
    required this.departmentId,
    required this.departmentName,
    required this.totalBeds,
    required this.availableBeds,
    required this.occupiedBeds,
    required this.doctorCount,
    required this.availableDoctors,
    required this.staffCount,
    required this.availableStaff,
    required this.activeAppointments,
    required this.waitingAppointments,
    required this.emergencyCases,
    required this.utilization,
    required this.capturedAt,
  });
}
