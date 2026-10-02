import '../data/repositories/resource_repository.dart';
import '../enums/domain_enums.dart';
import '../models/resource_model.dart';
import '../queries/domain_queries.dart';

class ResourceService {
  final ResourceRepository resourceRepository;

  ResourceService({required this.resourceRepository});

  Future<List<ResourceMatrixItem>> getResourceMatrix({ResourceQuery query = const ResourceQuery()}) async {
    return await resourceRepository.getResourceMatrix(query: query);
  }

  Future<List<ResourceSnapshot>> getResourceSnapshots({ResourceQuery query = const ResourceQuery()}) async {
    return await resourceRepository.getResourceSnapshots(query: query);
  }

  Future<List<DepartmentCapacitySummary>> getDepartmentCapacitySummaries() async {
    return await resourceRepository.getDepartmentCapacitySummaries();
  }

  Future<List<ResourceAllocationRequest>> getAllocationRequests({AllocationRequestQuery query = const AllocationRequestQuery()}) async {
    return await resourceRepository.getAllocationRequests(query: query);
  }

  Future<ResourceAllocationRequest> createAllocationRequest(ResourceAllocationRequest request) async {
    return await resourceRepository.createAllocationRequest(request);
  }

  Future<ResourceAllocationRequest> updateAllocationRequestStatus(String requestId, AllocationRequestStatus status) async {
    return await resourceRepository.updateAllocationRequestStatus(requestId, status);
  }

  Future<List<ResourceAllocationRecommendation>> getRecommendations({RecommendationQuery query = const RecommendationQuery()}) async {
    return await resourceRepository.getRecommendations(query: query);
  }

  Future<ResourceAllocationRecommendation> reviewRecommendation(String recommendationId, RecommendationStatus status) async {
    return await resourceRepository.reviewRecommendation(recommendationId, status);
  }
}
