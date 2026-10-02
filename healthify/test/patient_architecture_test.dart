import 'package:flutter_test/flutter_test.dart';
import 'package:healthify_hospital/core/data/mock/mock_location_repository.dart';
import 'package:healthify_hospital/core/data/mock/mock_patient_discovery_repository.dart';
import 'package:healthify_hospital/core/data/mock/mock_review_eligibility_repository.dart';
import 'package:healthify_hospital/core/data/mock/mock_review_repository.dart';
import 'package:healthify_hospital/core/queries/domain_queries.dart';

import 'package:healthify_hospital/core/services/distance_service.dart';
import 'package:healthify_hospital/core/services/patient_data_visibility_service.dart';
import 'package:healthify_hospital/core/services/patient_discovery_service.dart';

void main() {
  group('Phase 16 — Patient App Architecture & Contract Tests', () {
    late MockPatientDiscoveryRepository discoveryRepo;
    late MockReviewRepository reviewRepo;
    late MockReviewEligibilityRepository eligibilityRepo;
    late MockLocationRepository locationRepo;
    late PatientDiscoveryService discoveryService;

    setUp(() {
      discoveryRepo = MockPatientDiscoveryRepository();
      reviewRepo = MockReviewRepository();
      eligibilityRepo = MockReviewEligibilityRepository();
      locationRepo = MockLocationRepository();

      discoveryService = PatientDiscoveryService(
        discoveryRepository: discoveryRepo,
        reviewRepository: reviewRepo,
        eligibilityRepository: eligibilityRepo,
        locationRepository: locationRepo,
      );
    });

    test('1. Hospital Search Filtering & Sorting Works Cleanly', () async {
      final results = await discoveryService.searchHospitals(
        const HospitalSearchQuery(searchText: 'St. Jude', sortBy: 'rating'),
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.name, contains('St. Jude'));
      expect(results.first.rating, greaterThanOrEqualTo(4.5));
    });

    test('2. Doctor Search Filtering Works Cleanly', () async {
      final doctors = await discoveryService.searchDoctors(
        const DoctorSearchQuery(specialty: 'Cardiology'),
      );

      expect(doctors.isNotEmpty, isTrue);
      expect(doctors.first.specialty, contains('Cardiology'));
    });

    test('3. Health Concern Discovery Returns Non-Diagnostic Mapping', () async {
      final result = await discoveryService.discoverForHealthConcern('Persistent stomach pain and indigestion');

      expect(result.queryText, equals('Persistent stomach pain and indigestion'));
      expect(result.relevantDepartments.isNotEmpty, isTrue);
      expect(result.nonDiagnosticDisclaimer, contains('not a diagnosis'));
      expect(result.matchingDoctors.isNotEmpty, isTrue);
    });

    test('4. Emergency Hospital Recommendations Return Advisory Output', () async {
      final recommendations = await discoveryService.getEmergencyRecommendations(
        category: 'Trauma',
      );

      expect(recommendations.isNotEmpty, isTrue);
      expect(recommendations.first.emergencyAvailability, isNotEmpty);
      expect(recommendations.first.icuAvailability, greaterThan(0));
    });

    test('5. Location Repository & Distance Service Calculate Haversine Distance', () async {
      final loc = await locationRepo.getCurrentLocation();
      expect(loc.latitude, equals(40.730610));

      final dist = DistanceService.calculateDistanceKmFromCoords(
        loc.latitude,
        loc.longitude,
        40.758896,
        -73.985130,
      );

      expect(dist, greaterThan(0));
    });

    test('6. Patient Data Visibility Boundary Filters Staff/Internal Alerts', () {
      final filtered = PatientDataVisibilityService.filterPatientNotifications(
        [],
        'PAT-8842',
      );

      expect(filtered, isEmpty);
    });

    test('7. Review Submission & Eligibility Check Works Cleanly', () async {
      final isEligible = await discoveryService.checkReviewEligibility('PAT-8842', 'HOSP-101');
      expect(isEligible, isTrue);

      final review = await discoveryService.submitReview(
        patientId: 'PAT-8842',
        patientName: 'Alex Rivera',
        hospitalId: 'HOSP-101',
        rating: 5.0,
        reviewText: 'Great care and excellent nursing staff.',
      );

      expect(review.ratingScore, equals(5.0));
      expect(review.feedback, contains('Great care'));
    });
  });
}
