import '../../enums/domain_enums.dart';
import '../../models/resource_model.dart';
import '../../queries/domain_queries.dart';

abstract class ResourceRepository {
  Future<List<ResourceMatrixItem>> getResourceMatrix({ResourceQuery query = const ResourceQuery()});
  Future<List<ResourceSnapshot>> getResourceSnapshots({ResourceQuery query = const ResourceQuery()});
  Future<List<DepartmentCapacitySummary>> getDepartmentCapacitySummaries();
  Future<List<ResourceAllocationRequest>> getAllocationRequests({AllocationRequestQuery query = const AllocationRequestQuery()});
  Future<ResourceAllocationRequest> createAllocationRequest(ResourceAllocationRequest request);
  Future<ResourceAllocationRequest> updateAllocationRequestStatus(String requestId, AllocationRequestStatus status);
  Future<List<ResourceAllocationRecommendation>> getRecommendations({RecommendationQuery query = const RecommendationQuery()});
  Future<ResourceAllocationRecommendation> reviewRecommendation(String recommendationId, RecommendationStatus status);
}
