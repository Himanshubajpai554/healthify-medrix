import '../data/repositories/location_repository.dart';
import '../data/repositories/patient_discovery_repository.dart';
import '../data/repositories/review_eligibility_repository.dart';
import '../data/repositories/review_repository.dart';
import '../models/ai_insight_model.dart';
import '../models/doctor_model.dart';
import '../models/hospital_model.dart';
import '../provider/repository_provider.dart';

import '../queries/domain_queries.dart';
import 'distance_service.dart';

class PatientDiscoveryService {
  final PatientDiscoveryRepository _discoveryRepository;
  final ReviewRepository _reviewRepository;
  final ReviewEligibilityRepository _eligibilityRepository;
  final LocationRepository _locationRepository;

  PatientDiscoveryService({
    PatientDiscoveryRepository? discoveryRepository,
    ReviewRepository? reviewRepository,
    ReviewEligibilityRepository? eligibilityRepository,
    LocationRepository? locationRepository,
  })  : _discoveryRepository =
            discoveryRepository ?? RepositoryContainer.instance.patientDiscoveryRepository,
        _reviewRepository = reviewRepository ?? RepositoryContainer.instance.reviewRepository,
        _eligibilityRepository =
            eligibilityRepository ?? RepositoryContainer.instance.reviewEligibilityRepository,
        _locationRepository =
            locationRepository ?? RepositoryContainer.instance.locationRepository;

  Future<List<Hospital>> searchHospitals(HospitalSearchQuery query) async {
    return await _discoveryRepository.searchHospitals(query);
  }

  Future<HospitalProfile?> getHospitalDetails(String hospitalId) async {
    return await _discoveryRepository.getHospitalDetails(hospitalId);
  }

  Future<List<Doctor>> searchDoctors(DoctorSearchQuery query) async {
    return await _discoveryRepository.searchDoctors(query);
  }

  Future<Doctor?> getDoctorDetails(String doctorId) async {
    return await _discoveryRepository.getDoctorDetails(doctorId);
  }

  Future<HealthConcernMappingResult> discoverForHealthConcern(String healthConcernText) async {
    final location = await _locationRepository.getCurrentLocation();
    return await _discoveryRepository.getHealthConcernMapping(
      HealthConcernQuery(
        healthConcernText: healthConcernText,
        userLatitude: location.latitude,
        userLongitude: location.longitude,
      ),
    );
  }

  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations({
    String? category,
    List<String> requiredResources = const [],
  }) async {
    final location = await _locationRepository.getCurrentLocation();
    return await _discoveryRepository.getEmergencyRecommendations(
      EmergencyRecommendationQuery(
        emergencyCategory: category,
        requiredResources: requiredResources,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
  }

  Future<List<HospitalRating>> getHospitalReviews(String hospitalId) async {
    return await _reviewRepository.getReviews(
      ReviewQuery(targetType: 'hospital', targetId: hospitalId),
    );
  }

  Future<bool> checkReviewEligibility(String patientId, String hospitalId) async {
    return await _eligibilityRepository.checkEligibility(
      ReviewEligibilityQuery(
        patientId: patientId,
        targetType: 'hospital',
        targetId: hospitalId,
      ),
    );
  }

  Future<HospitalRating> submitReview({
    required String patientId,
    required String patientName,
    required String hospitalId,
    required double rating,
    required String reviewText,
  }) async {
    return await _reviewRepository.createReview(
      CreateReviewRequest(
        patientId: patientId,
        patientName: patientName,
        targetType: 'hospital',
        targetId: hospitalId,
        rating: rating,
        reviewText: reviewText,
      ),
    );
  }

  Future<double> getDistanceToHospital(double destLat, double destLon) async {
    final current = await _locationRepository.getCurrentLocation();
    return DistanceService.calculateDistanceKmFromCoords(
      current.latitude,
      current.longitude,
      destLat,
      destLon,
    );
  }
}
